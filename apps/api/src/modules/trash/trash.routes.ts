import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';

export function checkAdminRole(request: FastifyRequest, reply: FastifyReply): boolean {
  const user = (request as any).user;
  if (user && user.role === 'viewer') {
    reply.status(403).send({ error: 'Forbidden: Viewer role has read-only access' });
    return false;
  }
  return true;
}

export async function trashRoutes(fastify: FastifyInstance) {
  // GET /api/trash - Overview of all archived items across entities
  fastify.get('/trash', async (request: FastifyRequest, reply: FastifyReply) => {
    const [archivedPorts, archivedRoutes, archivedBackends, archivedServers, snapshots] = await Promise.all([
      prisma.port.findMany({
        where: { archivedAt: { not: null } },
        orderBy: { archivedAt: 'desc' }
      }),
      prisma.route.findMany({
        where: { archivedAt: { not: null } },
        include: { backend: true },
        orderBy: { archivedAt: 'desc' }
      }),
      prisma.backend.findMany({
        where: { archivedAt: { not: null } },
        orderBy: { archivedAt: 'desc' }
      }),
      prisma.server.findMany({
        where: { archivedAt: { not: null } },
        orderBy: { archivedAt: 'desc' }
      }),
      prisma.trashSnapshot.findMany({
        orderBy: { createdAt: 'desc' },
        take: 50
      })
    ]);

    return reply.send({
      ports: archivedPorts,
      routes: archivedRoutes,
      backends: archivedBackends,
      servers: archivedServers,
      snapshots,
      totalArchived:
        archivedPorts.length +
        archivedRoutes.length +
        archivedBackends.length +
        archivedServers.length
    });
  });

  // POST /api/trash/restore-snapshot/:id - Restores an entity from its permanent delete snapshot
  fastify.post('/trash/restore-snapshot/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const snapshot = await prisma.trashSnapshot.findUnique({ where: { id } });
    if (!snapshot) {
      return reply.status(404).send({ error: 'Trash snapshot not found' });
    }

    const data: any = snapshot.data;
    const username = (request as any).user?.username || 'admin';

    if (snapshot.entityType === 'port') {
      const portData = data.port || data;
      // Check if port number is already taken
      const existing = await prisma.port.findFirst({
        where: { port: portData.port, archivedAt: null }
      });
      if (existing) {
        return reply.status(400).send({
          error: `Cannot restore: Port ${portData.port} is already currently active in database.`
        });
      }

      const restored = await prisma.port.create({
        data: {
          port: portData.port,
          layer: portData.layer || 'http',
          protocol: portData.protocol || 'HTTP',
          purpose: portData.purpose || '',
          notes: portData.notes || '',
          isPublic: portData.isPublic !== undefined ? portData.isPublic : true,
          tags: portData.tags || [],
          customValues: portData.customValues || {},
          lifecycle: 'active',
          isExpected: true,
          isDocumented: true
        }
      });

      // Restore features if available
      if (Array.isArray(data.features)) {
        for (const f of data.features) {
          await prisma.portFeature.create({
            data: {
              portId: restored.id,
              featureKey: f.featureKey,
              enabled: f.enabled !== false,
              config: f.config || {}
            }
          });
        }
      }

      await prisma.auditLog.create({
        data: {
          username,
          action: 'restore_snapshot',
          entity: 'port',
          entityId: restored.id,
          afterState: restored
        }
      });

      return reply.send({ success: true, restored });
    } else if (snapshot.entityType === 'route') {
      const routeData = data.route || data;
      const restored = await prisma.route.create({
        data: {
          domain: routeData.domain,
          domainRaw: routeData.domainRaw || routeData.domain,
          isCatchAll: routeData.isCatchAll || false,
          portNum: routeData.portNum || null,
          protocol: routeData.protocol || 'HTTP',
          path: routeData.path || '/',
          paths: routeData.paths || ['/'],
          action: routeData.action || 'Proxy',
          targetRaw: routeData.targetRaw || '',
          targetType: routeData.targetType || 'url',
          backendId: routeData.backendId || null,
          notes: routeData.notes || ''
        }
      });

      await prisma.auditLog.create({
        data: {
          username,
          action: 'restore_snapshot',
          entity: 'route',
          entityId: restored.id,
          afterState: restored
        }
      });

      return reply.send({ success: true, restored });
    }

    return reply.status(400).send({ error: `Unsupported entity type: ${snapshot.entityType}` });
  });
}
