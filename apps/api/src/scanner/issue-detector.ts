import { PrismaClient } from '@prisma/client';
import { ListeningPortInfo } from './host-listener.js';
import { CertificateInfo } from './cert-checker.js';

export class IssueDetector {
  /**
   * Evaluates system state against health, security, and lifecycle rules.
   * Creates or resolves auto-detected issues.
   */
  async evaluate(
    prisma: PrismaClient,
    listeningPorts: Map<number, ListeningPortInfo>,
    certs: CertificateInfo[]
  ) {
    const activeAutoKeys = new Set<string>();

    const dbPorts = await prisma.port.findMany({
      include: { routes: { where: { archivedAt: null } } }
    });

    const now = new Date();

    // 1. Check for ports in DB that are DOWN (not listening on host)
    // IMPORTANT: Planned, reserved, maintenance, and archived ports NEVER create DOWN alerts!
    for (const p of dbPorts) {
      if (p.lifecycle === 'planned' || p.lifecycle === 'reserved' || p.lifecycle === 'archived' || p.lifecycle === 'maintenance') {
        continue;
      }

      const isListening = listeningPorts.has(p.port);
      if (!isListening && p.isExpected) {
        const autoKey = `auto-port-down-${p.port}`;
        activeAutoKeys.add(autoKey);

        await prisma.issue.upsert({
          where: { autoKey },
          update: {
            status: 'open',
            resolvedAt: null,
            observed: `Port ${p.port} (${p.protocol} / ${p.layer}) is documented in database but is NOT listening on the host.`,
            relatedPortId: p.id
          },
          create: {
            autoKey,
            title: `Port ${p.port} is down / not listening`,
            priority: 'High',
            observed: `Port ${p.port} (${p.protocol} / ${p.layer}) is documented in database but is NOT listening on the host.`,
            recommendation: `Check service status: sudo ss -tlnp | grep :${p.port} or systemctl status nginx`,
            status: 'open',
            source: 'auto-detected',
            relatedPortId: p.id
          }
        });
      }
    }

    // 2. Check for Undocumented listening ports (rogue ports on host not in PortWatch DB or archived)
    const activeDocPortsMap = new Map(dbPorts.filter((p) => p.lifecycle !== 'archived').map((p) => [p.port, p]));
    const archivedPortsMap = new Map(dbPorts.filter((p) => p.lifecycle === 'archived').map((p) => [p.port, p]));

    for (const [portNum, info] of listeningPorts.entries()) {
      if (archivedPortsMap.has(portNum)) {
        // Port is archived in PortWatch but STILL listening on the host!
        const autoKey = `auto-archived-listening-${portNum}`;
        activeAutoKeys.add(autoKey);

        await prisma.issue.upsert({
          where: { autoKey },
          update: {
            status: 'open',
            resolvedAt: null,
            observed: `Port ${portNum} is archived in PortWatch documentation but is STILL actively listening (${info.bindAddress}) under process '${info.processName || 'unknown'}' (PID: ${info.pid || '?'}).`
          },
          create: {
            autoKey,
            title: `Port ${portNum} is archived but still listening on the server`,
            priority: 'Medium',
            observed: `Port ${portNum} is archived in PortWatch documentation but is STILL actively listening (${info.bindAddress}) under process '${info.processName || 'unknown'}' (PID: ${info.pid || '?'}).`,
            recommendation: `Stop the running service on the host if no longer needed, or restore the port documentation in PortWatch.`,
            status: 'open',
            source: 'auto-detected',
            relatedPortId: archivedPortsMap.get(portNum)?.id
          }
        });
      } else if (!activeDocPortsMap.has(portNum)) {
        // Completely undocumented port
        const autoKey = `auto-port-undocumented-${portNum}`;
        activeAutoKeys.add(autoKey);

        await prisma.issue.upsert({
          where: { autoKey },
          update: {
            status: 'open',
            resolvedAt: null,
            observed: `Port ${portNum} is actively listening (${info.bindAddress}) under process '${info.processName || 'unknown'}' (PID: ${info.pid || '?'}) but is not documented.`
          },
          create: {
            autoKey,
            title: `Undocumented listening port ${portNum}`,
            priority: 'Medium',
            observed: `Port ${portNum} is actively listening (${info.bindAddress}) under process '${info.processName || 'unknown'}' (PID: ${info.pid || '?'}) but is not documented.`,
            recommendation: `Run: sudo ss -tlnp | grep :${portNum} to identify the application and add it to documentation or close it.`,
            status: 'open',
            source: 'auto-detected'
          }
        });
      }
    }

    // 3. Planned / Reserved port found LISTENING on host
    for (const p of dbPorts) {
      if ((p.lifecycle === 'planned' || p.lifecycle === 'reserved') && listeningPorts.has(p.port)) {
        const info = listeningPorts.get(p.port)!;
        const autoKey = `auto-planned-listening-${p.port}`;
        activeAutoKeys.add(autoKey);

        await prisma.issue.upsert({
          where: { autoKey },
          update: {
            status: 'open',
            resolvedAt: null,
            observed: `Port ${p.port} is marked as ${p.lifecycle} (${p.purpose || 'no purpose'}) and is now listening (${info.bindAddress}) under process '${info.processName || 'unknown'}' (PID: ${info.pid || '?'}).`,
            relatedPortId: p.id
          },
          create: {
            autoKey,
            title: `Port ${p.port} is ${p.lifecycle} and now listening`,
            priority: 'Info',
            observed: `Port ${p.port} is marked as ${p.lifecycle} (${p.purpose || 'no purpose'}) and is now listening (${info.bindAddress}) under process '${info.processName || 'unknown'}' (PID: ${info.pid || '?'}).`,
            recommendation: `Port ${p.port} is ${p.lifecycle} and now listening. Mark active?`,
            status: 'open',
            source: 'auto-detected',
            relatedPortId: p.id
          }
        });
      }
    }

    // 4. Overdue planned ports (target date in the past)
    for (const p of dbPorts) {
      if (p.lifecycle === 'planned' && p.targetDate && new Date(p.targetDate) < now) {
        const autoKey = `auto-planned-overdue-${p.port}`;
        activeAutoKeys.add(autoKey);

        const targetFormatted = new Date(p.targetDate).toISOString().split('T')[0];
        await prisma.issue.upsert({
          where: { autoKey },
          update: {
            status: 'open',
            resolvedAt: null,
            observed: `Planned port ${p.port} target date was ${targetFormatted} (${p.owner || 'unassigned'}) and is now overdue.`,
            relatedPortId: p.id
          },
          create: {
            autoKey,
            title: `Planned port ${p.port} is overdue (${targetFormatted})`,
            priority: 'Medium',
            observed: `Planned port ${p.port} target date was ${targetFormatted} (${p.owner || 'unassigned'}) and is now overdue.`,
            recommendation: `Confirm project deployment status: mark port ${p.port} active or postpone the target date.`,
            status: 'open',
            source: 'auto-detected',
            relatedPortId: p.id
          }
        });
      }
    }

    // 5. Routes attached to Deprecated port
    for (const p of dbPorts) {
      if (p.lifecycle === 'deprecated' && p.routes.length > 0) {
        const autoKey = `auto-deprecated-port-routes-${p.port}`;
        activeAutoKeys.add(autoKey);

        const routeDomains = p.routes.map((r) => r.domain).join(', ');
        await prisma.issue.upsert({
          where: { autoKey },
          update: {
            status: 'open',
            resolvedAt: null,
            observed: `Deprecated port ${p.port} has ${p.routes.length} active routes attached (${routeDomains}).`,
            relatedPortId: p.id
          },
          create: {
            autoKey,
            title: `Active routes attached to deprecated port ${p.port}`,
            priority: 'Medium',
            observed: `Deprecated port ${p.port} has ${p.routes.length} active routes attached (${routeDomains}).`,
            recommendation: `Migrate all routes off deprecated port ${p.port} before shutting down the service.`,
            status: 'open',
            source: 'auto-detected',
            relatedPortId: p.id
          }
        });
      }
    }

    // 6. Database ports exposed publicly
    const dbPortNumbers = [7001, 7002, 7003, 60007, 60008, 60009, 3306, 5432, 27017, 6379];
    for (const p of dbPorts) {
      if (p.lifecycle !== 'archived' && dbPortNumbers.includes(p.port) && p.isPublic) {
        const autoKey = `auto-db-exposed-${p.port}`;
        activeAutoKeys.add(autoKey);

        await prisma.issue.upsert({
          where: { autoKey },
          update: {
            status: 'open',
            resolvedAt: null,
            relatedPortId: p.id
          },
          create: {
            autoKey,
            title: `Database port ${p.port} (${p.purpose || 'Stream TCP'}) bound publicly`,
            priority: 'High',
            observed: `Database/cache port ${p.port} is accessible on public interfaces (0.0.0.0).`,
            recommendation: `Confirm firewall or IP whitelist restrictions: sudo ufw status or inspect nginx stream whitelist config.`,
            status: 'open',
            source: 'auto-detected',
            relatedPortId: p.id
          }
        });
      }
    }

    // 7. Duplicate local ports / conflict detection (8080 and 9000 check)
    const backends = await prisma.backend.findMany({
      where: { archivedAt: null },
      include: { routes: { where: { archivedAt: null } } }
    });
    for (const b of backends) {
      if (b.routes.length > 1 && (b.port === 8080 || b.port === 9000 || b.host === '127.0.0.1' || b.host === 'localhost')) {
        const domains = Array.from(new Set(b.routes.map((r) => r.domain)));
        if (domains.length > 1) {
          const autoKey = `auto-port-conflict-${b.host}-${b.port}`;
          activeAutoKeys.add(autoKey);

          await prisma.issue.upsert({
            where: { autoKey },
            update: {
              status: 'open',
              resolvedAt: null,
              observed: `Local backend ${b.host}:${b.port} is shared across distinct domains: ${domains.join(', ')}.`
            },
            create: {
              autoKey,
              title: `Local port ${b.port} mapped to multiple applications`,
              priority: 'High',
              observed: `Local backend ${b.host}:${b.port} is shared across distinct domains: ${domains.join(', ')}.`,
              recommendation: `Run: sudo ss -tlnp | grep :${b.port} to confirm which app owns it and isolate routes.`,
              status: 'open',
              source: 'auto-detected'
            }
          });
        }
      }
    }

    // 8. Expiring Certificates check
    for (const c of certs) {
      if (c.status === 'critical' || c.status === 'expiring_soon' || c.status === 'expired') {
        const autoKey = `auto-cert-expiring-${c.domain}-${c.port}`;
        activeAutoKeys.add(autoKey);

        const priority = c.daysRemaining <= 7 ? 'High' : 'Medium';
        await prisma.issue.upsert({
          where: { autoKey },
          update: {
            status: 'open',
            resolvedAt: null,
            priority,
            observed: `TLS certificate for ${c.domain}:${c.port} expires in ${c.daysRemaining} days (Issuer: ${c.issuer}).`
          },
          create: {
            autoKey,
            title: `TLS certificate for ${c.domain} expiring soon (${c.daysRemaining}d left)`,
            priority,
            observed: `TLS certificate for ${c.domain}:${c.port} expires in ${c.daysRemaining} days (Issuer: ${c.issuer}).`,
            recommendation: `Renew certificate: sudo certbot renew --cert-name ${c.domain} or check auto-renewal timer.`,
            status: 'open',
            source: 'auto-detected'
          }
        });
      }
    }

    // 9. Auto-resolve issues that are no longer active
    const openAutoIssues = await prisma.issue.findMany({
      where: {
        source: 'auto-detected',
        status: { in: ['open', 'acknowledged'] }
      }
    });

    for (const issue of openAutoIssues) {
      if (issue.autoKey && !activeAutoKeys.has(issue.autoKey)) {
        await prisma.issue.update({
          where: { id: issue.id },
          data: {
            status: 'resolved',
            resolvedAt: new Date()
          }
        });
      }
    }
  }
}

export const issueDetector = new IssueDetector();
