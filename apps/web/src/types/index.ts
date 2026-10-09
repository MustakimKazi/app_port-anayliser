export type StatusType = 'up' | 'down' | 'slow' | 'unknown';
export type LayerType = 'http' | 'stream';
export type ProtocolType = 'HTTP' | 'HTTPS' | 'TCP' | 'UDP';
export type ActionType = 'Proxy' | 'Static' | 'Redirect' | 'Return' | 'Status';
export type PriorityType = 'High' | 'Medium' | 'Low' | 'Info';
export type IssueStatus = 'open' | 'acknowledged' | 'resolved' | 'ignored';
export type LifecycleType = 'planned' | 'reserved' | 'active' | 'maintenance' | 'deprecated' | 'archived';

export interface Port {
  id: string;
  port: number;
  serverId?: string | null;
  serverName?: string | null;
  server?: Server | null;
  layer: LayerType;
  protocol: ProtocolType;
  purpose: string | null;
  processName: string | null;
  pid: number | null;
  listenAddress: string | null;
  expectedBind?: string | null;
  isPublic: boolean;
  isExpected: boolean;
  isDocumented?: boolean;
  lifecycle: LifecycleType;
  lifecycleReason?: string | null;
  targetDate?: string | null;
  owner?: string | null;
  maintenanceFrom?: string | null;
  maintenanceTo?: string | null;
  archivedAt?: string | null;
  archivedBy?: string | null;
  status: StatusType;
  latencyMs: number | null;
  lastCheckedAt: string | null;
  lastSeenUpAt: string | null;
  tags: string[];
  notes: string | null;
  customValues: Record<string, any> | null;
  routeCount: number;
  domainsList: string;
  backendCount: number;
  openIssueCount: number;
  hasHighIssue: boolean;
  routes?: Route[];
  issues?: Issue[];
  features?: PortFeature[];
}

export interface PortFeature {
  id?: string;
  portId?: string;
  featureKey: string;
  enabled: boolean;
  config?: any;
}

export interface FeatureItem {
  key: string;
  label: string;
  description: string;
  settingsSchema: any;
  defaultConfig: any;
  applicableLayers?: string[];
  applicableProtocols?: string[];
  enabled: boolean;
  config: any;
  globallyEnabled: boolean;
  usedCount?: number;
}

export interface FeaturePreset {
  id: string;
  name: string;
  description: string | null;
  isBuiltin: boolean;
  features: Record<string, { enabled: boolean; config?: any }>;
}

export interface ImpactPreview {
  port?: { id: string; port: number; lifecycle: string; purpose: string | null };
  routesCount: number;
  routes: Route[];
  domainsCount: number;
  domains: string[];
  orphanedBackendsCount?: number;
  orphanedBackends?: Backend[];
  issuesCount: number;
  issues: Issue[];
  historyChecksCount?: number;
  isListening?: boolean;
  warningLevel: 'safe' | 'caution' | 'dangerous';
  notice?: string;
}

export interface Route {
  id: string;
  rowNum: number | null;
  domain: string;
  domainRaw: string | null;
  isCatchAll: boolean;
  portId: string | null;
  portNum: number | null;
  portRaw: string | null;
  protocol: string;
  path: string;
  paths: string[];
  action: ActionType;
  targetRaw: string | null;
  targetType: 'url' | 'upstream' | 'variable' | 'static_root' | 'redirect' | 'status' | 'unknown';
  backendId: string | null;
  backend?: Backend | null;
  staticRoot: string | null;
  redirectCode: number | null;
  configFileId: string | null;
  configFile?: ConfigFile | null;
  notes: string | null;
  flags: {
    websocket?: boolean;
    rateLimit?: boolean;
    hasUploadLimit?: boolean;
    maxUploadSize?: string | null;
    [key: string]: any;
  } | null;
  customValues?: Record<string, any> | null;
  archivedAt?: string | null;
  archivedBy?: string | null;
}

