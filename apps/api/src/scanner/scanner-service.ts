import pLimit from 'p-limit';
import { PrismaClient } from '@prisma/client';
import { hostListener, ListeningPortInfo } from './host-listener.js';
import { tcpChecker } from './tcp-checker.js';
import { httpChecker } from './http-checker.js';
import { certChecker, CertificateInfo } from './cert-checker.js';
import { issueDetector } from './issue-detector.js';
import { sseManager } from '../realtime/sse.js';
import { config } from '../config/env.js';

export class ScannerService {
  private isScanning = false;
  private timer: NodeJS.Timeout | null = null;
  private lastScanTime: Date | null = null;
  private cachedCerts: CertificateInfo[] = [];

  constructor(private prisma: PrismaClient) {}

  start() {
    console.log(`Starting PortWatch Scanner worker (interval: ${config.scanIntervalSec}s)...`);
    // Run initial scan shortly after startup
    setTimeout(() => {
      this.runScan().catch((err) => console.error('Initial scan failed:', err));
    }, 2000);

    // Schedule periodic scans
    this.timer = setInterval(() => {
      this.runScan().catch((err) => console.error('Periodic scan error:', err));
    }, config.scanIntervalSec * 1000);
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  getLastScanTime() {
    return this.lastScanTime;
  }

  isCurrentlyScanning() {
    return this.isScanning;
  }

  getCachedCertificates() {
    return this.cachedCerts;
  }

  /**
   * Run a full scan across host listeners, ports, backends, routes, and certs.
   * Respects port lifecycles (planned, reserved, maintenance, deprecated, archived)
   * and per-port feature toggles (e.g. tcp_check on/off).
   */
  async runScan(): Promise<{
    durationMs: number;
    portsChecked: number;
    backendsChecked: number;
    issuesFound: number;
  }> {
    if (this.isScanning) {
      console.log('Scan already in progress, skipping cycle...');
      return { durationMs: 0, portsChecked: 0, backendsChecked: 0, issuesFound: 0 };
    }

    this.isScanning = true;
    const startTime = performance.now();
    sseManager.broadcast('scan_progress', { stage: 'starting', progress: 5 });

    try {
      // Step 1: Host listening sockets
      sseManager.broadcast('scan_progress', { stage: 'inspecting_sockets', progress: 15 });
      const listeningMap = await hostListener.getListeningPorts();

      // Step 2: Probe Ports
      sseManager.broadcast('scan_progress', { stage: 'checking_ports', progress: 35 });
      const dbPorts = await this.prisma.port.findMany({
        include: { features: true }
      });
      const portLimit = pLimit(config.concurrencyLimit);
      const now = new Date();

      let activeScannedCount = 0;

      await Promise.all(
        dbPorts.map((p) =>
          portLimit(async () => {
            // 1. Archived ports are NEVER scanned
            if (p.lifecycle === 'archived' || p.archivedAt) {
              return;
            }

            // 2. Planned / Reserved ports are NOT scanned and NEVER create DOWN alerts
            if (p.lifecycle === 'planned' || p.lifecycle === 'reserved') {
              return;
            }

            // 3. Maintenance ports: check if maintenance window has ended automatically
            let currentLifecycle = p.lifecycle;
            if (currentLifecycle === 'maintenance') {
              if (p.maintenanceTo && now > new Date(p.maintenanceTo)) {
                currentLifecycle = 'active';
                await this.prisma.port.update({
                  where: { id: p.id },
                  data: {
                    lifecycle: 'active',
                    lifecycleReason: 'Maintenance window completed automatically',
                    maintenanceFrom: null,
                    maintenanceTo: null
                  }
                });
                await this.prisma.statusEvent.create({
                  data: {
                    targetType: 'port',
                    targetId: p.id,
                    targetName: `Port ${p.port}`,
                    fromStatus: 'maintenance',
                    toStatus: 'active',
                    details: { reason: 'Maintenance window expired automatically' }
                  }
                });
              }
            }

            // 4. Per-port feature check: TCP check feature toggle
            const tcpFeat = p.features.find((f) => f.featureKey === 'tcp_check');
            const tcpEnabled = tcpFeat !== undefined ? tcpFeat.enabled : true;

            if (!tcpEnabled) {
              // TCP check is disabled for this port, skip probe
              return;
            }

            activeScannedCount++;

            const hostInfo = listeningMap.get(p.port);
            let status: 'up' | 'down' | 'slow' = 'down';
            let latencyMs: number | null = null;

            if (hostInfo) {
              // Local socket is active! Now run TCP connect check to measure true response latency
              const tcpRes = await tcpChecker.check(
                hostInfo.isPublic ? '127.0.0.1' : hostInfo.bindAddress,
                p.port,
                config.tcpTimeoutMs,
                config.slowThresholdMs
              );
              status = tcpRes.status;
              latencyMs = tcpRes.latencyMs;
            } else {
              // Not found in local listening sockets, try direct TCP connect
              const tcpRes = await tcpChecker.check(
                '127.0.0.1',
                p.port,
                1500,
                config.slowThresholdMs
              );
              status = tcpRes.status;
              latencyMs = tcpRes.latencyMs;
            }

            const oldStatus = p.status;

            await this.prisma.port.update({
              where: { id: p.id },
              data: {
                status,
                latencyMs,
                lastCheckedAt: now,
                lastSeenUpAt: status === 'up' || status === 'slow' ? now : p.lastSeenUpAt,
                listenAddress: hostInfo ? hostInfo.bindAddress : p.listenAddress,
                processName: hostInfo?.processName || p.processName,
                pid: hostInfo?.pid || p.pid,
                isPublic: hostInfo ? hostInfo.isPublic : p.isPublic
              }
            });

            // Record time-series check
            await this.prisma.portCheck.create({
              data: {
                targetType: 'port',
                targetId: p.id,
                targetName: `Port ${p.port}`,
                checkedAt: now,
                status,
                latencyMs,
                checkType: 'tcp'
              }
            });

            // Write status event if status changed
            if (oldStatus !== status && oldStatus !== 'unknown') {
              const isMaintenance = currentLifecycle === 'maintenance';
              await this.recordStatusEvent(
                'port',
                p.id,
                `Port ${p.port}`,
                oldStatus,
                status,
                isMaintenance // mute alerts if in maintenance
              );
            }
          })
        )
      );

      // Step 3: Probe Backends
      sseManager.broadcast('scan_progress', { stage: 'checking_backends', progress: 65 });
      const dbBackends = await this.prisma.backend.findMany({
        where: { archivedAt: null }
      });
      const backendLimit = pLimit(config.concurrencyLimit);

      await Promise.all(
        dbBackends.map((b) =>
          backendLimit(async () => {
            const hostToProbe = b.host === 'localhost' ? '127.0.0.1' : b.host;
            const res = await tcpChecker.check(
              hostToProbe,
              b.port,
              config.tcpTimeoutMs,
              config.slowThresholdMs
            );

            const oldStatus = b.status;

            await this.prisma.backend.update({
              where: { id: b.id },
              data: {
                status: res.status,
                latencyMs: res.latencyMs,
                lastCheckedAt: now
              }
            });

            await this.prisma.portCheck.create({
              data: {
                targetType: 'backend',
                targetId: b.id,
                targetName: `${b.host}:${b.port}`,
                checkedAt: now,
                status: res.status,
                latencyMs: res.latencyMs,
                checkType: 'tcp',
                error: res.error
              }
            });

            if (oldStatus !== res.status && oldStatus !== 'unknown') {
              await this.recordStatusEvent('backend', b.id, `${b.host}:${b.port}`, oldStatus, res.status, false);
            }
          })
        )
      );

      // Step 4: Check TLS certificates for HTTPS domains
      sseManager.broadcast('scan_progress', { stage: 'checking_certificates', progress: 80 });
      const httpsRoutes = await this.prisma.route.findMany({
        where: {
          protocol: 'HTTPS',
          archivedAt: null,
          domain: { not: '(catch-all)' }
        },
        distinct: ['domain']
      });

      const certResults: CertificateInfo[] = [];
      const certLimit = pLimit(10);
      await Promise.all(
        httpsRoutes.slice(0, 20).map((r) =>
          certLimit(async () => {
            try {
              const cert = await certChecker.check(r.domain, r.portNum || 443, 3000);
              certResults.push(cert);
            } catch (e) {
              // Ignore probe failure
            }
          })
        )
      );
      this.cachedCerts = certResults;

      // Step 5: Issue detection
      sseManager.broadcast('scan_progress', { stage: 'analyzing_health', progress: 90 });
      await issueDetector.evaluate(this.prisma, listeningMap, this.cachedCerts);

      // Step 6: Retention cleanup (older than retentionDays)
      const retentionThreshold = new Date();
      retentionThreshold.setDate(retentionThreshold.getDate() - config.retentionDays);
      await this.prisma.portCheck.deleteMany({
        where: { checkedAt: { lt: retentionThreshold } }
      });

      const durationMs = Math.round(performance.now() - startTime);
      this.lastScanTime = new Date();

      sseManager.broadcast('scan_complete', {
        durationMs,
        portsChecked: activeScannedCount,
        backendsChecked: dbBackends.length,
        timestamp: this.lastScanTime
      });

      return {
        durationMs,
        portsChecked: activeScannedCount,
        backendsChecked: dbBackends.length,
        issuesFound: await this.prisma.issue.count({ where: { status: 'open' } })
      };
    } finally {
      this.isScanning = false;
    }
  }

  /**
   * Check a single target (port or backend) on demand.
   */
  async checkTarget(type: 'port' | 'backend', id: string) {
    if (type === 'port') {
      const port = await this.prisma.port.findUnique({ where: { id } });
      if (!port) throw new Error('Port not found');

      const tcpRes = await tcpChecker.check(
        port.listenAddress && port.listenAddress !== '0.0.0.0' ? port.listenAddress : '127.0.0.1',
        port.port,
        config.tcpTimeoutMs,
        config.slowThresholdMs
      );

      const oldStatus = port.status;
      const now = new Date();

      await this.prisma.port.update({
        where: { id },
        data: {
          status: tcpRes.status,
          latencyMs: tcpRes.latencyMs,
          lastCheckedAt: now,
          lastSeenUpAt: tcpRes.status === 'up' || tcpRes.status === 'slow' ? now : port.lastSeenUpAt
        }
      });

      await this.prisma.portCheck.create({
        data: {
          targetType: 'port',
          targetId: port.id,
          targetName: `Port ${port.port}`,
          checkedAt: now,
          status: tcpRes.status,
          latencyMs: tcpRes.latencyMs,
          checkType: 'tcp'
        }
      });

      if (oldStatus !== tcpRes.status) {
        const isMaintenance = port.lifecycle === 'maintenance';
        await this.recordStatusEvent('port', port.id, `Port ${port.port}`, oldStatus, tcpRes.status, isMaintenance);
      }

      return { port: port.port, ...tcpRes };
    } else {
      const backend = await this.prisma.backend.findUnique({ where: { id } });
      if (!backend) throw new Error('Backend not found');

      const hostToProbe = backend.host === 'localhost' ? '127.0.0.1' : backend.host;
      const tcpRes = await tcpChecker.check(
        hostToProbe,
        backend.port,
        config.tcpTimeoutMs,
        config.slowThresholdMs
      );

      const oldStatus = backend.status;
      const now = new Date();

      await this.prisma.backend.update({
        where: { id },
        data: {
          status: tcpRes.status,
          latencyMs: tcpRes.latencyMs,
          lastCheckedAt: now
        }
      });

      await this.prisma.portCheck.create({
        data: {
          targetType: 'backend',
          targetId: backend.id,
          targetName: `${backend.host}:${backend.port}`,
          checkedAt: now,
          status: tcpRes.status,
          latencyMs: tcpRes.latencyMs,
          checkType: 'tcp',
          error: tcpRes.error
        }
      });

      if (oldStatus !== tcpRes.status) {
        await this.recordStatusEvent('backend', backend.id, `${backend.host}:${backend.port}`, oldStatus, tcpRes.status, false);
      }

      return { host: backend.host, port: backend.port, ...tcpRes };
    }
  }

  private async recordStatusEvent(
    targetType: string,
    targetId: string,
    targetName: string,
    fromStatus: string,
    toStatus: string,
    muteAlerts: boolean = false
  ) {
    const event = await this.prisma.statusEvent.create({
      data: {
        targetType,
        targetId,
        targetName,
        fromStatus,
        toStatus,
        at: new Date()
      }
    });

    // Broadcast status change immediately over SSE
    sseManager.broadcast('status_change', {
      targetType,
      targetId,
      targetName,
      fromStatus,
      toStatus,
      at: event.at
    });

    // Evaluate alerts if not muted
    if (!muteAlerts) {
      await this.evaluateAlert(targetName, fromStatus, toStatus);
    }
  }

  private async evaluateAlert(targetName: string, fromStatus: string, toStatus: string) {
    if (toStatus === 'down') {
      const rules = await this.prisma.alertRule.findMany({
        where: { isEnabled: true, eventType: 'down_duration' }
      });

      for (const rule of rules) {
        for (const channel of rule.channels) {
          await this.prisma.alertLog.create({
            data: {
              ruleId: rule.id,
              title: `Alert: ${targetName} is DOWN`,
              message: `Status changed from ${fromStatus} to ${toStatus} on ${new Date().toISOString()}`,
              channel,
              status: 'simulated'
            }
          });
        }
      }
    }
  }
}
