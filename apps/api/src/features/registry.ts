import { PrismaClient } from '@prisma/client';

export interface FeatureDefinition {
  key: string;
  label: string;
  description: string;
  settingsSchema: {
    type: 'object';
    properties: Record<string, {
      type: 'string' | 'number' | 'boolean' | 'array';
      title?: string;
      description?: string;
      default?: any;
      enum?: any[];
      items?: any;
      minimum?: number;
      maximum?: number;
    }>;
    required?: string[];
  };
  defaultConfig: Record<string, any>;
  defaultEnabled: (layer: string, protocol: string) => boolean;
  applicableLayers?: string[];
  applicableProtocols?: string[];
  handler?: (context: any) => Promise<any>;
}

// Registry map of registered features
const featureRegistry = new Map<string, FeatureDefinition>();

// 1. TCP Check
const tcpCheckFeature: FeatureDefinition = {
  key: 'tcp_check',
  label: 'TCP check',
  description: 'Regular TCP socket connect check measuring latency and reachability',
  settingsSchema: {
    type: 'object',
    properties: {
      intervalSec: { type: 'number', title: 'Interval (seconds)', minimum: 10, maximum: 3600, default: 30 },
      timeoutMs: { type: 'number', title: 'Timeout (ms)', minimum: 100, maximum: 10000, default: 3000 },
      failuresBeforeDown: { type: 'number', title: 'Failures Before DOWN', minimum: 1, maximum: 10, default: 3 }
    }
  },
  defaultConfig: {
    intervalSec: 30,
    timeoutMs: 3000,
    failuresBeforeDown: 3
  },
  defaultEnabled: () => true,
  applicableLayers: ['http', 'stream'],
  applicableProtocols: ['HTTP', 'HTTPS', 'TCP', 'UDP']
};

// 2. HTTP / HTTPS Check
const httpCheckFeature: FeatureDefinition = {
  key: 'http_check',
  label: 'HTTP / HTTPS check',
  description: 'Probes HTTP endpoint, validates status code response, content match, and redirect handling',
  settingsSchema: {
    type: 'object',
    properties: {
      path: { type: 'string', title: 'Health Path', default: '/' },
      expectedStatusCodes: { type: 'array', title: 'Expected Status Codes', items: { type: 'number' }, default: [200, 301, 302, 304] },
      expectedText: { type: 'string', title: 'Expected Body Text', default: '' },
      followRedirects: { type: 'boolean', title: 'Follow Redirects', default: true },
      sniHost: { type: 'string', title: 'SNI Host Header', default: '' },
      slowThresholdMs: { type: 'number', title: 'Slow Threshold (ms)', minimum: 100, maximum: 10000, default: 1500 }
    }
  },
  defaultConfig: {
    path: '/',
    expectedStatusCodes: [200, 301, 302, 304],
    expectedText: '',
    followRedirects: true,
    sniHost: '',
    slowThresholdMs: 1500
  },
  defaultEnabled: (layer) => layer.toLowerCase() === 'http',
  applicableLayers: ['http'],
  applicableProtocols: ['HTTP', 'HTTPS']
};

// 3. TLS Certificate Check
const tlsCertCheckFeature: FeatureDefinition = {
  key: 'tls_cert_check',
  label: 'TLS certificate check',
  description: 'Monitors SSL/TLS certificate expiry, validity, and issuer chain',
  settingsSchema: {
    type: 'object',
    properties: {
      warnDays: { type: 'number', title: 'Warning Days Ahead', minimum: 1, maximum: 90, default: 30 },
      checkChain: { type: 'boolean', title: 'Check Certificate Chain', default: true }
    }
  },
  defaultConfig: {
    warnDays: 30,
    checkChain: true
  },
  defaultEnabled: (_layer, protocol) => protocol.toUpperCase() === 'HTTPS',
  applicableLayers: ['http', 'stream'],
  applicableProtocols: ['HTTPS']
};

// 4. Process Check
const processCheckFeature: FeatureDefinition = {
  key: 'process_check',
  label: 'Process check',
  description: 'Verifies expected process name owning socket via socket statistics (ss)',
  settingsSchema: {
    type: 'object',
    properties: {
      expectedProcessName: { type: 'string', title: 'Expected Process Name', default: '' },
      alertOnChange: { type: 'boolean', title: 'Alert If Process Changes', default: true }
    }
  },
  defaultConfig: {
    expectedProcessName: '',
    alertOnChange: true
  },
  defaultEnabled: () => false,
  applicableLayers: ['http', 'stream'],
  applicableProtocols: ['HTTP', 'HTTPS', 'TCP', 'UDP']
};

