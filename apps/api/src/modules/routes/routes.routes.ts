import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import prisma from '../../db/prisma.js';

const RouteFilterSchema = z.object({
  domain: z.string().optional(),
  port: z.coerce.number().optional(),
  protocol: z.string().optional(),
  action: z.string().optional(),
  backendHost: z.string().optional(),
  backendPort: z.coerce.number().optional(),
  configFile: z.string().optional(),
  unresolved: z.string().optional(), // 'true' for upstream, variable, unknown
  catchAll: z.string().optional(),
  websocket: z.string().optional(),
  rateLimit: z.string().optional(),
  q: z.string().optional(),
  sort: z.string().optional(),
  page: z.coerce.number().default(1),
  limit: z.coerce.number().default(100)
});

export async function routesRoutes(fastify: FastifyInstance) {
  // GET /api/routes - filterable list of routes
  fastify.get('/routes', async (request: FastifyRequest, reply: FastifyReply) => {
    const parse = RouteFilterSchema.safeParse(request.query);
    if (!parse.success) return reply.status(400).send({ error: parse.error });

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
      q,
      sort = 'rowNum',
      page,
      limit
    } = parse.data;

    const where: any = {};

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

  // GET /api/routes/:id - Detail view with nginx config generator
  fastify.get('/routes/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const route = await prisma.route.findUnique({
      where: { id },
      include: {
        port: true,
        backend: { include: { server: true } },
        configFile: true
      }
    });

    if (!route) return reply.status(404).send({ error: 'Route not found' });

    // Generate Nginx snippet preview
    let nginxSnippet = `# Server block: ${route.domain}\n`;
    nginxSnippet += `server {\n`;
    nginxSnippet += `    listen ${route.portNum || 80}${route.protocol === 'HTTPS' ? ' ssl' : ''};\n`;
    nginxSnippet += `    server_name ${route.isCatchAll ? '_' : route.domain};\n\n`;
    nginxSnippet += `    location ${route.path} {\n`;

    if (route.action === 'Proxy') {
      nginxSnippet += `        proxy_pass ${route.targetRaw || 'http://127.0.0.1:8080'};\n`;
      nginxSnippet += `        proxy_set_header Host $host;\n`;
      nginxSnippet += `        proxy_set_header X-Real-IP $remote_addr;\n`;
      if (route.flags && (route.flags as any).websocket) {
        nginxSnippet += `        proxy_http_version 1.1;\n`;
        nginxSnippet += `        proxy_set_header Upgrade $http_upgrade;\n`;
        nginxSnippet += `        proxy_set_header Connection "upgrade";\n`;
      }
    } else if (route.action === 'Static') {
      nginxSnippet += `        root ${route.staticRoot || '/var/www/html'};\n`;
      nginxSnippet += `        try_files $uri $uri/ =404;\n`;
    } else if (route.action === 'Redirect') {
      nginxSnippet += `        return ${route.redirectCode || 301} ${route.targetRaw};\n`;
    } else if (route.action === 'Status') {
      nginxSnippet += `        stub_status;\n`;
      nginxSnippet += `        allow 127.0.0.1;\n`;
      nginxSnippet += `        deny all;\n`;
    }
    nginxSnippet += `    }\n`;
    nginxSnippet += `}\n`;

    return reply.send({
      route,
      nginxSnippet
    });
  });

  // POST /api/routes
  fastify.post('/routes', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    const created = await prisma.route.create({
      data: {
        domain: body.domain,
        domainRaw: body.domain,
        isCatchAll: body.isCatchAll || false,
        portNum: body.portNum ? parseInt(body.portNum) : null,
        portRaw: String(body.portNum || ''),
        protocol: body.protocol || 'HTTP',
        path: body.path || '/',
        paths: [body.path || '/'],
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

  // PATCH /api/routes/:id
  fastify.patch('/routes/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
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

  // DELETE /api/routes/:id
  fastify.delete('/routes/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const existing = await prisma.route.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Route not found' });

    await prisma.route.delete({ where: { id } });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'delete',
        entity: 'route',
        entityId: id,
        beforeState: existing
      }
    });

    return reply.send({ success: true });
  });
}
