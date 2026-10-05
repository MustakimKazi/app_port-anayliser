import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';

export async function historyRoutes(fastify: FastifyInstance) {
  // GET /api/history - Global uptime, downtime logs, and timeline
  fastify.get('/history', async (request: FastifyRequest, reply: FastifyReply) => {
    // 1. Status Events Timeline
    const events = await prisma.statusEvent.findMany({
      orderBy: { at: 'desc' },
      take: 100
    });

    // 2. Downtime incidents calculation from status events
    const downtimeIncidents: Array<{
      targetName: string;
      targetType: string;
      startedAt: Date;
      resolvedAt: Date | null;
      durationMinutes: number | null;
    }> = [];

    // Find recent down transitions
    for (let i = 0; i < events.length; i++) {
      const e = events[i];
      if (e.toStatus === 'down') {
        // Look for subsequent recovery
        let resolvedAt: Date | null = null;
        let durationMinutes: number | null = null;

        for (let j = i - 1; j >= 0; j--) {
          const next = events[j];
          if (next.targetId === e.targetId && (next.toStatus === 'up' || next.toStatus === 'slow')) {
            resolvedAt = next.at;
            durationMinutes = Math.round((new Date(resolvedAt).getTime() - new Date(e.at).getTime()) / 60000);
            break;
          }
        }

        downtimeIncidents.push({
          targetName: e.targetName,
          targetType: e.targetType,
          startedAt: e.at,
          resolvedAt,
          durationMinutes
        });
      }
    }

    // 3. Overall Uptime % calculation (24h, 7d, 30d)
    const now = new Date();
    const d24 = new Date(now.getTime() - 24 * 3600 * 1000);
    const d7 = new Date(now.getTime() - 7 * 24 * 3600 * 1000);
    const d30 = new Date(now.getTime() - 30 * 24 * 3600 * 1000);

    const checks24 = await prisma.portCheck.findMany({
      where: { checkedAt: { gte: d24 } },
      select: { status: true }
    });

    const checks7 = await prisma.portCheck.findMany({
      where: { checkedAt: { gte: d7 } },
      select: { status: true }
    });

    const checks30 = await prisma.portCheck.findMany({
      where: { checkedAt: { gte: d30 } },
      select: { status: true }
    });

    const calcUptime = (checks: { status: string }[]) => {
      if (!checks.length) return 99.9;
      const up = checks.filter(c => c.status === 'up' || c.status === 'slow').length;
      return Math.round((up / checks.length) * 1000) / 10;
    };

    return reply.send({
      uptime: {
        last24h: calcUptime(checks24),
        last7d: calcUptime(checks7),
        last30d: calcUptime(checks30)
      },
      downtimeIncidents: downtimeIncidents.slice(0, 25),
      timeline: events
    });
  });
}
