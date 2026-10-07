import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import prisma from '../../db/prisma.js';
import {
  getAllFeatures,
  getFeature,
  isFeatureGloballyEnabled,
  setFeatureGloballyEnabled
} from '../../features/registry.js';
import { BUILTIN_PRESETS } from '../../features/presets.js';

export function checkAdminRole(request: FastifyRequest, reply: FastifyReply): boolean {
  const user = (request as any).user;
  if (user && user.role === 'viewer') {
    reply.status(403).send({ error: 'Forbidden: Viewer role has read-only access' });
    return false;
  }
  return true;
}

export async function featuresRoutes(fastify: FastifyInstance) {
  // GET /api/features/registry - List all features from the registry
  fastify.get('/features/registry', async (request: FastifyRequest, reply: FastifyReply) => {
    const features = getAllFeatures();
    const result = await Promise.all(
      features.map(async (f) => {
        const globallyEnabled = await isFeatureGloballyEnabled(prisma, f.key);
        const usedCount = await prisma.portFeature.count({
          where: { featureKey: f.key, enabled: true }
        });

        return {
          key: f.key,
          label: f.label,
          description: f.description,
          settingsSchema: f.settingsSchema,
          defaultConfig: f.defaultConfig,
          applicableLayers: f.applicableLayers,
          applicableProtocols: f.applicableProtocols,
          globallyEnabled,
          usedCount
        };
      })
    );

    return reply.send(result);
  });

  // PATCH /api/features/registry/:key - Globally enable/disable a feature (admin only)
  fastify.patch('/features/registry/:key', async (request: FastifyRequest<{ Params: { key: string }; Body: { enabled: boolean } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { key } = request.params;
    const { enabled } = request.body || {};

    const feature = getFeature(key);
    if (!feature) {
      return reply.status(404).send({ error: `Feature '${key}' not found in registry` });
    }

    await setFeatureGloballyEnabled(prisma, key, !!enabled);

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'update',
        entity: 'feature_registry',
        entityId: key,
        afterState: { key, globallyEnabled: !!enabled }
      }
    });

    return reply.send({ key, globallyEnabled: !!enabled });
  });

  // GET /api/feature-presets - List all presets (builtin + custom)
  fastify.get('/feature-presets', async (request: FastifyRequest, reply: FastifyReply) => {
    // Ensure built-in presets exist
    for (const p of BUILTIN_PRESETS) {
      const existing = await prisma.featurePreset.findUnique({ where: { name: p.name } });
      if (!existing) {
        await prisma.featurePreset.create({
          data: {
            name: p.name,
            description: p.description,
            isBuiltin: true,
            features: p.features
          }
        });
      }
    }

    const presets = await prisma.featurePreset.findMany({
      orderBy: [{ isBuiltin: 'desc' }, { name: 'asc' }]
    });

    return reply.send(presets);
  });

  // POST /api/feature-presets - Create a custom preset from port settings or scratch
  fastify.post('/feature-presets', async (request: FastifyRequest, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const schema = z.object({
      name: z.string().min(1),
      description: z.string().optional(),
      features: z.record(z.any()),
      portId: z.string().optional() // if saving from existing port
    });

    const parsed = schema.safeParse(request.body);
    if (!parsed.success) {
      return reply.status(400).send({ error: parsed.error });
    }

    let { name, description, features, portId } = parsed.data;

    // If portId is given, read features from port
    if (portId && Object.keys(features || {}).length === 0) {
      const portFeatures = await prisma.portFeature.findMany({
        where: { portId }
      });
      const featureMap: Record<string, any> = {};
      for (const pf of portFeatures) {
        featureMap[pf.featureKey] = { enabled: pf.enabled, config: pf.config };
      }
      features = featureMap;
    }

    const existing = await prisma.featurePreset.findUnique({ where: { name } });
    if (existing) {
      return reply.status(400).send({ error: `Preset with name '${name}' already exists` });
    }

    const created = await prisma.featurePreset.create({
      data: {
        name,
        description: description || null,
        isBuiltin: false,
        features
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'create',
        entity: 'feature_preset',
        entityId: created.id,
        afterState: created
      }
    });

    return reply.status(201).send(created);
  });

  // PATCH /api/feature-presets/:id - Edit custom preset
  fastify.patch('/feature-presets/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const body = request.body as any;

    const existing = await prisma.featurePreset.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Preset not found' });
    if (existing.isBuiltin) {
      return reply.status(400).send({ error: 'Built-in presets cannot be edited' });
    }

    const updated = await prisma.featurePreset.update({
      where: { id },
      data: {
        name: body.name !== undefined ? body.name : existing.name,
        description: body.description !== undefined ? body.description : existing.description,
        features: body.features !== undefined ? body.features : existing.features
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'update',
        entity: 'feature_preset',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send(updated);
  });

  // DELETE /api/feature-presets/:id - Delete custom preset
  fastify.delete('/feature-presets/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const existing = await prisma.featurePreset.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Preset not found' });
    if (existing.isBuiltin) {
      return reply.status(400).send({ error: 'Built-in presets cannot be deleted' });
    }

    await prisma.featurePreset.delete({ where: { id } });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'delete',
        entity: 'feature_preset',
        entityId: id,
        beforeState: existing
      }
    });

    return reply.send({ success: true });
  });
}
