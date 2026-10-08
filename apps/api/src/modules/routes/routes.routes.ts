import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import prisma from '../../db/prisma.js';

export function checkAdminRole(request: FastifyRequest, reply: FastifyReply): boolean {
  const user = (request as any).user;
  if (user && user.role === 'viewer') {
    reply.status(403).send({ error: 'Forbidden: Viewer role has read-only access' });
    return false;
  }
  return true;
}

const RouteFilterSchema = z.object({
  domain: z.string().optional(),
  port: z.coerce.number().optional(),
  protocol: z.string().optional(),
  action: z.string().optional(),
  backendHost: z.string().optional(),
  backendPort: z.coerce.number().optional(),
  configFile: z.string().optional(),
  unresolved: z.string().optional(),
  catchAll: z.string().optional(),
  websocket: z.string().optional(),
  rateLimit: z.string().optional(),
  showArchived: z.string().optional(),
  q: z.string().optional(),
  sort: z.string().optional(),
  page: z.coerce.number().int().min(1).max(100_000).default(1),
  limit: z.coerce.number().int().min(1).max(1000).default(100)
});

export async function routesRoutes(fastify: FastifyInstance) {
  // GET /api/routes - Filterable list of routes
  fastify.get('/routes', async (request: FastifyRequest, reply: FastifyReply) => {
    const parse = RouteFilterSchema.safeParse(request.query);
    if (!parse.success) return reply.status(400).send({
        error: 'Invalid request parameters',
        issues: parse.error.issues.map((i) => ({ path: i.path.join('.'), message: i.message }))
      });

    const {
      domain,
      port,
      protocol,
      action,
      backendHost,
      backendPort,
      configFile,
      unresolved,
      catchAll,
      websocket,
      rateLimit,
      showArchived,
      q,
      sort = 'rowNum',
      page,
      limit
    } = parse.data;

    const where: any = {};

    if (showArchived !== 'true') {
      where.archivedAt = null;
    }

    if (domain) {
      where.domain = { contains: domain, mode: 'insensitive' };
    }

    if (port !== undefined) {
      where.portNum = port;
    }

    if (protocol) {
      where.protocol = { equals: protocol, mode: 'insensitive' };
    }

    if (action) {
      where.action = { equals: action, mode: 'insensitive' };
    }

    if (unresolved === 'true') {
      where.targetType = { in: ['upstream', 'variable', 'unknown'] };
    }

    if (catchAll === 'true') {
      where.isCatchAll = true;
    } else if (catchAll === 'false') {
      where.isCatchAll = false;
    }

    if (backendHost || backendPort) {
      where.backend = {
        ...(backendHost ? { host: { contains: backendHost, mode: 'insensitive' } } : {}),
        ...(backendPort ? { port: backendPort } : {})
      };
    }

    if (configFile) {
      where.configFile = {
        filename: { contains: configFile, mode: 'insensitive' }
      };
    }

    if (websocket === 'true') {
      where.flags = {
        path: ['websocket'],
        equals: true
      };
    }

    if (rateLimit === 'true') {
      where.flags = {
        path: ['rateLimit'],
        equals: true
      };
    }

    if (q) {
      where.OR = [
        { domain: { contains: q, mode: 'insensitive' } },
        { path: { contains: q, mode: 'insensitive' } },
        { targetRaw: { contains: q, mode: 'insensitive' } },
        { notes: { contains: q, mode: 'insensitive' } }
      ];
    }

    // Sort
    const isDesc = sort.startsWith('-');
    const sortField = isDesc ? sort.substring(1) : sort;
    const orderBy: any = {};
    if (sortField === 'rowNum') orderBy.rowNum = isDesc ? 'desc' : 'asc';
    else if (sortField === 'domain') orderBy.domain = isDesc ? 'desc' : 'asc';
    else if (sortField === 'port') orderBy.portNum = isDesc ? 'desc' : 'asc';
    else if (sortField === 'action') orderBy.action = isDesc ? 'desc' : 'asc';
    else orderBy.rowNum = 'asc';

    const [total, items] = await Promise.all([
      prisma.route.count({ where }),
      prisma.route.findMany({
        where,
        orderBy,
        skip: (page - 1) * limit,
        take: limit,
        include: {
          port: true,
          backend: {
            include: { server: true }
          },
          configFile: true
        }
      })
    ]);

    return reply.send({
      data: items,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    });
  });

  // GET /api/routes/:id - Single route details
  fastify.get('/routes/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const route = await prisma.route.findUnique({
      where: { id },
      include: {
        port: true,
        backend: { include: { server: true } },
        configFile: true,
        issues: true
      }
    });

    if (!route) return reply.status(404).send({ error: 'Route not found' });
    return reply.send(route);
  });

  // GET /api/routes/:id/impact - Computes impact before archive/delete
  fastify.get('/routes/:id/impact', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const route = await prisma.route.findUnique({
      where: { id },
      include: {
        port: true,
        backend: true,
        issues: { where: { status: { in: ['open', 'acknowledged'] } } }
      }
    });

    if (!route) return reply.status(404).send({ error: 'Route not found' });

    // Check if backend will become orphaned
    let backendOrphaned = false;
    if (route.backendId) {
      const otherRoutes = await prisma.route.count({
        where: { backendId: route.backendId, id: { not: id }, archivedAt: null }
      });
      backendOrphaned = otherRoutes === 0;
    }

    const warningLevel = route.backendId && backendOrphaned ? 'caution' : 'safe';

    return reply.send({
      route,
      backendOrphaned,
      openIssuesCount: route.issues.length,
      warningLevel,
      notice: 'Removing or archiving this route does not stop web servers on the host.'
    });
  });

  // POST /api/routes - Create a route
  fastify.post('/routes', async (request: FastifyRequest, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const body = request.body as any;
    const portNum = body.portNum ? parseInt(body.portNum) : null;

    let portId = body.portId || null;
    if (!portId && portNum) {
      const p = await prisma.port.findFirst({ where: { port: portNum, archivedAt: null } });
      if (p) portId = p.id;
    }

    const created = await prisma.route.create({
      data: {
        domain: body.domain,
        domainRaw: body.domainRaw || body.domain,
        isCatchAll: body.isCatchAll || false,
        portId,
        portNum,
        portRaw: String(portNum || ''),
        protocol: body.protocol || 'HTTP',
        path: body.path || '/',
        paths: body.paths || [body.path || '/'],
        action: body.action || 'Proxy',
        targetRaw: body.targetRaw || '',
        targetType: body.targetType || 'url',
        backendId: body.backendId || null,
        configFileId: body.configFileId || null,
        notes: body.notes || '',
        flags: body.flags || {},
        customValues: body.customValues || {}
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'create',
        entity: 'route',
        entityId: created.id,
        afterState: created
      }
    });

    return reply.status(201).send(created);
  });

  // POST /api/routes/bulk - Bulk add routes (paste or CSV)
  fastify.post('/routes/bulk', async (request: FastifyRequest, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { routesList } = request.body as { routesList: any[] };
    if (!Array.isArray(routesList) || routesList.length === 0) {
      return reply.status(400).send({ error: 'No routes provided in routesList' });
    }

    const username = (request as any).user?.username || 'admin';
    const createdRoutes: any[] = [];

    await prisma.$transaction(async (tx) => {
      for (const item of routesList) {
        if (!item.domain) continue;

        const portNum = item.portNum ? parseInt(item.portNum) : null;
        let portId = item.portId || null;
        if (!portId && portNum) {
          const p = await tx.port.findFirst({ where: { port: portNum, archivedAt: null } });
          if (p) portId = p.id;
        }

        const r = await tx.route.create({
          data: {
            domain: item.domain,
            domainRaw: item.domain,
            path: item.path || '/',
            paths: [item.path || '/'],
            action: item.action || 'Proxy',
            protocol: item.protocol || 'HTTP',
            portId,
            portNum,
            targetRaw: item.targetRaw || '',
            targetType: item.targetType || 'url',
            backendId: item.backendId || null,
            notes: item.notes || ''
          }
        });
        createdRoutes.push(r);
      }

      await tx.auditLog.create({
        data: {
          username,
          action: 'bulk_create',
          entity: 'route',
          afterState: { count: createdRoutes.length }
        }
      });
    });

    return reply.status(201).send({ success: true, count: createdRoutes.length, routes: createdRoutes });
  });

  // PATCH /api/routes/:id - Edit route
  fastify.patch('/routes/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const body = request.body as any;

    const existing = await prisma.route.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Route not found' });

    const updated = await prisma.route.update({
      where: { id },
      data: {
        domain: body.domain !== undefined ? body.domain : existing.domain,
        path: body.path !== undefined ? body.path : existing.path,
        action: body.action !== undefined ? body.action : existing.action,
        targetRaw: body.targetRaw !== undefined ? body.targetRaw : existing.targetRaw,
        targetType: body.targetType !== undefined ? body.targetType : existing.targetType,
        backendId: body.backendId !== undefined ? body.backendId : existing.backendId,
        portId: body.portId !== undefined ? body.portId : existing.portId,
        portNum: body.portNum !== undefined ? (body.portNum ? parseInt(body.portNum) : null) : existing.portNum,
        notes: body.notes !== undefined ? body.notes : existing.notes,
        customValues: body.customValues !== undefined ? body.customValues : existing.customValues
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'update',
        entity: 'route',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send(updated);
  });

  // POST /api/routes/:id/archive - Archive a route
  fastify.post('/routes/:id/archive', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const existing = await prisma.route.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Route not found' });

    const username = (request as any).user?.username || 'admin';
    const now = new Date();

    const updated = await prisma.route.update({
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
        entity: 'route',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send({ success: true, message: `Route ${existing.domain}${existing.path} archived.` });
  });

  // POST /api/routes/:id/restore - Restore an archived route
  fastify.post('/routes/:id/restore', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const existing = await prisma.route.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Route not found' });

    const restored = await prisma.route.update({
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
        entity: 'route',
        entityId: id,
        afterState: restored
      }
    });

    return reply.send({ success: true, route: restored });
  });

  // DELETE /api/routes/:id - Permanently delete route (with snapshot)
  fastify.delete('/routes/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const existing = await prisma.route.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Route not found' });

    const username = (request as any).user?.username || 'admin';

    // Store snapshot
    await prisma.trashSnapshot.create({
      data: {
        entityType: 'route',
        entityId: id,
        entityName: `${existing.domain}${existing.path}`,
        data: existing,
        deletedBy: username
      }
    });

    await prisma.route.delete({ where: { id } });

    await prisma.auditLog.create({
      data: {
        username,
        action: 'delete',
        entity: 'route',
        entityId: id,
        beforeState: existing
      }
    });

    return reply.send({ success: true });
  });
}
