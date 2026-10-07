import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';
import { ScannerService } from '../../scanner/scanner-service.js';

export function checkAdminRole(request: FastifyRequest, reply: FastifyReply): boolean {
  const user = (request as any).user;
  if (user && user.role === 'viewer') {
    reply.status(403).send({ error: 'Forbidden: Viewer role has read-only access' });
    return false;
  }
  return true;
}

export async function backendsRoutes(fastify: FastifyInstance, opts: { scanner: ScannerService }) {
  // GET /api/backends
  fastify.get('/backends', async (request: FastifyRequest, reply: FastifyReply) => {
    const showArchived = (request.query as any)?.showArchived === 'true';

    const where: any = {};
    if (!showArchived) {
      where.archivedAt = null;
    }

    const backends = await prisma.backend.findMany({
      where,
      include: {
        server: true,
        routes: {
          where: { archivedAt: null },
          select: { id: true, domain: true, path: true, action: true }
        }
      },
      orderBy: [{ host: 'asc' }, { port: 'asc' }]
    });

    return reply.send(backends);
  });

  // GET /api/topology - Graph nodes and edges for React Flow + Blast Radius analysis
  fastify.get('/topology', async (request: FastifyRequest, reply: FastifyReply) => {
    const [routes, ports, backends] = await Promise.all([
      prisma.route.findMany({
        where: { action: 'Proxy', archivedAt: null },
        include: { port: true, backend: true }
      }),
      prisma.port.findMany({ where: { archivedAt: null } }),
      prisma.backend.findMany({
        where: { archivedAt: null },
        include: { server: true }
      })
    ]);

    const nodes: any[] = [];
    const edges: any[] = [];
    const nodeSet = new Set<string>();

    // 1. Domain nodes
    const domainSet = new Set<string>();
    for (const r of routes) {
      if (!domainSet.has(r.domain)) {
        domainSet.add(r.domain);
        const nodeId = `domain-${r.domain}`;
        nodes.push({
          id: nodeId,
          type: 'domain',
          data: { label: r.domain, type: 'domain' }
        });
        nodeSet.add(nodeId);
      }
    }

    // 2. Port nodes
    for (const p of ports) {
      const nodeId = `port-${p.port}`;
      nodes.push({
        id: nodeId,
        type: 'port',
        data: {
          label: `Port :${p.port}`,
          protocol: p.protocol,
          status: p.status,
          layer: p.layer,
          lifecycle: p.lifecycle
        }
      });
      nodeSet.add(nodeId);
    }

    // 3. Backend nodes
    for (const b of backends) {
      const nodeId = `backend-${b.host}-${b.port}`;
      nodes.push({
        id: nodeId,
        type: 'backend',
        data: {
          label: `${b.host}:${b.port}`,
          server: b.server?.name || b.host,
          status: b.status,
          latencyMs: b.latencyMs
        }
      });
      nodeSet.add(nodeId);
    }

    // 4. Edges: Domain -> Port, and Port -> Backend
    const edgeSet = new Set<string>();

    for (const r of routes) {
      const dNode = `domain-${r.domain}`;
      const pNode = r.portNum ? `port-${r.portNum}` : null;
      const bNode = r.backend ? `backend-${r.backend.host}-${r.backend.port}` : null;

      if (pNode && nodeSet.has(dNode) && nodeSet.has(pNode)) {
        const dToPEdge = `${dNode}->${pNode}`;
        if (!edgeSet.has(dToPEdge)) {
          edgeSet.add(dToPEdge);
          edges.push({
            id: dToPEdge,
            source: dNode,
            target: pNode,
            type: 'smoothstep'
          });
        }
      }

      if (pNode && bNode && nodeSet.has(pNode) && nodeSet.has(bNode)) {
        const pToBEdge = `${pNode}->${bNode}`;
        if (!edgeSet.has(pToBEdge)) {
          edgeSet.add(pToBEdge);
          edges.push({
            id: pToBEdge,
            source: pNode,
            target: bNode,
            type: 'smoothstep',
            animated: r.backend?.status === 'up'
          });
        }
      }
    }

    // 5. Blast radius map: backend -> list of affected domains
    const blastRadius: Record<string, string[]> = {};
    for (const b of backends) {
      const key = `${b.host}:${b.port}`;
      const affectedDomains = routes
        .filter((r) => r.backendId === b.id)
        .map((r) => r.domain);
      blastRadius[key] = Array.from(new Set(affectedDomains));
    }

    return reply.send({
      nodes,
      edges,
      blastRadius
    });
  });

  // GET /api/backends/:id/impact - Computes impact before archive/delete
  fastify.get('/backends/:id/impact', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const backend = await prisma.backend.findUnique({
      where: { id },
      include: {
        routes: { where: { archivedAt: null } }
      }
    });

    if (!backend) return reply.status(404).send({ error: 'Backend not found' });

    const routesCount = backend.routes.length;
    const warningLevel = routesCount > 0 ? 'caution' : 'safe';

    return reply.send({
      backend,
      routesCount,
      routes: backend.routes,
      warningLevel,
      notice: 'Removing or archiving this backend will cause attached routes to point to an inactive backend.'
    });
  });

  // POST /api/backends - Create backend
  fastify.post('/backends', async (request: FastifyRequest, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const body = request.body as any;
    const port = parseInt(body.port);

    const existing = await prisma.backend.findUnique({
      where: { host_port: { host: body.host, port } }
    });

    if (existing) {
      if (existing.archivedAt) {
        // Restore existing
        const restored = await prisma.backend.update({
          where: { id: existing.id },
          data: { archivedAt: null, archivedBy: null, label: body.label || existing.label }
        });
        return reply.status(200).send(restored);
      }
      return reply.status(409).send({ error: `Backend ${body.host}:${port} already exists.` });
    }

    const created = await prisma.backend.create({
      data: {
        host: body.host,
        port,
        serverId: body.serverId || null,
        label: body.label || `${body.host}:${port}`,
        notes: body.notes || '',
        status: 'unknown'
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'create',
        entity: 'backend',
        entityId: created.id,
        afterState: created
      }
    });

    return reply.status(201).send(created);
  });

  // POST /api/backends/bulk - Bulk add backends
  fastify.post('/backends/bulk', async (request: FastifyRequest, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { backendsList } = request.body as { backendsList: any[] };
    if (!Array.isArray(backendsList) || backendsList.length === 0) {
      return reply.status(400).send({ error: 'No backends provided in backendsList' });
    }

    const username = (request as any).user?.username || 'admin';
    const createdBackends: any[] = [];

    await prisma.$transaction(async (tx) => {
      for (const item of backendsList) {
        const port = parseInt(item.port);
        if (!item.host || isNaN(port)) continue;

        const existing = await tx.backend.findUnique({
          where: { host_port: { host: item.host, port } }
        });

        if (existing) {
          if (existing.archivedAt) {
            await tx.backend.update({
              where: { id: existing.id },
              data: { archivedAt: null, archivedBy: null }
            });
            createdBackends.push(existing);
          }
          continue;
        }

        const b = await tx.backend.create({
          data: {
            host: item.host,
            port,
            label: item.label || `${item.host}:${port}`,
            serverId: item.serverId || null,
            notes: item.notes || ''
          }
        });
        createdBackends.push(b);
      }

      await tx.auditLog.create({
        data: {
          username,
          action: 'bulk_create',
          entity: 'backend',
          afterState: { count: createdBackends.length }
        }
      });
    });

    return reply.status(201).send({ success: true, count: createdBackends.length, backends: createdBackends });
  });

  // PATCH /api/backends/:id - Edit backend
  fastify.patch('/backends/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const body = request.body as any;

    const existing = await prisma.backend.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Backend not found' });

    const updated = await prisma.backend.update({
      where: { id },
      data: {
        label: body.label !== undefined ? body.label : existing.label,
        notes: body.notes !== undefined ? body.notes : existing.notes,
        serverId: body.serverId !== undefined ? body.serverId : existing.serverId
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'update',
        entity: 'backend',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send(updated);
  });

  // POST /api/backends/:id/archive - Archive a backend
  fastify.post('/backends/:id/archive', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const existing = await prisma.backend.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Backend not found' });

    const username = (request as any).user?.username || 'admin';
    const now = new Date();

    const updated = await prisma.backend.update({
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
        entity: 'backend',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send({ success: true, message: `Backend ${existing.host}:${existing.port} archived.` });
  });

  // POST /api/backends/:id/restore - Restore an archived backend
  fastify.post('/backends/:id/restore', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const existing = await prisma.backend.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Backend not found' });

    const restored = await prisma.backend.update({
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
        entity: 'backend',
        entityId: id,
        afterState: restored
      }
    });

    return reply.send({ success: true, backend: restored });
  });

  // DELETE /api/backends/:id - Permanently delete backend (with snapshot)
  fastify.delete('/backends/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const existing = await prisma.backend.findUnique({
      where: { id },
      include: { routes: true }
    });
    if (!existing) return reply.status(404).send({ error: 'Backend not found' });

    const username = (request as any).user?.username || 'admin';

    // Store snapshot
    await prisma.trashSnapshot.create({
      data: {
        entityType: 'backend',
        entityId: id,
        entityName: `${existing.host}:${existing.port}`,
        data: existing,
        deletedBy: username
      }
    });

    await prisma.backend.delete({ where: { id } });

    await prisma.auditLog.create({
      data: {
        username,
        action: 'delete',
        entity: 'backend',
        entityId: id,
        beforeState: existing
      }
    });

    return reply.send({ success: true });
  });
}
