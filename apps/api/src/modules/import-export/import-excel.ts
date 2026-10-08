import * as xlsx from 'xlsx';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

export interface ImportResult {
  serversCount: number;
  configFilesCount: number;
  backendsCount: number;
  portsCount: number;
  routesCount: number;
  issuesCount: number;
  warnings: string[];
}

export interface ParsedWorkbookData {
  configFiles: Array<{
    filename: string;
    status: 'active' | 'backup';
    description: string;
  }>;
  ports: Array<{
    port: number;
    layer: 'http' | 'stream';
    protocol: string;
    purpose: string;
    listenAddress: string;
    isPublic: boolean;
    domainsServicesRaw: string;
  }>;
  backends: Array<{
    host: string;
    port: number;
    notes: string;
    usedByRaw: string;
  }>;
  routes: Array<{
    rowNum: number;
    domainRaw: string;
    domain: string;
    isCatchAll: boolean;
    portRaw: string;
    portNum: number | null;
    protocol: string;
    path: string;
    paths: string[];
    action: string;
    targetRaw: string;
    targetType: string;
    staticRoot: string | null;
    redirectCode: number | null;
    backendHost: string | null;
    backendPort: number | null;
    configFile: string | null;
    notes: string;
    flags: Record<string, any>;
  }>;
  issues: Array<{
    issueNum: number;
    priority: string;
    title: string;
    observed: string;
    recommendation: string;
    source: string;
  }>;
}

