import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import prisma from '../../db/prisma.js';
import { hostListener } from '../../scanner/host-listener.js';
import { tcpChecker } from '../../scanner/tcp-checker.js';

const FreePortQuerySchema = z.object({
  range: z.string().default('3000-3999'),
  count: z.coerce.number().default(5)
});

export async function portMapRoutes(fastify: FastifyInstance) {
  // GET /api/port-map - Overview of ranges and port utilization
  fastify.get('/port-map', async (request: FastifyRequest, reply: FastifyReply) => {
    const ports = await prisma.port.findMany({
      select: {
        port: true,
        layer: true,
        protocol: true,
        purpose: true,
        status: true,
        isPublic: true
      }
    });

    const definedRanges = [
      { label: 'Well-Known (System)', min: 1, max: 1024 },
      { label: '3000–3999 (Web Apps / Dev)', min: 3000, max: 3999 },
      { label: '4000–4999 (Services)', min: 4000, max: 4999 },
      { label: '7000–7999 (Redis / DB)', min: 7000, max: 7999 },
      { label: '8000–8999 (Web / Proxies)', min: 8000, max: 8999 },
      { label: '9000–9999 (Apps / APIs)', min: 9000, max: 9999 },
      { label: '10000–10999 (Internal Apps)', min: 10000, max: 10999 },
      { label: '28000–28999 (Media / Custom)', min: 28000, max: 28999 },
      { label: '60000–60999 (Mongo / Streams)', min: 60000, max: 60999 }
    ];

    const rangeStats = definedRanges.map(r => {
      const assigned = ports.filter(p => p.port >= r.min && p.port <= r.max);
      return {
        label: r.label,
        min: r.min,
        max: r.max,
        totalCapacity: r.max - r.min + 1,
        usedCount: assigned.length,
        usedPercentage: Math.round((assigned.length / (r.max - r.min + 1)) * 1000) / 10,
        ports: assigned
      };
    });

    return reply.send({
      ranges: rangeStats,
      allDocumentedPorts: ports
    });
  });

  // GET /api/port-map/free - Find free ports in a specific range
  fastify.get('/port-map/free', async (request: FastifyRequest, reply: FastifyReply) => {
    const parse = FreePortQuerySchema.safeParse(request.query);
    if (!parse.success) return reply.status(400).send({
        error: 'Invalid request parameters',
        issues: parse.error.issues.map((i) => ({ path: i.path.join('.'), message: i.message }))
      });

    const { range, count } = parse.data;
    const [minStr, maxStr] = range.split('-');
    const minPort = parseInt(minStr, 10) || 3000;
    const maxPort = parseInt(maxStr, 10) || 3999;

    // 1. Get documented ports in range
    const documented = await prisma.port.findMany({
      where: { port: { gte: minPort, lte: maxPort } },
      select: { port: true }
    });
    const docSet = new Set(documented.map(p => p.port));

    // 2. Get active host listeners
    const hostListening = await hostListener.getListeningPorts();

    // 3. Find candidates and probe them via TCP to ensure they are truly free
    const candidates: number[] = [];
    for (let p = minPort; p <= maxPort && candidates.length < count * 2; p++) {
      if (!docSet.has(p) && !hostListening.has(p)) {
        candidates.push(p);
      }
    }

    const verifiedFreePorts: number[] = [];
    for (const port of candidates) {
      if (verifiedFreePorts.length >= count) break;
      const res = await tcpChecker.check('127.0.0.1', port, 500);
      if (res.status === 'down') {
        // TCP refused connection = confirmed free!
        verifiedFreePorts.push(port);
      }
    }

    return reply.send({
      range: `${minPort}-${maxPort}`,
      requestedCount: count,
      freePorts: verifiedFreePorts
    });
  });
}
