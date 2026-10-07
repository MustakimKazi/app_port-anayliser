import { PrismaClient } from '@prisma/client';
import { getAllFeatures } from './registry.js';

export interface BuiltinPreset {
  name: string;
  description: string;
  features: Record<string, { enabled: boolean; config?: Record<string, any> }>;
}

export const BUILTIN_PRESETS: BuiltinPreset[] = [
  {
    name: 'Public HTTPS site',
    description: 'Standard configuration for external HTTPS web services and APIs',
    features: {
      tcp_check: { enabled: true, config: { intervalSec: 30, timeoutMs: 3000, failuresBeforeDown: 3 } },
      http_check: { enabled: true, config: { path: '/', followRedirects: true, slowThresholdMs: 1500 } },
      tls_cert_check: { enabled: true, config: { warnDays: 30, checkChain: true } },
      process_check: { enabled: false },
      bind_check: { enabled: false, config: { expectedBind: '0.0.0.0', alertIfPublic: false } },
      alerts: { enabled: true, config: { channels: ['log'], repeatIntervalMin: 60, severity: 'High' } },
      maintenance_window: { enabled: false },
      latency_baseline: { enabled: false },
      dependency_tracking: { enabled: true, config: { includeInGraph: true, includeInBlastRadius: true } },
      dashboard_pinned: { enabled: false },
      custom_runbook: { enabled: false },
      retention: { enabled: true, config: { retentionDays: null } }
    }
  },
  {
    name: 'Internal HTTP app',
    description: 'Internal HTTP service bound to localhost or private network (alerts on public bind)',
    features: {
      tcp_check: { enabled: true, config: { intervalSec: 30, timeoutMs: 3000, failuresBeforeDown: 3 } },
      http_check: { enabled: true, config: { path: '/', followRedirects: true, slowThresholdMs: 1500 } },
      tls_cert_check: { enabled: false },
      process_check: { enabled: false },
      bind_check: { enabled: true, config: { expectedBind: '127.0.0.1', alertIfPublic: true } },
      alerts: { enabled: true, config: { channels: ['log'], repeatIntervalMin: 60, severity: 'High' } },
      maintenance_window: { enabled: false },
      latency_baseline: { enabled: false },
      dependency_tracking: { enabled: true, config: { includeInGraph: true, includeInBlastRadius: true } },
      dashboard_pinned: { enabled: false },
      custom_runbook: { enabled: false },
      retention: { enabled: true, config: { retentionDays: null } }
    }
  },
  {
    name: 'Redis (private only)',
    description: 'In-memory Redis cache instance: TCP probe, process verification, strictly private bind',
    features: {
      tcp_check: { enabled: true, config: { intervalSec: 15, timeoutMs: 2000, failuresBeforeDown: 2 } },
      http_check: { enabled: false },
      tls_cert_check: { enabled: false },
      process_check: { enabled: true, config: { expectedProcessName: 'redis-server', alertOnChange: true } },
      bind_check: { enabled: true, config: { expectedBind: '127.0.0.1', alertIfPublic: true } },
      alerts: { enabled: true, config: { channels: ['log'], repeatIntervalMin: 30, severity: 'High' } },
      maintenance_window: { enabled: false },
      latency_baseline: { enabled: false },
      dependency_tracking: { enabled: true, config: { includeInGraph: true, includeInBlastRadius: true } },
      dashboard_pinned: { enabled: false },
      custom_runbook: { enabled: false },
      retention: { enabled: true, config: { retentionDays: null } }
    }
  },
  {
    name: 'MongoDB (private only)',
    description: 'MongoDB document database: fast probe, process checking, alerts on public bind',
    features: {
      tcp_check: { enabled: true, config: { intervalSec: 15, timeoutMs: 2000, failuresBeforeDown: 2 } },
      http_check: { enabled: false },
      tls_cert_check: { enabled: false },
      process_check: { enabled: true, config: { expectedProcessName: 'mongod', alertOnChange: true } },
      bind_check: { enabled: true, config: { expectedBind: '127.0.0.1', alertIfPublic: true } },
      alerts: { enabled: true, config: { channels: ['log'], repeatIntervalMin: 30, severity: 'High' } },
      maintenance_window: { enabled: false },
      latency_baseline: { enabled: false },
      dependency_tracking: { enabled: true, config: { includeInGraph: true, includeInBlastRadius: true } },
      dashboard_pinned: { enabled: false },
      custom_runbook: { enabled: false },
      retention: { enabled: true, config: { retentionDays: null } }
    }
  },
  {
    name: 'PostgreSQL (private only)',
    description: 'PostgreSQL relational database: connection probe, strictly internal bind',
    features: {
      tcp_check: { enabled: true, config: { intervalSec: 15, timeoutMs: 2000, failuresBeforeDown: 2 } },
      http_check: { enabled: false },
      tls_cert_check: { enabled: false },
      process_check: { enabled: true, config: { expectedProcessName: 'postgres', alertOnChange: true } },
      bind_check: { enabled: true, config: { expectedBind: '127.0.0.1', alertIfPublic: true } },
      alerts: { enabled: true, config: { channels: ['log'], repeatIntervalMin: 30, severity: 'High' } },
      maintenance_window: { enabled: false },
      latency_baseline: { enabled: false },
      dependency_tracking: { enabled: true, config: { includeInGraph: true, includeInBlastRadius: true } },
      dashboard_pinned: { enabled: false },
      custom_runbook: { enabled: false },
      retention: { enabled: true, config: { retentionDays: null } }
    }
  },
  {
    name: 'SSH',
    description: 'Secure Shell remote administration socket (sshd process and port probe)',
    features: {
      tcp_check: { enabled: true, config: { intervalSec: 60, timeoutMs: 3000, failuresBeforeDown: 3 } },
      http_check: { enabled: false },
      tls_cert_check: { enabled: false },
      process_check: { enabled: true, config: { expectedProcessName: 'sshd', alertOnChange: true } },
      bind_check: { enabled: false },
      alerts: { enabled: true, config: { channels: ['log'], repeatIntervalMin: 60, severity: 'High' } },
      maintenance_window: { enabled: false },
      latency_baseline: { enabled: false },
      dependency_tracking: { enabled: true, config: { includeInGraph: true, includeInBlastRadius: true } },
      dashboard_pinned: { enabled: false },
      custom_runbook: { enabled: false },
      retention: { enabled: true, config: { retentionDays: null } }
    }
  },
  {
    name: 'Static/redirect only',
    description: 'Simple static content or redirect gateway port without backend dependency',
    features: {
      tcp_check: { enabled: true, config: { intervalSec: 60, timeoutMs: 3000, failuresBeforeDown: 3 } },
      http_check: { enabled: true, config: { path: '/', followRedirects: true } },
      tls_cert_check: { enabled: true, config: { warnDays: 30 } },
      process_check: { enabled: false },
      bind_check: { enabled: false },
      alerts: { enabled: true, config: { channels: ['log'], repeatIntervalMin: 120, severity: 'Medium' } },
      maintenance_window: { enabled: false },
      latency_baseline: { enabled: false },
      dependency_tracking: { enabled: true, config: { includeInGraph: true, includeInBlastRadius: true } },
      dashboard_pinned: { enabled: false },
      custom_runbook: { enabled: false },
      retention: { enabled: true, config: { retentionDays: null } }
    }
  },
  {
    name: 'Planned (no scanning)',
    description: 'Future reserved or planned port: all automated probes and alerts deactivated',
    features: {
      tcp_check: { enabled: false },
      http_check: { enabled: false },
      tls_cert_check: { enabled: false },
      process_check: { enabled: false },
      bind_check: { enabled: false },
      alerts: { enabled: false },
      maintenance_window: { enabled: false },
      latency_baseline: { enabled: false },
      dependency_tracking: { enabled: true, config: { includeInGraph: true, includeInBlastRadius: true } },
      dashboard_pinned: { enabled: false },
      custom_runbook: { enabled: false },
      retention: { enabled: true, config: { retentionDays: null } }
    }
  }
];

