import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';

function checkAdminRole(request: FastifyRequest, reply: FastifyReply): boolean {
  const role = (request as any).user?.role;
  if (role !== 'admin') {
    reply.status(403).send({ error: 'Admin role required' });
    return false;
  }
  return true;
}

export async function domainsRoutes(fastify: FastifyInstance) {
  // GET /api/domains - Aggregate all domains from active routes
  fastify.get('/domains', async (request: FastifyRequest, reply: FastifyReply) => {
    const showArchived = (request.query as any)?.showArchived === 'true';

    const routes = await prisma.route.findMany({
      where: showArchived ? { archivedAt: { not: null } } : { archivedAt: null },
      select: {
        id: true,
        domain: true,
        path: true,
        action: true,
        portNum: true,
        portId: true,
        backendId: true,
        configFileId: true,
        isCatchAll: true,
        archivedAt: true,
        updatedAt: true,
        backend: { select: { host: true, port: true } },
        configFile: { select: { filename: true } },
        port: { select: { purpose: true, protocol: true } }
      },
      orderBy: { domain: 'asc' }
    });

    const map = new Map<string, any>();
    for (const r of routes) {
      let entry = map.get(r.domain);
      if (!entry) {
        entry = {
          domain: r.domain,
          routeCount: 0,
          ports: new Set<number | null>(),
          backends: new Map<string, { host: string; port: number; count: number }>(),
          configFiles: new Map<string, { id: string; filename: string }>(),
          actions: {} as Record<string, number>,
          catchAll: 0,
          archived: r.archivedAt !== null,
          lastUpdated: r.updatedAt
        };
        map.set(r.domain, entry);
      }
      entry.routeCount += 1;
      if (r.portNum) entry.ports.add(r.portNum);
      if (r.backend) {
        const key = `${r.backend.host}:${r.backend.port}`;
        const prev = entry.backends.get(key);
        if (prev) prev.count += 1;
        else entry.backends.set(key, { host: r.backend.host, port: r.backend.port, count: 1 });
      }
      if (r.configFile) entry.configFiles.set(r.configFile.id, r.configFile);
      entry.actions[r.action] = (entry.actions[r.action] || 0) + 1;
      if (r.isCatchAll) entry.catchAll += 1;
      if (r.updatedAt > entry.lastUpdated) entry.lastUpdated = r.updatedAt;
    }

    const domains = Array.from(map.values())
      .map((e) => ({
        ...e,
        ports: Array.from(e.ports).sort((a, b) => (a || 0) - (b || 0)),
        backends: Array.from(e.backends.values()),
        configFiles: Array.from(e.configFiles.values())
      }))
      .sort((a, b) => a.domain.localeCompare(b.domain));

    return reply.send({ domains, count: domains.length });
  });

  // GET /api/domains/:domain - Full detail for one domain
  fastify.get('/domains/:domain', async (request: FastifyRequest<{ Params: { domain: string } }>, reply: FastifyReply) => {
    const { domain } = request.params;
    const showArchived = (request.query as any)?.showArchived === 'true';

    const routes = await prisma.route.findMany({
      where: { domain, ...(showArchived ? {} : { archivedAt: null }) },
      include: {
        backend: true,
        port: true,
        configFile: { select: { id: true, filename: true } },
        issues: { where: { status: { not: 'Resolved' } }, select: { id: true, priority: true, title: true, status: true } }
      },
      orderBy: [{ path: 'asc' }]
    });

    if (routes.length === 0) {
      return reply.status(404).send({ error: 'Domain not found' });
    }

    const ports = new Map<number | string, any>();
    for (const r of routes) {
      const key = r.portNum ?? 'none';
      if (!ports.has(key)) {
        ports.set(key, {
          portNum: r.portNum,
          portId: r.portId,
          purpose: r.port?.purpose || null,
          protocol: r.protocol,
          routeCount: 0
        });
      }
      ports.get(key).routeCount += 1;
    }

    const backends = new Map<string, any>();
    for (const r of routes) {
      if (!r.backend) continue;
      const key = r.backend.id;
      if (!backends.has(key)) {
        backends.set(key, { id: r.backend.id, host: r.backend.host, port: r.backend.port, status: r.backend.status, routeCount: 0 });
      }
      backends.get(key).routeCount += 1;
    }

    const configFiles = new Map<string, any>();
    for (const r of routes) {
      if (!r.configFile) continue;
      configFiles.set(r.configFile.id, r.configFile);
    }

    const openIssues = routes.flatMap((r) => r.issues.map((i) => ({ ...i, routeId: r.id, path: r.path })));

    return reply.send({
      domain,
      routes,
      ports: Array.from(ports.values()),
      backends: Array.from(backends.values()),
      configFiles: Array.from(configFiles.values()),
      openIssues,
      counts: {
        routes: routes.length,
        ports: ports.size,
        backends: backends.size,
        openIssues: openIssues.length
      }
    });
  });

  // GET /api/domains/:domain/impact - What happens if this domain is removed
  fastify.get('/domains/:domain/impact', async (request: FastifyRequest<{ Params: { domain: string } }>, reply: FastifyReply) => {
    const { domain } = request.params;

    const routes = await prisma.route.findMany({
      where: { domain, archivedAt: null },
      include: {
        backend: { select: { id: true, host: true, port: true } },
        port: { select: { id: true, port: true, purpose: true } },
        configFile: { select: { id: true, filename: true } },
        issues: { where: { status: { not: 'Resolved' } }, select: { id: true, title: true, priority: true } }
      }
    });

    if (routes.length === 0) {
      return reply.status(404).send({ error: 'Domain not found' });
    }

    const ports = Array.from(
      new Map(routes.filter((r) => r.port).map((r) => [r.port!.id, r.port])).values()
    );
    const backends = Array.from(
      new Map(routes.filter((r) => r.backend).map((r) => [r.backend!.id, r.backend])).values()
    );
    const configFiles = Array.from(
      new Map(routes.filter((r) => r.configFile).map((r) => [r.configFile!.id, r.configFile])).values()
    );
    const openIssues = routes.flatMap((r) => r.issues.map((i) => ({ ...i, routeId: r.id, path: r.path })));

    return reply.send({
      domain,
      routesCount: routes.length,
      routes: routes.map((r) => ({ id: r.id, path: r.path, action: r.action, portNum: r.portNum, targetType: r.targetType })),
      ports,
      backends,
      configFiles,
      openIssues,
      warningLevel: ports.length > 0 || backends.length > 0 || configFiles.length > 0 ? 'caution' : 'safe',
      notice:
        'Removing this domain deletes its routes. Ports, backends, and config files are shared with other domains and are NOT deleted.'
    });
  });

  // POST /api/domains/:domain/archive - Archive every active route for the domain
  fastify.post('/domains/:domain/archive', async (request: FastifyRequest<{ Params: { domain: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { domain } = request.params;
    const active = await prisma.route.findMany({ where: { domain, archivedAt: null } });
    if (active.length === 0) {
      return reply.status(404).send({ error: 'Domain not found (no active routes)' });
    }

    const username = (request as any).user?.username || 'admin';
    const now = new Date();

    await prisma.$transaction(async (tx) => {
      await tx.route.updateMany({
        where: { domain, archivedAt: null },
        data: { archivedAt: now, archivedBy: username }
      });
      await tx.auditLog.create({
        data: {
          username,
          action: 'archive',
          entity: 'domain',
          entityId: domain,
          beforeState: { activeRoutes: active.length },
          afterState: { archivedRoutes: active.length }
        }
      });
    });

    return reply.send({ success: true, message: `Domain ${domain} archived (${active.length} routes).`, archived: active.length });
  });

  // POST /api/domains/:domain/restore - Restore archived routes for the domain
  fastify.post('/domains/:domain/restore', async (request: FastifyRequest<{ Params: { domain: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { domain } = request.params;
    const archived = await prisma.route.findMany({ where: { domain, archivedAt: { not: null } } });
    if (archived.length === 0) {
      return reply.status(404).send({ error: 'Domain not found (no archived routes)' });
    }

    const username = (request as any).user?.username || 'admin';

    await prisma.$transaction(async (tx) => {
      await tx.route.updateMany({
        where: { domain, archivedAt: { not: null } },
        data: { archivedAt: null, archivedBy: null }
      });
      await tx.auditLog.create({
        data: {
          username,
          action: 'restore',
          entity: 'domain',
          entityId: domain,
          afterState: { restoredRoutes: archived.length }
        }
      });
    });

    return reply.send({ success: true, message: `Domain ${domain} restored (${archived.length} routes).`, restored: archived.length });
  });

  // DELETE /api/domains/:domain - Permanently delete every route for the domain (with trash snapshots)
  fastify.delete('/domains/:domain', async (request: FastifyRequest<{ Params: { domain: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { domain } = request.params;
    const confirm = (request.query as any)?.confirm;
    if (confirm !== domain) {
      return reply.status(400).send({ error: 'Confirmation mismatch: pass ?confirm=<domain> to delete' });
    }

    const routes = await prisma.route.findMany({ where: { domain } });
    if (routes.length === 0) {
      return reply.status(404).send({ error: 'Domain not found' });
    }

    const username = (request as any).user?.username || 'admin';

    await prisma.$transaction(async (tx) => {
      for (const r of routes) {
        await tx.trashSnapshot.create({
          data: {
            entityType: 'route',
            entityId: r.id,
            entityName: `${r.domain}${r.path}`,
            data: r as any,
            deletedBy: username
          }
        });
      }
      await tx.route.deleteMany({ where: { domain } });
      await tx.auditLog.create({
        data: {
          username,
          action: 'delete',
          entity: 'domain',
          entityId: domain,
          beforeState: { routes: routes.map((r) => ({ id: r.id, path: r.path, portNum: r.portNum })) },
          afterState: { deletedRoutes: routes.length }
        }
      });
    });

    return reply.send({ success: true, message: `Domain ${domain} deleted (${routes.length} routes).`, deleted: routes.length });
  });
}
