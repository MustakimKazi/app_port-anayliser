import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';

export async function serversRoutes(fastify: FastifyInstance) {
  // GET /api/servers
  fastify.get('/servers', async (request: FastifyRequest, reply: FastifyReply) => {
    const servers = await prisma.server.findMany({
      include: {
        backends: {
          include: {
            routes: {
              select: { id: true, domain: true }
            }
          }
        }
      },
      orderBy: { name: 'asc' }
    });

    return reply.send(servers);
  });

  // POST /api/servers
  fastify.post('/servers', async (request: FastifyRequest, reply: FastifyReply) => {
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

  // DELETE /api/servers/:id
  fastify.delete('/servers/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const existing = await prisma.server.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Server not found' });

    await prisma.server.delete({ where: { id } });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'delete',
        entity: 'server',
        entityId: id,
        beforeState: existing
      }
    });

    return reply.send({ success: true });
  });
}