export function parseWorkbook(wb: xlsx.WorkBook): ParsedWorkbookData {
  // 1. Config Files
  const configFilesSheet = wb.Sheets['Config Files'];
  const rawConfigFiles = configFilesSheet
    ? xlsx.utils.sheet_to_json<any>(configFilesSheet, { defval: '' })
    : [];

  const configFiles: ParsedWorkbookData['configFiles'] = rawConfigFiles
    .filter(r => r['Config File'] && String(r['Config File']).trim())
    .map(r => {
      const filename = String(r['Config File']).trim();
      const statusRaw = String(r['Status'] || '').toLowerCase();
      const status: 'active' | 'backup' = statusRaw.includes('backup') ? 'backup' : 'active';
      const description = String(r['Domains / Purpose'] || '').trim();
      return { filename, status, description };
    });

  // 2. Port Summary
  const portSummarySheet = wb.Sheets['Port Summary'];
  const rawPorts = portSummarySheet
    ? xlsx.utils.sheet_to_json<any>(portSummarySheet, { defval: '' })
    : [];

  const ports: ParsedWorkbookData['ports'] = rawPorts
    .filter(r => r['Port'] !== '' && !isNaN(parseInt(String(r['Port']))))
    .map(r => {
      const port = parseInt(String(r['Port']));
      const layerRaw = String(r['Layer'] || '').toLowerCase();
      const layer: 'http' | 'stream' = layerRaw.includes('stream') ? 'stream' : 'http';
      let protocol = String(r['Protocol'] || '').trim();
      if (!protocol) {
        protocol = layer === 'stream' ? 'TCP' : (port === 443 ? 'HTTPS' : 'HTTP');
      }
      const purpose = String(r['Purpose'] || '').trim();
      const domainsServicesRaw = String(r['Domains / Services using this port'] || '').trim();

      // Listen address and public flag
      const isPublic = port !== 8080; // 8080 stub_status is local
      const listenAddress = port === 8080 ? '127.0.0.1' : '0.0.0.0';

      return {
        port,
        layer,
        protocol,
        purpose,
        listenAddress,
        isPublic,
        domainsServicesRaw
      };
    });

  // 3. Backends
  const backendsSheet = wb.Sheets['Backends'];
  const rawBackends = backendsSheet
    ? xlsx.utils.sheet_to_json<any>(backendsSheet, { defval: '' })
    : [];

  const backends: ParsedWorkbookData['backends'] = rawBackends
    .filter(r => r['Backend Host'] && r['Backend Port'] !== '')
    .map(r => {
      const host = String(r['Backend Host']).trim();
      const port = parseInt(String(r['Backend Port']));
      const notes = String(r['Notes'] || '').trim();
      const usedByRaw = String(r['Used By (domain + path)'] || '').trim();
      return { host, port, notes, usedByRaw };
    });

  // 4. Domain Map
  const domainMapSheet = wb.Sheets['Domain Map'];
  const rawRoutes = domainMapSheet
    ? xlsx.utils.sheet_to_json<any>(domainMapSheet, { defval: '' })
    : [];

  const routes: ParsedWorkbookData['routes'] = rawRoutes
    .filter(r => r['Domain'] !== '' || r['#'] !== '')
    .map((r, idx) => {
      const rowNum = parseInt(String(r['#'])) || (idx + 1);
      const domainRaw = String(r['Domain'] || '').trim();
      const isCatchAll =
        domainRaw.toLowerCase().includes('server_name _') ||
        domainRaw.toLowerCase().includes('catch-all');

      let domain = domainRaw
        .replace(/\s*\(server_name _\)/i, '')
        .replace(/\s*\(catch-all.*?\)/i, '')
        .replace(/^\(|\)$/g, '')
        .trim();

      if (!domain) {
        domain = '(catch-all)';
      }

      const portRaw = String(r['Port'] || '').trim();
      const portParsed = parseInt(portRaw);
      const portNum = isNaN(portParsed) ? null : portParsed;

      const protocol = String(r['Protocol'] || 'HTTP').trim();
      const pathRaw = String(r['Path'] || '/').trim();
      const paths = pathRaw
        .split(/[,\n]/)
        .map(p => p.trim())
        .filter(Boolean);

      const action = String(r['Action'] || 'Proxy').trim();
      const targetRaw = String(r['Target / Backend'] || '').trim();

      // Target type detection
      let targetType = 'unknown';
      let staticRoot: string | null = null;
      let redirectCode: number | null = null;

      const targetLower = targetRaw.toLowerCase();
      const backendHostRaw = String(r['Backend Host'] || '');
      if (targetLower.startsWith('upstream:') || targetLower.includes('upstream')) {
        targetType = 'upstream';
      } else if (
        targetLower.includes('(variable)') ||
        targetRaw.includes('$') ||
        backendHostRaw.includes('variable') ||
        backendHostRaw.includes('$')
      ) {
        targetType = 'variable';
      } else if (targetLower.includes('(not captured)') || targetLower.includes('not captured') || !targetRaw) {
        targetType = 'unknown';
      } else if (action === 'Static' || targetLower.startsWith('root ')) {
        targetType = 'static_root';
        if (targetLower.startsWith('root ')) {
          staticRoot = targetRaw.slice(5).trim();
        } else {
          staticRoot = targetRaw;
        }
      } else if (
        action === 'Redirect' ||
        action === 'Return' ||
        targetLower.startsWith('301') ||
        targetLower.startsWith('302') ||
        targetLower.startsWith('return')
      ) {
        targetType = 'redirect';
        if (targetLower.startsWith('301')) redirectCode = 301;
        else if (targetLower.startsWith('302')) redirectCode = 302;
        else if (targetLower.startsWith('return 301')) redirectCode = 301;
        else if (targetLower.startsWith('return 302')) redirectCode = 302;
      } else if (action === 'Status' || targetLower.includes('stub_status')) {
        targetType = 'status';
      } else if (targetLower.startsWith('http://') || targetLower.startsWith('https://')) {
        targetType = 'url';
      }

      const backendHost = r['Backend Host'] ? String(r['Backend Host']).trim() : null;
      const backendPortParsed = parseInt(String(r['Backend Port']));
      const backendPort = isNaN(backendPortParsed) ? null : backendPortParsed;

      const configFile = r['Config File (/etc/nginx/conf.d/)']
        ? String(r['Config File (/etc/nginx/conf.d/)']).trim()
        : null;

      const notes = String(r['Notes'] || '').trim();
      const flags: Record<string, any> = {
        websocket: notes.toLowerCase().includes('websocket'),
        rateLimit: notes.toLowerCase().includes('rate limit') || notes.toLowerCase().includes('zone'),
        hasUploadLimit: /client_max_body_size|\d+[MmGg][Bb]?/.test(notes)
      };

      const maxUploadMatch = notes.match(/\b(\d+[MmGg][Bb]?)\b/);
      if (maxUploadMatch) {
        flags.maxUploadSize = maxUploadMatch[1];
      }

      return {
        rowNum,
        domainRaw,
        domain,
        isCatchAll,
        portRaw,
        portNum,
        protocol,
        path: pathRaw,
        paths: paths.length > 0 ? paths : [pathRaw],
        action,
        targetRaw,
        targetType,
        staticRoot,
        redirectCode,
        backendHost,
        backendPort,
        configFile,
        notes,
        flags
      };
    });

  // 5. Issues & Checks
  const issuesSheet = wb.Sheets['Issues & Checks'];
  const rawIssues = issuesSheet
    ? xlsx.utils.sheet_to_json<any>(issuesSheet, { defval: '' })
    : [];

  const issues: ParsedWorkbookData['issues'] = rawIssues
    .filter(r => r['Item'] || r['#'])
    .map((r, idx) => {
      const issueNum = parseInt(String(r['#'])) || (idx + 1);
      const priority = String(r['Priority'] || 'Medium').trim();
      const title = String(r['Item'] || '').trim();
      const observed = String(r['What was seen'] || '').trim();
      const recommendation = String(r['What to check / do'] || '').trim();
      return {
        issueNum,
        priority,
        title,
        observed,
        recommendation,
        source: 'imported'
      };
    });

  const parsed = { configFiles, ports, backends, routes, issues };
  const totalRows =
    parsed.configFiles.length +
    parsed.ports.length +
    parsed.backends.length +
    parsed.routes.length +
    parsed.issues.length;

  if (totalRows === 0) {
    const err: any = new Error(
      'Workbook contains no importable rows (expected sheets such as ' +
        '"Config Files", "Port Summary", "Domain Map"). Import aborted — nothing was changed.'
    );
    err.code = 'EMPTY_WORKBOOK';
    throw err;
  }

  return parsed;
}

