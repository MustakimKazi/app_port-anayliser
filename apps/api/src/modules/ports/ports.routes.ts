import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import prisma from '../../db/prisma.js';
import { ScannerService } from '../../scanner/scanner-service.js';

const PortFilterSchema = z.object({
  status: z.string().optional(),
  layer: z.string().optional(),
  protocol: z.string().optional(),
  bind: z.enum(['public', 'local']).optional(),
  hasIssues: z.string().optional(),
  issuePriority: z.string().optional(),
  portMin: z.coerce.number().optional(),
  portMax: z.coerce.number().optional(),
  q: z.string().optional(),
  process: z.string().optional(),
  tag: z.string().optional(),
  documented: z.string().optional(),
  shared: z.string().optional(),
  sort: z.string().optional(),
  page: z.coerce.number().default(1),
  limit: z.coerce.number().default(50)
});

export async function portsRoutes(fastify: FastifyInstance, opts: { scanner: ScannerService }) {
  // GET /api/ports - reading from v_port_overview with comprehensive filters
  fastify.get('/ports', async (request: FastifyRequest, reply: FastifyReply) => {
    const parse = PortFilterSchema.safeParse(request.query);
    if (!parse.success) {
      return reply.status(400).send({ error: parse.error });
    }

    const {
      status,
      layer,
      protocol,
      bind,
      hasIssues,
      issuePriority,
      portMin,
      portMax,
      q,
      process,
      tag,
      documented,
      shared,
      sort = 'port',
      page,
      limit
    } = parse.data;

    // Build parameterized raw query on v_port_overview
    const conditions: string[] = ['1=1'];
    const params: any[] = [];
    let pIdx = 1;

    if (status) {
      conditions.push(`status = $${pIdx++}`);
      params.push(status.toLowerCase());
    }

    if (layer) {
      conditions.push(`LOWER(layer) = $${pIdx++}`);
      params.push(layer.toLowerCase());
    }

    if (protocol) {
      conditions.push(`UPPER(protocol) = $${pIdx++}`);
      params.push(protocol.toUpperCase());
    }

    if (bind) {
      conditions.push(`"isPublic" = $${pIdx++}`);
      params.push(bind === 'public');
    }

    if (hasIssues === 'true') {
      conditions.push(`"openIssueCount" > 0`);
    } else if (hasIssues === 'false') {
      conditions.push(`"openIssueCount" = 0`);
    }

    if (issuePriority === 'High') {
      conditions.push(`"hasHighIssue" = true`);
    }

    if (portMin !== undefined) {
      conditions.push(`port >= $${pIdx++}`);
      params.push(portMin);
    }

    if (portMax !== undefined) {
      conditions.push(`port <= $${pIdx++}`);
      params.push(portMax);
    }

    if (process) {
      conditions.push(`LOWER("processName") LIKE $${pIdx++}`);
      params.push(`%${process.toLowerCase()}%`);
    }

    if (tag) {
      conditions.push(`$${pIdx++} = ANY(tags)`);
      params.push(tag);
    }

    if (shared === 'true') {
      conditions.push(`"routeCount" > 1`);
    }

    if (documented === 'false') {
      conditions.push(`"isExpected" = false`);
    } else if (documented === 'true') {
      conditions.push(`"isExpected" = true`);
    }

    if (q) {
      const qPattern = `%${q.toLowerCase()}%`;
      conditions.push(`(
        CAST(port AS TEXT) LIKE $${pIdx} OR
        LOWER(purpose) LIKE $${pIdx} OR
        LOWER(notes) LIKE $${pIdx} OR
        LOWER("domainsList") LIKE $${pIdx} OR
        LOWER("processName") LIKE $${pIdx}
      )`);
      params.push(qPattern);
      pIdx++;
    }

    // Dynamic sort
    let orderClause = 'ORDER BY port ASC';
    const isDesc = sort.startsWith('-');
    const sortField = isDesc ? sort.substring(1) : sort;

    const allowedSortFields: Record<string, string> = {
      port: 'port',
      status: 'status',
      layer: 'layer',
      protocol: 'protocol',
      routeCount: '"routeCount"',
      backendCount: '"backendCount"',
      openIssueCount: '"openIssueCount"',
      latencyMs: '"latencyMs"',
      lastCheckedAt: '"lastCheckedAt"'
    };

    if (allowedSortFields[sortField]) {
      orderClause = `ORDER BY ${allowedSortFields[sortField]} ${isDesc ? 'DESC' : 'ASC'}`;
    }

    const whereClause = conditions.join(' AND ');

    // Count query
    const countSql = `SELECT COUNT(*)::integer as total FROM v_port_overview WHERE ${whereClause}`;
    const countRes: any = await prisma.$queryRawUnsafe(countSql, ...params);
    const total = countRes[0]?.total || 0;

    // Data query with pagination
    const offset = (page - 1) * limit;
    const dataSql = `
      SELECT * FROM v_port_overview 
      WHERE ${whereClause} 
      ${orderClause} 
      LIMIT ${limit} OFFSET ${offset}
    `;
    const rows: any = await prisma.$queryRawUnsafe(dataSql, ...params);

    return reply.send({
      data: rows,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    });
  });

  // GET /api/ports/:id - Full details for row drawer
  fastify.get('/ports/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;

    const port = await prisma.port.findUnique({
      where: { id },
      include: {
        routes: {
          include: {
            backend: true,
            configFile: true
          }
        },
        issues: true
      }
    });

    if (!port) {
      return reply.status(404).send({ error: 'Port not found' });
    }

    // Recent 50 checks
    const recentChecks = await prisma.portCheck.findMany({
      where: { targetId: id },
      orderBy: { checkedAt: 'desc' },
      take: 50
    });

    // 24h Uptime bar (24 blocks of 1 hour)
    const now = new Date();
    const uptimeBlocks: Array<{ hour: number; label: string; status: 'up' | 'down' | 'slow' | 'unknown' }> = [];

    for (let h = 23; h >= 0; h--) {
      const blockStart = new Date(now.getTime() - (h + 1) * 3600 * 1000);
      const blockEnd = new Date(now.getTime() - h * 3600 * 1000);

      const checksInHour = recentChecks.filter(
        c => new Date(c.checkedAt) >= blockStart && new Date(c.checkedAt) < blockEnd
      );

      let status: 'up' | 'down' | 'slow' | 'unknown' = 'unknown';
      if (checksInHour.length > 0) {
        if (checksInHour.some(c => c.status === 'down')) status = 'down';
        else if (checksInHour.some(c => c.status === 'slow')) status = 'slow';
        else if (checksInHour.some(c => c.status === 'up')) status = 'up';
      } else if (port.status !== 'unknown') {
        status = port.status as any;
      }

      uptimeBlocks.push({
        hour: blockStart.getHours(),
        label: `${blockStart.getHours()}:00`,
        status
      });
    }

    // Audit trail
    const auditLogs = await prisma.auditLog.findMany({
      where: { entity: 'port', entityId: id },
      orderBy: { createdAt: 'desc' },
      take: 20
    });

    return reply.send({
      port,
      routes: port.routes,
      issues: port.issues,
      uptimeBlocks,
      recentChecks,
      auditLogs
    });
  });

  // GET /api/ports/:id/history - Uptime statistics
  fastify.get('/ports/:id/history', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;

    const checks = await prisma.portCheck.findMany({
      where: { targetId: id },
      orderBy: { checkedAt: 'desc' },
      take: 200
    });

    const total = checks.length;
    const upCount = checks.filter(c => c.status === 'up' || c.status === 'slow').length;
    const uptimePercent = total > 0 ? Math.round((upCount / total) * 1000) / 10 : 100;

    return reply.send({
      checks,
      stats: {
        totalChecks: total,
        upCount,
        downCount: total - upCount,
        uptimePercent
      }
    });
  });

  // POST /api/ports - Create port
  fastify.post('/ports', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    const created = await prisma.port.create({
      data: {
        port: parseInt(body.port),
        layer: body.layer || 'http',
        protocol: body.protocol || 'HTTP',
        purpose: body.purpose || '',
        notes: body.notes || '',
        isPublic: body.isPublic !== undefined ? body.isPublic : true,
        tags: body.tags || [],
        customValues: body.customValues || {}
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'create',
        entity: 'port',
        entityId: created.id,
        afterState: created
      }
    });

    return reply.status(201).send(created);
  });

  // PATCH /api/ports/:id - Update port (supports inline edit for notes, tags, purpose, etc.)
  fastify.patch('/ports/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const body = request.body as any;

    const existing = await prisma.port.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Port not found' });

    const updated = await prisma.port.update({
      where: { id },
      data: {
        purpose: body.purpose !== undefined ? body.purpose : existing.purpose,
        notes: body.notes !== undefined ? body.notes : existing.notes,
        isPublic: body.isPublic !== undefined ? body.isPublic : existing.isPublic,
        isExpected: body.isExpected !== undefined ? body.isExpected : existing.isExpected,
        tags: body.tags !== undefined ? body.tags : existing.tags,
        customValues: body.customValues !== undefined ? body.customValues : existing.customValues
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'update',
        entity: 'port',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send(updated);
  });

  // DELETE /api/ports/:id
  fastify.delete('/ports/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const existing = await prisma.port.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Port not found' });

    await prisma.port.delete({ where: { id } });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'delete',
        entity: 'port',
        entityId: id,
        beforeState: existing
      }
    });

    return reply.send({ success: true });
  });

  // POST /api/ports/bulk - Bulk operations
  fastify.post('/ports/bulk', async (request: FastifyRequest, reply: FastifyReply) => {
    const { ids, action, payload } = request.body as { ids: string[]; action: string; payload?: any };
    if (!ids || !ids.length) return reply.status(400).send({ error: 'No port IDs provided' });

    if (action === 'addTag' && payload?.tag) {
      for (const id of ids) {
        const p = await prisma.port.findUnique({ where: { id } });
        if (p && !p.tags.includes(payload.tag)) {
          await prisma.port.update({
            where: { id },
            data: { tags: [...p.tags, payload.tag] }
          });
        }
      }
    } else if (action === 'markExpected') {
      await prisma.port.updateMany({
        where: { id: { in: ids } },
        data: { isExpected: true }
      });
    } else if (action === 'checkNow') {
      for (const id of ids) {
        await opts.scanner.checkTarget('port', id);
      }
    } else if (action === 'ackIssues') {
      await prisma.issue.updateMany({
        where: { relatedPortId: { in: ids }, status: 'open' },
        data: { status: 'acknowledged' }
      });
    }

    return reply.send({ success: true, count: ids.length });
  });
}
