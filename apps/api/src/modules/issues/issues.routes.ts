import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import prisma from '../../db/prisma.js';

const IssueFilterSchema = z.object({
  priority: z.string().optional(),
  status: z.string().optional(),
  source: z.string().optional(),
  relatedPortId: z.string().optional(),
  q: z.string().optional()
});

// Validated body: an unvalidated body used to reach Prisma directly and leak
// the raw PrismaClientValidationError (stack + file paths) to the client
const IssueCreateSchema = z.object({
  title: z.string().trim().min(1).max(500),
  priority: z.string().max(20).optional(),
  observed: z.string().max(20_000).optional(),
  recommendation: z.string().max(20_000).optional(),
  relatedPortId: z.string().nullable().optional(),
  relatedRouteId: z.string().nullable().optional(),
  assignee: z.string().max(100).nullable().optional()
});

export async function issuesRoutes(fastify: FastifyInstance) {
  // GET /api/issues
  fastify.get('/issues', async (request: FastifyRequest, reply: FastifyReply) => {
    const parse = IssueFilterSchema.safeParse(request.query);
    if (!parse.success) return reply.status(400).send({
        error: 'Invalid request parameters',
        issues: parse.error.issues.map((i) => ({ path: i.path.join('.'), message: i.message }))
      });

    const { priority, status, source, relatedPortId, q } = parse.data;
    const where: any = {};

    if (priority) where.priority = priority;
    if (status) where.status = status;
    if (source) where.source = source;
    if (relatedPortId) where.relatedPortId = relatedPortId;

    if (q) {
      where.OR = [
        { title: { contains: q, mode: 'insensitive' } },
        { observed: { contains: q, mode: 'insensitive' } },
        { recommendation: { contains: q, mode: 'insensitive' } }
      ];
    }

    const issues = await prisma.issue.findMany({
      where,
      orderBy: [
        { status: 'asc' }, // open first
        { priority: 'desc' },
        { issueNum: 'asc' }
      ],
      include: {
        relatedPort: true,
        relatedRoute: true
      }
    });

    return reply.send(issues);
  });

  // POST /api/issues
  fastify.post('/issues', async (request: FastifyRequest, reply: FastifyReply) => {
    const parse = IssueCreateSchema.safeParse(request.body);
    if (!parse.success) {
      return reply.status(400).send({
        error: 'Invalid issue payload',
        issues: parse.error.issues.map((i) => ({ path: i.path.join('.'), message: i.message }))
      });
    }
    const body = parse.data;
    const created = await prisma.issue.create({
      data: {
        title: body.title,
        priority: body.priority || 'Medium',
        observed: body.observed || '',
        recommendation: body.recommendation || '',
        status: 'open',
        source: 'manual',
        relatedPortId: body.relatedPortId || null,
        relatedRouteId: body.relatedRouteId || null,
        assignee: body.assignee || null,
        comments: []
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'create',
        entity: 'issue',
        entityId: created.id,
        afterState: created
      }
    });

    return reply.status(201).send(created);
  });

  // PATCH /api/issues/:id - status workflow (open -> acknowledged -> resolved / ignored), assignee, comments
  fastify.patch('/issues/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const body = request.body as any;

    const existing = await prisma.issue.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Issue not found' });

    let comments = (existing.comments as any[]) || [];
    if (body.newComment) {
      comments = [
        ...comments,
        {
          author: (request as any).user?.username || 'admin',
          text: body.newComment,
          at: new Date()
        }
      ];
    }

    const resolvedAt =
      body.status === 'resolved' && existing.status !== 'resolved'
        ? new Date()
        : (body.status && body.status !== 'resolved' ? null : existing.resolvedAt);

    const updated = await prisma.issue.update({
      where: { id },
      data: {
        status: body.status !== undefined ? body.status : existing.status,
        priority: body.priority !== undefined ? body.priority : existing.priority,
        assignee: body.assignee !== undefined ? body.assignee : existing.assignee,
        recommendation: body.recommendation !== undefined ? body.recommendation : existing.recommendation,
        comments,
        resolvedAt
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'update',
        entity: 'issue',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send(updated);
  });

  // DELETE /api/issues/:id
  fastify.delete('/issues/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const existing = await prisma.issue.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Issue not found' });

    await prisma.issue.delete({ where: { id } });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'delete',
        entity: 'issue',
        entityId: id,
        beforeState: existing
      }
    });

    return reply.send({ success: true });
  });
}
