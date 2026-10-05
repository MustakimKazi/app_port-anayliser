import { PrismaClient } from '@prisma/client';
import { ListeningPortInfo } from './host-listener.js';
import { CertificateInfo } from './cert-checker.js';

export class IssueDetector {
  /**
   * Evaluates system state against health and security rules.
   * Creates or resolves auto-detected issues.
   */
  async evaluate(
    prisma: PrismaClient,
    listeningPorts: Map<number, ListeningPortInfo>,
    certs: CertificateInfo[]
  ) {
    const activeAutoKeys = new Set<string>();

    // 1. Check for ports in DB that are DOWN (not listening on host)
    const dbPorts = await prisma.port.findMany({
      include: { routes: true }
    });

    for (const p of dbPorts) {
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

    // 2. Check for Undocumented listening ports (rogue ports on host not in PortWatch DB)
    const documentedPortNumbers = new Set(dbPorts.map(p => p.port));
    for (const [portNum, info] of listeningPorts.entries()) {
      // Ignore ephemeral/high ports and internal dynamic ports if needed
      if (!documentedPortNumbers.has(portNum)) {
        const autoKey = `auto-port-undocumented-${portNum}`;
        activeAutoKeys.add(autoKey);

        await prisma.issue.upsert({
          where: { autoKey },
          update: {
            status: 'open',
            resolvedAt: null,
            observed: `Port ${portNum} is actively listening (${info.bindAddress}) under process '${info.processName || 'unknown'}' (PID: ${info.pid || '?'}) but is not documented.`,
          },
          create: {
            autoKey,
            title: `Undocumented listening port ${portNum}`,
            priority: 'Medium',
            observed: `Port ${portNum} is actively listening (${info.bindAddress}) under process '${info.processName || 'unknown'}' (PID: ${info.pid || '?'}) but is not documented.`,
            recommendation: `Run: sudo ss -tlnp | grep :${portNum} to identify the application and document or close it.`,
            status: 'open',
            source: 'auto-detected'
          }
        });
      }
    }

    // 3. Database ports exposed publicly (Redis 7001-7003, Mongo 60007-60009, 3306, 5432, etc.)
    const dbPortNumbers = [7001, 7002, 7003, 60007, 60008, 60009, 3306, 5432, 27017, 6379];
    for (const p of dbPorts) {
      if (dbPortNumbers.includes(p.port) && p.isPublic) {
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

    // 4. Public plain-HTTP ports (no TLS on internet-facing web ports)
    const plainHttpPorts = [10080, 10081, 10180, 10181, 28096];
    for (const p of dbPorts) {
      if (plainHttpPorts.includes(p.port) && p.protocol === 'HTTP' && p.isPublic) {
        const autoKey = `auto-plain-http-${p.port}`;
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
            title: `Public plain-HTTP port ${p.port} without TLS`,
            priority: 'Medium',
            observed: `Port ${p.port} serves unencrypted HTTP without SSL configuration in Nginx.`,
            recommendation: `Confirm if TLS termination is handled by an upstream CDN or add SSL certificates.`,
            status: 'open',
            source: 'auto-detected',
            relatedPortId: p.id
          }
        });
      }
    }

    // 5. Duplicate local ports / conflict detection (8080 and 9000 check)
    // Check routes proxying to same backend host:port from different apps
    const backends = await prisma.backend.findMany({
      include: { routes: true }
    });
    for (const b of backends) {
      if (b.routes.length > 1 && (b.port === 8080 || b.port === 9000 || b.host === '127.0.0.1' || b.host === 'localhost')) {
        const domains = Array.from(new Set(b.routes.map(r => r.domain)));
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

    // 6. Expiring Certificates check
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

    // 7. Auto-resolve issues that are no longer active
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
