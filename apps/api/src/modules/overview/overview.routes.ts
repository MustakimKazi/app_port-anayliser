import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';
import { ScannerService } from '../../scanner/scanner-service.js';
import { hostListener } from '../../scanner/host-listener.js';

export async function overviewRoutes(fastify: FastifyInstance, opts: { scanner: ScannerService }) {
  fastify.get('/overview', async (request: FastifyRequest, reply: FastifyReply) => {
    // 1. Ports status breakdown
    const allPorts = await prisma.port.findMany({
      include: { routes: { where: { archivedAt: null } } }
    });

    // Lifecycle counts
    const lifecycles = {
      active: 0,
      planned: 0,
      reserved: 0,
      maintenance: 0,
      deprecated: 0,
      archived: 0
    };

    for (const p of allPorts) {
      const lc = (p.lifecycle || 'active').toLowerCase() as keyof typeof lifecycles;
      if (lifecycles[lc] !== undefined) {
        lifecycles[lc]++;
      } else {
        lifecycles.active++;
      }
    }

    // Active (non-archived) ports for status counters
    const activePorts = allPorts.filter((p) => p.lifecycle !== 'archived' && !p.archivedAt);
    const totalPorts = activePorts.length;

    let upPorts = 0;
    let downPorts = 0;
    let slowPorts = 0;
    let unknownPorts = 0;

    for (const p of activePorts) {
      if (p.lifecycle === 'planned' || p.lifecycle === 'reserved') {
        continue;
      }
      if (p.status === 'up') upPorts++;
      else if (p.status === 'down') downPorts++;
      else if (p.status === 'slow') slowPorts++;
      else unknownPorts++;
    }

    // 2. Open Issues breakdown
    const issues = await prisma.issue.findMany({
      where: { status: { in: ['open', 'acknowledged'] } }
    });

    const openIssuesTotal = issues.length;
    let highIssues = 0;
    let medIssues = 0;
    let lowIssues = 0;
    let infoIssues = 0;

    for (const i of issues) {
      if (i.priority === 'High') highIssues++;
      else if (i.priority === 'Medium') medIssues++;
      else if (i.priority === 'Low') lowIssues++;
      else infoIssues++;
    }

    // 3. Domains and Backends count (non-archived)
    const routes = await prisma.route.findMany({
      where: { archivedAt: null },
      select: { domain: true, action: true, portNum: true }
    });
    const uniqueDomains = new Set(routes.map((r) => r.domain));
    const totalBackends = await prisma.backend.count({ where: { archivedAt: null } });

    // 4. Certificates expiring soon count
    const certs = opts.scanner.getCachedCertificates();
    const certsExpiringSoon = certs.filter(
      (c) => c.isExpiringSoon || c.status === 'critical' || c.status === 'expired'
    ).length;

    // 5. Ports by Layer & Protocol (Donut Chart)
    const layerStats: Record<string, number> = {};
    for (const p of activePorts) {
      const key = `${p.layer.toUpperCase()} (${p.protocol})`;
      layerStats[key] = (layerStats[key] || 0) + 1;
    }
    const layerDonut = Object.entries(layerStats).map(([name, value]) => ({ name, value }));

    // 6. Routes by Action
    const actionStats: Record<string, number> = {};
    for (const r of routes) {
      actionStats[r.action] = (actionStats[r.action] || 0) + 1;
    }
    const actionChart = Object.entries(actionStats).map(([name, value]) => ({ name, value }));

    // 7. Top 10 Ports by Domains Count
    const portDomainCount = new Map<number, Set<string>>();
    for (const r of routes) {
      if (r.portNum) {
        if (!portDomainCount.has(r.portNum)) portDomainCount.set(r.portNum, new Set());
        portDomainCount.get(r.portNum)!.add(r.domain);
      }
    }
    const topPorts = Array.from(portDomainCount.entries())
      .map(([port, set]) => ({ port: `Port ${port}`, count: set.size, portNum: port }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 10);

    // 8. Needs Attention Panel
    const now = new Date();
    const attentionHighIssues = issues.filter((i) => i.priority === 'High').slice(0, 5);
    const attentionDownPorts = activePorts
      .filter((p) => p.status === 'down' && p.lifecycle !== 'planned' && p.lifecycle !== 'reserved' && p.lifecycle !== 'maintenance')
      .slice(0, 5);
    const attentionExpiringCerts = certs.filter((c) => c.daysRemaining <= 14).slice(0, 5);

    // Overdue planned ports
    const overduePlanned = allPorts.filter(
      (p) => p.lifecycle === 'planned' && p.targetDate && new Date(p.targetDate) < now
    );

    // Planned or reserved ports currently listening
    let listeningPlanned: any[] = [];
    try {
      const listeningMap = await hostListener.getListeningPorts();
      listeningPlanned = allPorts.filter(
        (p) => (p.lifecycle === 'planned' || p.lifecycle === 'reserved') && listeningMap.has(p.port)
      );
    } catch (e) {
      // Ignore
    }

    // 9. Live Activity Feed from status_events
    const recentEvents = await prisma.statusEvent.findMany({
      orderBy: { at: 'desc' },
      take: 15
    });

    // 10. Status History over last 24h
    const oneDayAgo = new Date();
    oneDayAgo.setDate(oneDayAgo.getDate() - 1);

    const recentChecks = await prisma.portCheck.findMany({
      where: { checkedAt: { gte: oneDayAgo } },
      orderBy: { checkedAt: 'asc' },
      take: 500
    });

    // Aggregate into 12 two-hour buckets
    const historyTrend: Array<{ time: string; up: number; down: number; slow: number }> = [];
    for (let i = 11; i >= 0; i--) {
      const bucketStart = new Date(now.getTime() - (i + 1) * 2 * 3600 * 1000);
      const bucketEnd = new Date(now.getTime() - i * 2 * 3600 * 1000);

      const inBucket = recentChecks.filter(
        (c) => new Date(c.checkedAt) >= bucketStart && new Date(c.checkedAt) < bucketEnd
      );

      historyTrend.push({
        time: `${bucketStart.getHours()}:00`,
        up: inBucket.filter((c) => c.status === 'up').length,
        down: inBucket.filter((c) => c.status === 'down').length,
        slow: inBucket.filter((c) => c.status === 'slow').length
      });
    }

    return reply.send({
      kpis: {
        totalPorts,
        upPorts,
        downPorts,
        slowPorts,
        unknownPorts,
        lifecycles,
        openIssues: {
          total: openIssuesTotal,
          high: highIssues,
          medium: medIssues,
          low: lowIssues,
          info: infoIssues
        },
        totalDomains: uniqueDomains.size,
        totalBackends,
        certsExpiringSoon
      },
      charts: {
        layerDonut,
        actionChart,
        topPorts,
        historyTrend
      },
      attention: {
        highIssues: attentionHighIssues,
        downPorts: attentionDownPorts,
        expiringCerts: attentionExpiringCerts,
        overduePlanned,
        listeningPlanned
      },
      recentEvents,
      scanner: {
        isScanning: opts.scanner.isCurrentlyScanning(),
        lastScanTime: opts.scanner.getLastScanTime(),
        intervalSec: 30
      }
    });
  });
}
