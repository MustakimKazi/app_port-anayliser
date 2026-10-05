import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';

export async function savedViewsRoutes(fastify: FastifyInstance) {
  // GET /api/saved-views
  fastify.get('/saved-views', async (request: FastifyRequest, reply: FastifyReply) => {
    const { page } = request.query as { page?: string };
    const where: any = {};
    if (page) where.page = page;

    const views = await prisma.savedView.findMany({
      where,
      orderBy: { createdAt: 'desc' }
    });
    return reply.send(views);
  });

  // POST /api/saved-views
  fastify.post('/saved-views', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    const view = await prisma.savedView.create({
      data: {
        name: body.name,
        page: body.page,
        filterJson: body.filterJson,
        isShared: body.isShared !== undefined ? body.isShared : true
      }
    });
    return reply.status(201).send(view);
  });

  // DELETE /api/saved-views/:id
  fastify.delete('/saved-views/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    await prisma.savedView.delete({ where: { id } });
    return reply.send({ success: true });
  });
}