// Ensure builtin presets exist in database
export async function seedBuiltinPresets(prisma: PrismaClient) {
  for (const preset of BUILTIN_PRESETS) {
    const existing = await prisma.featurePreset.findUnique({
      where: { name: preset.name }
    });
    if (!existing) {
      await prisma.featurePreset.create({
        data: {
          name: preset.name,
          description: preset.description,
          isBuiltin: true,
          features: preset.features
        }
      });
    }
  }
}

// Backfill existing ports with default features according to their layer and protocol
export async function backfillPortFeatures(prisma: PrismaClient) {
  const ports = await prisma.port.findMany({
    include: { features: true }
  });

  const allRegistryFeatures = getAllFeatures();

  for (const port of ports) {
    const existingKeys = new Set(port.features.map(f => f.featureKey));
    const toCreate: Array<{
      portId: string;
      featureKey: string;
      enabled: boolean;
      config: any;
    }> = [];

    for (const feat of allRegistryFeatures) {
      if (!existingKeys.has(feat.key)) {
        const isPlanned = port.lifecycle === 'planned' || port.lifecycle === 'reserved';
        toCreate.push({
          portId: port.id,
          featureKey: feat.key,
          enabled: isPlanned ? false : feat.defaultEnabled(port.layer, port.protocol),
          config: feat.defaultConfig
        });
      }
    }

    if (toCreate.length > 0) {
      for (const item of toCreate) {
        await prisma.portFeature.create({
          data: item
        });
      }
    }
  }
}