// 5. Bind Check
const bindCheckFeature: FeatureDefinition = {
  key: 'bind_check',
  label: 'Bind check',
  description: 'Ensures listening socket adheres to expected interface and alerts if accidentally exposed publicly',
  settingsSchema: {
    type: 'object',
    properties: {
      expectedBind: { type: 'string', title: 'Expected Bind Address', default: '0.0.0.0' },
      alertIfPublic: { type: 'boolean', title: 'Alert If Public Interface', default: true }
    }
  },
  defaultConfig: {
    expectedBind: '0.0.0.0',
    alertIfPublic: true
  },
  defaultEnabled: () => false,
  applicableLayers: ['http', 'stream'],
  applicableProtocols: ['HTTP', 'HTTPS', 'TCP', 'UDP']
};

// 6. Alerts
const alertsFeature: FeatureDefinition = {
  key: 'alerts',
  label: 'Alerts',
  description: 'Alert dispatch rules, channels, quiet hours, and severity rating for this port',
  settingsSchema: {
    type: 'object',
    properties: {
      channels: { type: 'array', title: 'Notification Channels', items: { type: 'string' }, default: ['log'] },
      repeatIntervalMin: { type: 'number', title: 'Repeat Interval (min)', minimum: 5, maximum: 1440, default: 60 },
      quietHoursStart: { type: 'string', title: 'Quiet Hours Start (HH:MM)', default: '' },
      quietHoursEnd: { type: 'string', title: 'Quiet Hours End (HH:MM)', default: '' },
      severity: { type: 'string', title: 'Severity', enum: ['High', 'Medium', 'Low', 'Info'], default: 'High' }
    }
  },
  defaultConfig: {
    channels: ['log'],
    repeatIntervalMin: 60,
    quietHoursStart: '',
    quietHoursEnd: '',
    severity: 'High'
  },
  defaultEnabled: () => true,
  applicableLayers: ['http', 'stream'],
  applicableProtocols: ['HTTP', 'HTTPS', 'TCP', 'UDP']
};

// 7. Maintenance Window
const maintenanceWindowFeature: FeatureDefinition = {
  key: 'maintenance_window',
  label: 'Maintenance window',
  description: 'One-off or recurring maintenance schedule that temporarily mutes alerts',
  settingsSchema: {
    type: 'object',
    properties: {
      type: { type: 'string', title: 'Window Type', enum: ['one-off', 'recurring'], default: 'one-off' },
      cron: { type: 'string', title: 'Cron Expression (recurring)', default: '' },
      startTime: { type: 'string', title: 'Start Time (ISO/Timestamp)', default: '' },
      endTime: { type: 'string', title: 'End Time (ISO/Timestamp)', default: '' },
      mutesAlerts: { type: 'boolean', title: 'Mute Alerts During Window', default: true }
    }
  },
  defaultConfig: {
    type: 'one-off',
    cron: '',
    startTime: '',
    endTime: '',
    mutesAlerts: true
  },
  defaultEnabled: () => false,
  applicableLayers: ['http', 'stream'],
  applicableProtocols: ['HTTP', 'HTTPS', 'TCP', 'UDP']
};

// 8. Latency Baseline
const latencyBaselineFeature: FeatureDefinition = {
  key: 'latency_baseline',
  label: 'Latency baseline',
  description: 'Computes rolling average response time and alerts on unexpected latency spikes',
  settingsSchema: {
    type: 'object',
    properties: {
      alertMultiplier: { type: 'number', title: 'Degradation Multiplier', minimum: 1.2, maximum: 10.0, default: 2.0 },
      sampleWindow: { type: 'number', title: 'Sample Window Count', minimum: 5, maximum: 100, default: 20 }
    }
  },
  defaultConfig: {
    alertMultiplier: 2.0,
    sampleWindow: 20
  },
  defaultEnabled: () => false,
  applicableLayers: ['http', 'stream'],
  applicableProtocols: ['HTTP', 'HTTPS', 'TCP', 'UDP']
};

// 9. Dependency Tracking
const dependencyTrackingFeature: FeatureDefinition = {
  key: 'dependency_tracking',
  label: 'Dependency tracking',
  description: 'Includes this port in visual topology graphs, upstream/downstream maps, and blast radius calculation',
  settingsSchema: {
    type: 'object',
    properties: {
      includeInGraph: { type: 'boolean', title: 'Include in Graph', default: true },
      includeInBlastRadius: { type: 'boolean', title: 'Include in Blast Radius', default: true }
    }
  },
  defaultConfig: {
    includeInGraph: true,
    includeInBlastRadius: true
  },
  defaultEnabled: () => true,
  applicableLayers: ['http', 'stream'],
  applicableProtocols: ['HTTP', 'HTTPS', 'TCP', 'UDP']
};

