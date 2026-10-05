import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';

export async function auditRoutes(fastify: FastifyInstance) {
  // GET /api/audit-log
  fastify.get('/audit-log', async (request: FastifyRequest, reply: FastifyReply) => {
    const logs = await prisma.auditLog.findMany({
      orderBy: { createdAt: 'desc' },
      take: 100
    });
    return reply.send(logs);
  });
}
