import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';
import { ScannerService } from '../../scanner/scanner-service.js';

export async function overviewRoutes(fastify: FastifyInstance, opts: { scanner: ScannerService }) {
  fastify.get('/overview', async (request: FastifyRequest, reply: FastifyReply) => {
    // 1. Ports status breakdown
    const ports = await prisma.port.findMany({
      include: { routes: true }
    });

    const totalPorts = ports.length;
    let upPorts = 0;
    let downPorts = 0;
    let slowPorts = 0;
    let unknownPorts = 0;

    for (const p of ports) {
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

    // 3. Domains and Backends count
    const routes = await prisma.route.findMany({
      select: { domain: true, action: true, portNum: true }
    });
    const uniqueDomains = new Set(routes.map(r => r.domain));
    const totalBackends = await prisma.backend.count();

    // 4. Certificates expiring soon count
    const certs = opts.scanner.getCachedCertificates();
    const certsExpiringSoon = certs.filter(c => c.isExpiringSoon || c.status === 'critical' || c.status === 'expired').length;

    // 5. Ports by Layer & Protocol (Donut Chart)
    const layerStats: Record<string, number> = {};
    for (const p of ports) {
      const key = `${p.layer.toUpperCase()} (${p.protocol})`;
      layerStats[key] = (layerStats[key] || 0) + 1;
    }
    const layerDonut = Object.entries(layerStats).map(([name, value]) => ({ name, value }));

    // 6. Routes by Action (Proxy / Static / Redirect / Return / Status)
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
    const attentionHighIssues = issues.filter(i => i.priority === 'High').slice(0, 5);
    const attentionDownPorts = ports.filter(p => p.status === 'down').slice(0, 5);
    const attentionExpiringCerts = certs.filter(c => c.daysRemaining <= 14).slice(0, 5);

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

    // Group checks into 24 hour buckets or recent intervals
    const historyBuckets: Record<string, { up: number; down: number; slow: number }> = {};
    for (const c of recentChecks) {
      const timeKey = new Date(c.checkedAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      if (!historyBuckets[timeKey]) {
        historyBuckets[timeKey] = { up: 0, down: 0, slow: 0 };
      }
      if (c.status === 'up') historyBuckets[timeKey].up++;
      else if (c.status === 'down') historyBuckets[timeKey].down++;
      else if (c.status === 'slow') historyBuckets[timeKey].slow++;
    }

    const historyTrend = Object.entries(historyBuckets).map(([time, counts]) => ({
      time,
      ...counts
    }));

    return reply.send({
      kpis: {
        totalPorts,
        upPorts,
        downPorts,
        slowPorts,
        unknownPorts,
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
        expiringCerts: attentionExpiringCerts
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
