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

export async function serversRoutes(fastify: FastifyInstance) {
  // GET /api/servers
  fastify.get('/servers', async (request: FastifyRequest, reply: FastifyReply) => {
    const showArchived = (request.query as any)?.showArchived === 'true';

    const where: any = {};
    if (!showArchived) {
      where.archivedAt = null;
    }

    const servers = await prisma.server.findMany({
      where,
      include: {
        backends: {
          where: { archivedAt: null },
          include: {
            routes: {
              where: { archivedAt: null },
              select: { id: true, domain: true }
            }
          }
        },
        ports: {
          where: { archivedAt: null },
          select: { id: true, port: true, purpose: true, lifecycle: true }
        }
      },
      orderBy: { name: 'asc' }
    });

    return reply.send(servers);
  });

  // GET /api/servers/:id/impact - Computes impact before archive/delete
  fastify.get('/servers/:id/impact', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const server = await prisma.server.findUnique({
      where: { id },
      include: {
        ports: { where: { archivedAt: null } },
        backends: { where: { archivedAt: null } }
      }
    });

    if (!server) return reply.status(404).send({ error: 'Server not found' });

    const activePortsCount = server.ports.length;
    const activeBackendsCount = server.backends.length;
    const isBlocked = activePortsCount > 0 || activeBackendsCount > 0;

    return reply.send({
      server,
      activePorts: server.ports,
      activePortsCount,
      activeBackends: server.backends,
      activeBackendsCount,
      isBlocked,
      message: isBlocked
        ? `Server cannot be archived or deleted while ${activePortsCount} active ports and ${activeBackendsCount} backends are linked to it.`
        : 'Server has no active ports or backends and can be safely archived.'
    });
  });

  // POST /api/servers - Create server
  fastify.post('/servers', async (request: FastifyRequest, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const body = request.body as any;
    const created = await prisma.server.create({
      data: {
        name: body.name,
        host: body.host,
        kind: body.kind || 'backend',
        groupLabel: body.groupLabel || null,
        notes: body.notes || '',
        tags: body.tags || []
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'create',
        entity: 'server',
        entityId: created.id,
        afterState: created
      }
    });

    return reply.status(201).send(created);
  });

  // PATCH /api/servers/:id - Supports renaming and tag/note edits
  fastify.patch('/servers/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const body = request.body as any;

    const existing = await prisma.server.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Server not found' });

    const updated = await prisma.server.update({
      where: { id },
      data: {
        name: body.name !== undefined ? body.name : existing.name,
        host: body.host !== undefined ? body.host : existing.host,
        kind: body.kind !== undefined ? body.kind : existing.kind,
        groupLabel: body.groupLabel !== undefined ? body.groupLabel : existing.groupLabel,
        notes: body.notes !== undefined ? body.notes : existing.notes,
        tags: body.tags !== undefined ? body.tags : existing.tags
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'update',
        entity: 'server',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send(updated);
  });

  // POST /api/servers/:id/archive - Archive server (blocked while active ports or backends use it)
  fastify.post('/servers/:id/archive', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const existing = await prisma.server.findUnique({
      where: { id },
      include: {
        ports: { where: { archivedAt: null } },
        backends: { where: { archivedAt: null } }
      }
    });

    if (!existing) return reply.status(404).send({ error: 'Server not found' });

    if (existing.ports.length > 0 || existing.backends.length > 0) {
      return reply.status(400).send({
        error: `Cannot archive server: ${existing.ports.length} active ports and ${existing.backends.length} backends are linked to it.`,
        activePorts: existing.ports,
        activeBackends: existing.backends
      });
    }

    const username = (request as any).user?.username || 'admin';
    const now = new Date();

    const updated = await prisma.server.update({
      where: { id },
      data: {
        archivedAt: now,
        archivedBy: username
      }
    });

    await prisma.auditLog.create({
      data: {
        username,
        action: 'archive',
        entity: 'server',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send({ success: true, message: `Server ${existing.name} archived.` });
  });

  // POST /api/servers/:id/restore - Restore server
  fastify.post('/servers/:id/restore', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const existing = await prisma.server.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Server not found' });

    const restored = await prisma.server.update({
      where: { id },
      data: {
        archivedAt: null,
        archivedBy: null
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'restore',
        entity: 'server',
        entityId: id,
        afterState: restored
      }
    });

    return reply.send({ success: true, server: restored });
  });

  // DELETE /api/servers/:id - Permanently delete server (blocked while active ports or backends use it)
  fastify.delete('/servers/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const existing = await prisma.server.findUnique({
      where: { id },
      include: {
        ports: { where: { archivedAt: null } },
        backends: { where: { archivedAt: null } }
      }
    });

    if (!existing) return reply.status(404).send({ error: 'Server not found' });

    if (existing.ports.length > 0 || existing.backends.length > 0) {
      return reply.status(400).send({
        error: `Cannot delete server: ${existing.ports.length} active ports and ${existing.backends.length} active backends are linked to it.`,
        activePorts: existing.ports,
        activeBackends: existing.backends
      });
    }

    const username = (request as any).user?.username || 'admin';

    // Store snapshot
    await prisma.trashSnapshot.create({
      data: {
        entityType: 'server',
        entityId: id,
        entityName: existing.name,
        data: existing,
        deletedBy: username
      }
    });

    await prisma.server.delete({ where: { id } });

    await prisma.auditLog.create({
      data: {
        username,
        action: 'delete',
        entity: 'server',
        entityId: id,
        beforeState: existing
      }
    });

    return reply.send({ success: true });
  });
}