// 10. Pinned / Show on Dashboard
const dashboardPinnedFeature: FeatureDefinition = {
  key: 'dashboard_pinned',
  label: 'Show on dashboard / pinned',
  description: 'Pins port to prominent positions on dashboard attention sections',
  settingsSchema: {
    type: 'object',
    properties: {
      pinToTop: { type: 'boolean', title: 'Pin to Top', default: true },
      order: { type: 'number', title: 'Display Priority Order', default: 0 }
    }
  },
  defaultConfig: {
    pinToTop: true,
    order: 0
  },
  defaultEnabled: () => false,
  applicableLayers: ['http', 'stream'],
  applicableProtocols: ['HTTP', 'HTTPS', 'TCP', 'UDP']
};

// 11. Custom Notes / Runbook Link
const customRunbookFeature: FeatureDefinition = {
  key: 'custom_runbook',
  label: 'Custom notes / runbook link',
  description: 'Incident triage documentation, operational notes, and external runbook URL link',
  settingsSchema: {
    type: 'object',
    properties: {
      notes: { type: 'string', title: 'Runbook Notes', default: '' },
      runbookUrl: { type: 'string', title: 'Runbook URL', default: '' }
    }
  },
  defaultConfig: {
    notes: '',
    runbookUrl: ''
  },
  defaultEnabled: () => false,
  applicableLayers: ['http', 'stream'],
  applicableProtocols: ['HTTP', 'HTTPS', 'TCP', 'UDP']
};

// 12. Retention Policy
const retentionFeature: FeatureDefinition = {
  key: 'retention',
  label: 'Retention',
  description: 'Port-specific check history retention period in days (inherits global setting if blank)',
  settingsSchema: {
    type: 'object',
    properties: {
      retentionDays: { type: 'number', title: 'Retention Days (null to inherit)', default: null }
    }
  },
  defaultConfig: {
    retentionDays: null
  },
  defaultEnabled: () => true,
  applicableLayers: ['http', 'stream'],
  applicableProtocols: ['HTTP', 'HTTPS', 'TCP', 'UDP']
};

// Register a feature dynamically
export function registerFeature(feature: FeatureDefinition) {
  const normalized: FeatureDefinition = {
    ...feature,
    defaultEnabled: typeof feature.defaultEnabled === 'function'
      ? feature.defaultEnabled
      : () => Boolean(feature.defaultEnabled)
  };
  featureRegistry.set(feature.key, normalized);
}

export function unregisterFeature(key: string) {
  featureRegistry.delete(key);
}

export function getFeature(key: string): FeatureDefinition | undefined {
  return featureRegistry.get(key);
}

export function getAllFeatures(): FeatureDefinition[] {
  return Array.from(featureRegistry.values());
}

// Check if a feature is globally enabled in DB
export async function isFeatureGloballyEnabled(prisma: PrismaClient, key: string): Promise<boolean> {
  try {
    const setting = await prisma.registryFeatureSetting.findUnique({
      where: { key }
    });
    return setting ? setting.globallyEnabled : true;
  } catch (e) {
    return true;
  }
}

// Toggle global enable for a feature
export async function setFeatureGloballyEnabled(prisma: PrismaClient, key: string, enabled: boolean): Promise<void> {
  await prisma.registryFeatureSetting.upsert({
    where: { key },
    update: { globallyEnabled: enabled },
    create: { key, globallyEnabled: enabled }
  });
}

// Generates the default features config object for a given port
export function getDefaultFeaturesForPort(layer: string, protocol: string): Record<string, { enabled: boolean; config: Record<string, any> }> {
  const result: Record<string, { enabled: boolean; config: Record<string, any> }> = {};
  for (const feat of featureRegistry.values()) {
    const isFn = typeof feat.defaultEnabled === 'function';
    result[feat.key] = {
      enabled: isFn ? feat.defaultEnabled(layer, protocol) : Boolean(feat.defaultEnabled),
      config: { ...feat.defaultConfig }
    };
  }
  return result;
}

// Initialize standard features
[
  tcpCheckFeature,
  httpCheckFeature,
  tlsCertCheckFeature,
  processCheckFeature,
  bindCheckFeature,
  alertsFeature,
  maintenanceWindowFeature,
  latencyBaselineFeature,
  dependencyTrackingFeature,
  dashboardPinnedFeature,
  customRunbookFeature,
  retentionFeature
].forEach(registerFeature);