export interface Backend {
  id: string;
  serverId: string | null;
  server?: Server | null;
  host: string;
  port: number;
  label: string | null;
  notes: string | null;
  status: StatusType;
  latencyMs: number | null;
  lastCheckedAt: string | null;
  customValues?: Record<string, any> | null;
  routes?: Route[];
  archivedAt?: string | null;
  archivedBy?: string | null;
}

export interface Server {
  id: string;
  name: string;
  host: string;
  kind: 'nginx-host' | 'backend' | 'lan' | 'local';
  groupLabel: string | null;
  notes: string | null;
  tags: string[];
  customValues?: Record<string, any> | null;
  backends?: Backend[];
  ports?: Port[];
  archivedAt?: string | null;
  archivedBy?: string | null;
}

export interface ConfigFile {
  id: string;
  filename: string;
  status: 'active' | 'backup' | 'archived';
  description: string | null;
  content?: string | null;
  hasContent?: boolean;
  contentLength?: number;
  createdAt?: string;
  updatedAt?: string;
  routes?: Array<{
    id: string;
    domain: string;
    path: string;
    portNum: number | null;
    action: string;
  }>;
}

export interface Issue {
  id: string;
  issueNum: number | null;
  priority: PriorityType;
  title: string;
  observed: string;
  recommendation: string;
  status: IssueStatus;
  relatedPortId: string | null;
  relatedPort?: Port | null;
  relatedRouteId: string | null;
  relatedRoute?: Route | null;
  source: 'imported' | 'auto-detected' | 'manual';
  autoKey: string | null;
  assignee: string | null;
  comments: Array<{
    author: string;
    text: string;
    at: string;
  }> | null;
  resolvedAt: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface PortCheck {
  id: string;
  targetType: string;
  targetId: string;
  targetName: string | null;
  checkedAt: string;
  status: StatusType;
  latencyMs: number | null;
  error: string | null;
  checkType: string;
}

export interface StatusEvent {
  id: string;
  targetType: string;
  targetId: string;
  targetName: string;
  fromStatus: string;
  toStatus: string;
  at: string;
  details?: any;
}

export interface CertificateInfo {
  domain: string;
  port: number;
  subject: string;
  issuer: string;
  validFrom: string;
  validTo: string;
  daysRemaining: number;
  isExpiringSoon: boolean;
  status: 'valid' | 'expiring_soon' | 'critical' | 'expired' | 'error';
  error?: string;
  // Deep-probe fields (Phase 2)
  san?: string;
  serialNumber?: string;
  fingerprint256?: string;
  signatureAlgorithm?: string;
  protocol?: string;
  cipher?: string;
}

export interface CustomField {
  id: string;
  entityType: 'port' | 'route' | 'backend' | 'server';
  name: string;
  key: string;
  fieldType: 'text' | 'number' | 'select' | 'multi-select' | 'boolean' | 'date' | 'url';
  options: string[] | null;
  required: boolean;
  defaultValue: string | null;
}

export interface SavedView {
  id: string;
  name: string;
  page: string;
  filterJson: Record<string, any>;
  isShared: boolean;
}

export interface OverviewData {
  kpis: {
    totalPorts: number;
    upPorts: number;
    downPorts: number;
    slowPorts: number;
    unknownPorts: number;
    lifecycles: {
      planned: number;
      reserved: number;
      active: number;
      maintenance: number;
      deprecated: number;
      archived: number;
    };
    openIssues: {
      total: number;
      high: number;
      medium: number;
      low: number;
      info: number;
    };
    totalDomains: number;
    totalBackends: number;
    certsExpiringSoon: number;
  };
  charts: {
    layerDonut: Array<{ name: string; value: number }>;
    actionChart: Array<{ name: string; value: number }>;
    topPorts: Array<{ port: string; count: number; portNum: number }>;
    historyTrend: Array<{ time: string; up: number; down: number; slow: number }>;
  };
  attention: {
    highIssues: Issue[];
    downPorts: Port[];
    expiringCerts: CertificateInfo[];
    overduePlanned?: Port[];
    listeningPlanned?: Port[];
  };
  recentEvents: StatusEvent[];
  scanner: {
    isScanning: boolean;
    lastScanTime: string | null;
    intervalSec: number;
  };
}
