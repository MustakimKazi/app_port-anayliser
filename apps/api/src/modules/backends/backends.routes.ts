import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';
import { ScannerService } from '../../scanner/scanner-service.js';

export async function backendsRoutes(fastify: FastifyInstance, opts: { scanner: ScannerService }) {
  // GET /api/backends
  fastify.get('/backends', async (request: FastifyRequest, reply: FastifyReply) => {
    const backends = await prisma.backend.findMany({
      include: {
        server: true,
        routes: {
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
        where: { action: 'Proxy' },
        include: { port: true, backend: true }
      }),
      prisma.port.findMany(),
      prisma.backend.findMany({
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
          layer: p.layer
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
            label: r.protocol
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
            label: 'proxy'
          });
        }
      }
    }

    // 5. Blast Radius Analysis: For each backend, which domains break if it fails?
    const blastRadius: Record<string, { backend: string; affectedDomains: string[]; routeCount: number; serverName: string }> = {};

    for (const b of backends) {
      const key = `${b.host}:${b.port}`;
      const affected = routes
        .filter(r => r.backendId === b.id)
        .map(r => r.domain);
      const uniqueAffected = Array.from(new Set(affected));

      blastRadius[key] = {
        backend: key,
        affectedDomains: uniqueAffected,
        routeCount: affected.length,
        serverName: b.server?.name || b.host
      };
    }

    return reply.send({
      nodes,
      edges,
      blastRadius
    });
  });

  // POST /api/backends
  fastify.post('/backends', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    const created = await prisma.backend.create({
      data: {
        host: body.host,
        port: parseInt(body.port),
        serverId: body.serverId || null,
        label: body.label || `${body.host}:${body.port}`,
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

  // PATCH /api/backends/:id
  fastify.patch('/backends/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
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

  // DELETE /api/backends/:id
  fastify.delete('/api/backends/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const existing = await prisma.backend.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Backend not found' });

    await prisma.backend.delete({ where: { id } });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'delete',
        entity: 'backend',
        entityId: id,
        beforeState: existing
      }
    });

    return reply.send({ success: true });
  });
}
