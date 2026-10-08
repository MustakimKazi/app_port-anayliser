import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';

export async function configFilesRoutes(fastify: FastifyInstance) {
  // GET /api/config-files
  fastify.get('/config-files', async (request: FastifyRequest, reply: FastifyReply) => {
    const rawFiles = await prisma.configFile.findMany({
      include: {
        routes: {
          select: {
            id: true,
            domain: true,
            path: true,
            portNum: true,
            action: true
          }
        }
      },
      orderBy: [
        { status: 'asc' }, // active first
        { filename: 'asc' }
      ]
    });

    // List payload omits the (potentially large) content; expose a hasContent flag instead
    const files = rawFiles.map(({ content, ...rest }) => ({
      ...rest,
      hasContent: !!content && content.length > 0,
      contentLength: content ? content.length : 0
    }));

    const activeCount = files.filter(f => f.status === 'active').length;
    const backupCount = files.filter(f => f.status === 'backup').length;

    return reply.send({
      files,
      stats: {
        total: files.length,
        activeCount,
        backupCount
      }
    });
  });

  // GET /api/config-files/:id - full detail incl. stored nginx content + attached routes
  fastify.get<{ Params: { id: string } }>('/config-files/:id', async (request, reply) => {
    const { id } = request.params;
    const file = await prisma.configFile.findUnique({
      where: { id },
      include: {
        routes: {
          orderBy: [{ portNum: 'asc' }, { path: 'asc' }]
        }
      }
    });

    if (!file) return reply.status(404).send({ error: 'Config file not found' });
    return reply.send(file);
  });

  // POST /api/config-files
  fastify.post('/config-files', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    const created = await prisma.configFile.create({
      data: {
        filename: body.filename,
        status: body.status || 'active',
        description: body.description || ''
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'create',
        entity: 'config_file',
        entityId: created.id,
        afterState: created
      }
    });

    return reply.status(201).send(created);
  });
  // PATCH /api/config-files/:id
  fastify.patch('/config-files/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const body = request.body as any;

    const existing = await prisma.configFile.findUnique({
      where: { id }
    });
    if (!existing) return reply.status(404).send({ error: 'Config file not found' });

    const updated = await prisma.configFile.update({
      where: { id },
      data: {
        status: body.status !== undefined ? body.status : existing.status,
        description: body.description !== undefined ? body.description : existing.description,
        content: body.content !== undefined ? body.content : existing.content
      }
    });
    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'update',
        entity: 'config_file',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send(updated);
  });

  // DELETE /api/config-files/:id
  fastify.delete('/config-files/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const existing = await prisma.configFile.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Config file not found' });

    await prisma.configFile.delete({ where: { id } });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'delete',
        entity: 'config_file',
        entityId: id,
        beforeState: existing
      }
    });

    return reply.send({ success: true });
  });
}