export async function importParsedData(
  prisma: PrismaClient,
  data: ParsedWorkbookData
): Promise<ImportResult> {
  const warnings: string[] = [];

  // Step 1: Ensure default 5 Server Groups
  const defaultServers = [
    {
      name: 'Server A (App Backend)',
      host: '10.0.0.100',
      kind: 'backend',
      groupLabel: 'Group A',
      notes: 'Backend server A'
    },
    {
      name: 'Server B (Service Backend)',
      host: '10.0.0.200',
      kind: 'backend',
      groupLabel: 'Group B',
      notes: 'Backend server B'
    },
    {
      name: 'Server C (LAN Node 1)',
      host: '192.168.1.221',
      kind: 'lan',
      groupLabel: 'Group C (LAN)',
      notes: 'Backend server C (LAN)'
    },
    {
      name: 'Server D (LAN Node 2)',
      host: '192.168.1.222',
      kind: 'lan',
      groupLabel: 'Group D (LAN)',
      notes: 'Backend server D (LAN)'
    },
    {
      name: 'Localhost (Nginx Server)',
      host: 'localhost',
      kind: 'nginx-host',
      groupLabel: 'Localhost',
      notes: 'Runs on this nginx server itself'
    }
  ];

  const serverMap = new Map<string, string>(); // host -> id
  for (const s of defaultServers) {
    const existing = await prisma.server.findFirst({
      where: { host: s.host }
    });
    if (existing) {
      serverMap.set(s.host, existing.id);
    } else {
      const created = await prisma.server.create({
        data: s
      });
      serverMap.set(s.host, created.id);
    }
  }

  // Step 2: Config Files
  const configFileMap = new Map<string, string>(); // filename -> id
  for (const cf of data.configFiles) {
    const upserted = await prisma.configFile.upsert({
      where: { filename: cf.filename },
      update: {
        status: cf.status,
        description: cf.description
      },
      create: {
        filename: cf.filename,
        status: cf.status,
        description: cf.description
      }
    });
    configFileMap.set(cf.filename, upserted.id);
  }

  // Step 3: Backends
  const backendMap = new Map<string, string>(); // "host:port" -> id
  for (const b of data.backends) {
    let serverId = serverMap.get(b.host) || null;
    if (!serverId && (b.host === '127.0.0.1' || b.host === 'localhost')) {
      serverId = serverMap.get('localhost') || null;
    }

    const key = `${b.host}:${b.port}`;
    const upserted = await prisma.backend.upsert({
      where: {
        host_port: {
          host: b.host,
          port: b.port
        }
      },
      update: {
        serverId,
        notes: b.notes,
        label: key
      },
      create: {
        host: b.host,
        port: b.port,
        serverId,
        notes: b.notes,
        label: key,
        status: 'unknown'
      }
    });
    backendMap.set(key, upserted.id);
  }

  // Step 4: Ports
  const portMap = new Map<number, string>(); // portNum -> id
  for (const p of data.ports) {
    const existing = await prisma.port.findFirst({
      where: { port: p.port, archivedAt: null }
    });
    let portId: string;
    if (existing) {
      await prisma.port.update({
        where: { id: existing.id },
        data: {
          layer: p.layer,
          protocol: p.protocol,
          purpose: p.purpose,
          listenAddress: p.listenAddress,
          isPublic: p.isPublic
        }
      });
      portId = existing.id;
    } else {
      const created = await prisma.port.create({
        data: {
          port: p.port,
          layer: p.layer,
          protocol: p.protocol,
          purpose: p.purpose,
          listenAddress: p.listenAddress,
          isPublic: p.isPublic,
          isExpected: true,
          status: 'unknown',
          tags: p.layer === 'stream' ? ['stream', 'tcp'] : ['http']
        }
      });
      portId = created.id;
    }
    portMap.set(p.port, portId);
  }

  // Step 5: Routes (Domain Map - 106 rows)
  // Replace only the routes contained in this workbook (matched by rowNum) so a
  // partial or empty import can never wipe rows that were not re-imported.
  const importedRowNums = data.routes.map((r) => r.rowNum);
  if (importedRowNums.length > 0) {
    await prisma.route.deleteMany({ where: { rowNum: { in: importedRowNums } } });
  } else {
    warnings.push('Workbook had no Domain Map rows — existing routes were left untouched');
  }

  for (const r of data.routes) {
    const portId = r.portNum !== null ? portMap.get(r.portNum) || null : null;
    const backendKey = r.backendHost && r.backendPort ? `${r.backendHost}:${r.backendPort}` : null;
    const backendId = backendKey ? backendMap.get(backendKey) || null : null;
    const configFileId = r.configFile ? configFileMap.get(r.configFile) || null : null;

    await prisma.route.create({
      data: {
        rowNum: r.rowNum,
        domain: r.domain,
        domainRaw: r.domainRaw,
        isCatchAll: r.isCatchAll,
        portId,
        portNum: r.portNum,
        portRaw: r.portRaw,
        protocol: r.protocol,
        path: r.path,
        paths: r.paths,
        action: r.action,
        targetRaw: r.targetRaw,
        targetType: r.targetType,
        backendId,
        staticRoot: r.staticRoot,
        redirectCode: r.redirectCode,
        configFileId,
        notes: r.notes,
        flags: r.flags
      }
    });
  }

  // Step 6: Issues & Checks (12 rows)
  for (const issue of data.issues) {
    let relatedPortId: string | null = null;
    // Detect port links (e.g. 8080, 9000, 7001, etc.)
    const portMatch = issue.title.match(/\b(8080|9000|7001|7002|7003|60007|60008|60009|10080|10081|10180|10181|28096|443|80)\b/);
    if (portMatch) {
      const pNum = parseInt(portMatch[1]);
      relatedPortId = portMap.get(pNum) || null;
    }

    const autoKey = `imported-issue-${issue.issueNum}`;
    await prisma.issue.upsert({
      where: { autoKey },
      update: {
        priority: issue.priority,
        title: issue.title,
        observed: issue.observed,
        recommendation: issue.recommendation,
        relatedPortId
      },
      create: {
        issueNum: issue.issueNum,
        priority: issue.priority,
        title: issue.title,
        observed: issue.observed,
        recommendation: issue.recommendation,
        status: 'open',
        source: 'imported',
        autoKey,
        relatedPortId
      }
    });
  }

  // Step 7: Create Default Admin User & Settings & Alert Rules
  const adminUsername = process.env.ADMIN_USERNAME || 'admin';
  const existingAdmin = await prisma.user.findUnique({
    where: { username: adminUsername }
  });
  if (!existingAdmin) {
    const rawPass = process.env.ADMIN_PASSWORD || 'admin';
    const hash = bcrypt.hashSync(rawPass, 10);
    await prisma.user.create({
      data: {
        username: adminUsername,
        passwordHash: hash,
        role: 'admin',
        email: process.env.ADMIN_EMAIL || 'admin@leadowserver.local'
      }
    });
  }

  // Default Viewer user for convenience
  const existingViewer = await prisma.user.findUnique({
    where: { username: 'viewer' }
  });
  if (!existingViewer) {
    const hash = bcrypt.hashSync('viewer123', 10);
    await prisma.user.create({
      data: {
        username: 'viewer',
        passwordHash: hash,
        role: 'viewer',
        email: 'viewer@leadowserver.local'
      }
    });
  }

  // Ensure default Settings
  await prisma.setting.upsert({
    where: { id: 'global' },
    update: {},
    create: {
      id: 'global',
      scanIntervalSec: 30,
      tcpTimeoutMs: 3000,
      slowThresholdMs: 1500,
      concurrencyLimit: 20,
      retentionDays: 90
    }
  });

  // Ensure default Alert Rules
  const defaultRules = [
    {
      name: 'Port Down Alert',
      eventType: 'down_duration',
      threshold: 1, // minutes
      channels: ['log', 'webhook'],
      isEnabled: true
    },
    {
      name: 'Undocumented Listening Port',
      eventType: 'undocumented_port',
      threshold: 0,
      channels: ['log'],
      isEnabled: true
    },
    {
      name: 'Certificate Expiring Soon (< 14 days)',
      eventType: 'cert_expiry',
      threshold: 14,
      channels: ['log', 'webhook'],
      isEnabled: true
    },
    {
      name: 'High Priority Issue Auto-Detected',
      eventType: 'high_issue',
      threshold: 0,
      channels: ['log'],
      isEnabled: true
    }
  ];

  for (const rule of defaultRules) {
    const existing = await prisma.alertRule.findFirst({
      where: { name: rule.name }
    });
    if (!existing) {
      await prisma.alertRule.create({ data: rule });
    }
  }

  const [
    serversCount,
    configFilesCount,
    backendsCount,
    portsCount,
    routesCount,
    issuesCount
  ] = await Promise.all([
    prisma.server.count(),
    prisma.configFile.count(),
    prisma.backend.count(),
    prisma.port.count(),
    prisma.route.count(),
    prisma.issue.count()
  ]);

  return {
    serversCount,
    configFilesCount,
    backendsCount,
    portsCount,
    routesCount,
    issuesCount,
    warnings
  };
}
