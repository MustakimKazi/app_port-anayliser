import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import prisma from '../../db/prisma.js';
import { ScannerService } from '../../scanner/scanner-service.js';
import { hostListener } from '../../scanner/host-listener.js';
import {
  getAllFeatures,
  getDefaultFeaturesForPort,
  isFeatureGloballyEnabled
} from '../../features/registry.js';
import { BUILTIN_PRESETS } from '../../features/presets.js';

export function checkAdminRole(request: FastifyRequest, reply: FastifyReply): boolean {
  const user = (request as any).user;
  if (user && user.role === 'viewer') {
    reply.status(403).send({ error: 'Forbidden: Viewer role has read-only access' });
    return false;
  }
  return true;
}

const PortFilterSchema = z.object({
  status: z.string().optional(),
  layer: z.string().optional(),
  protocol: z.string().optional(),
  bind: z.enum(['public', 'local']).optional(),
  hasIssues: z.string().optional(),
  issuePriority: z.string().optional(),
  portMin: z.coerce.number().optional(),
  portMax: z.coerce.number().optional(),
  q: z.string().optional(),
  process: z.string().optional(),
  tag: z.string().optional(),
  documented: z.string().optional(),
  shared: z.string().optional(),
  lifecycle: z.string().optional(),
  showArchived: z.string().optional(),
  server: z.string().optional(),
  sort: z.string().optional(),
  page: z.coerce.number().default(1),
  limit: z.coerce.number().default(50)
});

export async function portsRoutes(fastify: FastifyInstance, opts: { scanner: ScannerService }) {
  // GET /api/ports - reading from v_port_overview with comprehensive filters including lifecycle
  fastify.get('/ports', async (request: FastifyRequest, reply: FastifyReply) => {
    const parse = PortFilterSchema.safeParse(request.query);
    if (!parse.success) {
      return reply.status(400).send({ error: parse.error });
    }

    const {
      status,
      layer,
      protocol,
      bind,
      hasIssues,
      issuePriority,
      portMin,
      portMax,
      q,
      process: processFilter,
      tag,
      documented,
      shared,
      lifecycle,
      showArchived,
      server,
      sort = 'port',
      page,
      limit
    } = parse.data;

    // Build parameterized raw query on v_port_overview
    const conditions: string[] = ['1=1'];
    const params: any[] = [];
    let pIdx = 1;

    // Archive & Lifecycle filter logic
    if (showArchived === 'true') {
      // User explicitly wants to see archived ports
      if (lifecycle) {
        const lifecycles = lifecycle.split(',').map((l) => l.trim().toLowerCase());
        conditions.push(`LOWER(lifecycle) = ANY($${pIdx++})`);
        params.push(lifecycles);
      }
    } else {
      // By default hide archived ports unless user asked for archived lifecycle
      if (lifecycle) {
        const lifecycles = lifecycle.split(',').map((l) => l.trim().toLowerCase());
        conditions.push(`LOWER(lifecycle) = ANY($${pIdx++})`);
        params.push(lifecycles);
        if (!lifecycles.includes('archived')) {
          conditions.push(`"archivedAt" IS NULL`);
        }
      } else {
        conditions.push(`LOWER(lifecycle) != 'archived' AND "archivedAt" IS NULL`);
      }
    }

    if (status) {
      conditions.push(`status = $${pIdx++}`);
      params.push(status.toLowerCase());
    }

    if (layer) {
      conditions.push(`LOWER(layer) = $${pIdx++}`);
      params.push(layer.toLowerCase());
    }

    if (protocol) {
      conditions.push(`UPPER(protocol) = $${pIdx++}`);
      params.push(protocol.toUpperCase());
    }

    if (bind) {
      conditions.push(`"isPublic" = $${pIdx++}`);
      params.push(bind === 'public');
    }

    if (server) {
      conditions.push(`("serverId" = $${pIdx} OR LOWER("serverName") LIKE $${pIdx + 1})`);
      params.push(server);
      params.push(`%${server.toLowerCase()}%`);
      pIdx += 2;
    }

    if (hasIssues === 'true') {
      conditions.push(`"openIssueCount" > 0`);
    } else if (hasIssues === 'false') {
      conditions.push(`"openIssueCount" = 0`);
    }

    if (issuePriority === 'High') {
      conditions.push(`"hasHighIssue" = true`);
    }

    if (portMin !== undefined) {
      conditions.push(`port >= $${pIdx++}`);
      params.push(portMin);
    }

    if (portMax !== undefined) {
      conditions.push(`port <= $${pIdx++}`);
      params.push(portMax);
    }

    if (processFilter) {
      conditions.push(`LOWER("processName") LIKE $${pIdx++}`);
      params.push(`%${processFilter.toLowerCase()}%`);
    }

    if (tag) {
      conditions.push(`$${pIdx++} = ANY(tags)`);
      params.push(tag);
    }

    if (shared === 'true') {
      conditions.push(`"routeCount" > 1`);
    }

    if (documented === 'false') {
      conditions.push(`"isExpected" = false`);
    } else if (documented === 'true') {
      conditions.push(`"isExpected" = true`);
    }

    if (q) {
      const qPattern = `%${q.toLowerCase()}%`;
      conditions.push(`(
        CAST(port AS TEXT) LIKE $${pIdx} OR
        LOWER(purpose) LIKE $${pIdx} OR
        LOWER(notes) LIKE $${pIdx} OR
        LOWER("domainsList") LIKE $${pIdx} OR
        LOWER("processName") LIKE $${pIdx} OR
        LOWER(COALESCE(owner, '')) LIKE $${pIdx}
      )`);
      params.push(qPattern);
      pIdx++;
    }

    // Dynamic sort
    let orderClause = 'ORDER BY port ASC';
    const isDesc = sort.startsWith('-');
    const sortField = isDesc ? sort.substring(1) : sort;

    const allowedSortFields: Record<string, string> = {
      port: 'port',
      status: 'status',
      lifecycle: 'lifecycle',
      targetDate: '"targetDate"',
      owner: 'owner',
      layer: 'layer',
      protocol: 'protocol',
      routeCount: '"routeCount"',
      backendCount: '"backendCount"',
      openIssueCount: '"openIssueCount"',
      latencyMs: '"latencyMs"',
      lastCheckedAt: '"lastCheckedAt"'
    };

    if (allowedSortFields[sortField]) {
      orderClause = `ORDER BY ${allowedSortFields[sortField]} ${isDesc ? 'DESC' : 'ASC'}`;
    }

    const whereClause = conditions.join(' AND ');

    // Count query
    const countSql = `SELECT COUNT(*)::integer as total FROM v_port_overview WHERE ${whereClause}`;
    const countRes: any = await prisma.$queryRawUnsafe(countSql, ...params);
    const total = countRes[0]?.total || 0;

    // Data query with pagination
    const offset = (page - 1) * limit;
    const dataSql = `
      SELECT * FROM v_port_overview 
      WHERE ${whereClause} 
      ${orderClause} 
      LIMIT ${limit} OFFSET ${offset}
    `;
    const rows: any = await prisma.$queryRawUnsafe(dataSql, ...params);

    return reply.send({
      data: rows,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    });
  });

  // POST /api/ports/validate - Conflict check before saving (with clear messages)
  fastify.post('/ports/validate', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    const portNum = parseInt(body.port);
    const serverId = body.serverId || null;
    const expectedBind = body.expectedBind || '0.0.0.0';
    const isPublic = body.isPublic !== undefined ? body.isPublic : expectedBind === '0.0.0.0';

    if (isNaN(portNum) || portNum < 1 || portNum > 65535) {
      return reply.send({
        valid: false,
        warnings: [{ code: 'invalid_port', message: 'Port number must be between 1 and 65535.', severity: 'error' }]
      });
    }

    const warnings: Array<{
      code: string;
      message: string;
      severity: 'error' | 'warning' | 'info';
      existingPortId?: string;
      suggestedPreset?: string;
    }> = [];

    // 1. Same port + same server already in DB
    const existing = await prisma.port.findFirst({
      where: {
        port: portNum,
        archivedAt: null,
        ...(serverId ? { serverId } : {})
      }
    });

    if (existing) {
      if (existing.lifecycle === 'planned' || existing.lifecycle === 'reserved') {
        warnings.push({
          code: 'reserved_by_other',
          message: `Port ${portNum} is currently ${existing.lifecycle.toUpperCase()} by ${existing.owner || 'unknown'}${existing.lifecycleReason ? ` (Reason: "${existing.lifecycleReason}")` : ''}.`,
          severity: 'warning',
          existingPortId: existing.id
        });
      } else {
        warnings.push({
          code: 'port_exists',
          message: `Port ${portNum} already exists in PortWatch database (${existing.purpose || 'documented'}).`,
          severity: 'error',
          existingPortId: existing.id
        });
      }
    }

    // 2. Currently listening in latest scan / host listener (and not already in DB)
    try {
      const listeningMap = await hostListener.getListeningPorts();
      const hostInfo = listeningMap.get(portNum);
      if (hostInfo && !existing) {
        warnings.push({
          code: 'listening_on_host',
          message: `This port is already in use by '${hostInfo.processName || 'process'}' (PID: ${hostInfo.pid || 'unknown'}, bind: ${hostInfo.bindAddress}). Add it as documented?`,
          severity: 'info'
        });
      }
    } catch (e) {
      // Ignore host socket probe error
    }

    // 3. Privileged / well-known ports (< 1024)
    if (portNum < 1024) {
      warnings.push({
        code: 'privileged_port',
        message: `Port ${portNum} is a privileged system port (< 1024). Typically requires root / administrative privileges to bind.`,
        severity: 'warning'
      });
    }

    // 4. Known service ports & public bind safety check
    const knownPresets: Record<number, { service: string; preset: string; privateOnly: boolean }> = {
      6379: { service: 'Redis', preset: 'Redis (private only)', privateOnly: true },
      27017: { service: 'MongoDB', preset: 'MongoDB (private only)', privateOnly: true },
      5432: { service: 'PostgreSQL', preset: 'PostgreSQL (private only)', privateOnly: true },
      3306: { service: 'MySQL', preset: 'PostgreSQL (private only)', privateOnly: true },
      22: { service: 'SSH', preset: 'SSH', privateOnly: false },
      443: { service: 'HTTPS', preset: 'Public HTTPS site', privateOnly: false },
      80: { service: 'HTTP', preset: 'Internal HTTP app', privateOnly: false }
    };

    const known = knownPresets[portNum];
    if (known) {
      if (known.privateOnly && (isPublic || expectedBind === '0.0.0.0')) {
        warnings.push({
          code: 'known_db_public_bind',
          message: `Port ${portNum} is a standard ${known.service} port. Binding publicly (0.0.0.0) poses a security risk. Suggest using '${known.preset}' preset.`,
          severity: 'warning',
          suggestedPreset: known.preset
        });
      } else {
        warnings.push({
          code: 'suggest_preset',
          message: `Recognized standard ${known.service} port. Suggested preset: '${known.preset}'.`,
          severity: 'info',
          suggestedPreset: known.preset
        });
      }
    }

    // 5. Local backend collision check (8080 / 9000 problem)
    if (portNum === 8080 || portNum === 9000) {
      warnings.push({
        code: 'common_backend_port',
        message: `Port ${portNum} is a Common dev/backend port frequently shared across applications. Check for local collision (the 8080/9000 problem).`,
        severity: 'warning'
      });
    }

    if (body.initialRoute?.backendPort) {
      const bPort = parseInt(body.initialRoute.backendPort);
      const bHost = body.initialRoute.backendHost || '127.0.0.1';
      const existingBackend = await prisma.backend.findUnique({
        where: { host_port: { host: bHost, port: bPort } },
        include: { routes: true }
      });
      if (existingBackend && existingBackend.routes.length > 0) {
        const routeDomains = existingBackend.routes.map((r) => r.domain).join(', ');
        warnings.push({
          code: 'backend_port_shared',
          message: `Local backend port ${bPort} (${bHost}) is already mapped to existing application routes: ${routeDomains}.`,
          severity: 'warning'
        });
      }
    }

    const hasErrors = warnings.some((w) => w.severity === 'error');
    return reply.send({
      valid: !hasErrors,
      warnings
    });
  });

  // POST /api/ports - Add a single port (with live conflict check, features, initial route, audit log)
  fastify.post('/ports', async (request: FastifyRequest, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const body = request.body as any;
    const portNum = parseInt(body.port);
    if (isNaN(portNum) || portNum < 1 || portNum > 65535) {
      return reply.status(400).send({ error: 'Port number must be between 1 and 65535' });
    }

    let serverId = body.serverId || null;

    // Inline server creation if serverName provided without serverId
    if (!serverId && body.serverName) {
      let server = await prisma.server.findFirst({
        where: { name: body.serverName, archivedAt: null }
      });
      if (!server) {
        server = await prisma.server.create({
          data: {
            name: body.serverName,
            host: body.serverHost || 'localhost',
            kind: 'nginx-host'
          }
        });
      }
      serverId = server.id;
    }

    // Check duplicate port on same server
    const existing = await prisma.port.findFirst({
      where: {
        port: portNum,
        archivedAt: null,
        ...(serverId ? { serverId } : {})
      }
    });

    if (existing) {
      return reply.status(409).send({
        error: `Port ${portNum} already exists in database.`,
        existingPortId: existing.id
      });
    }

    const layer = body.layer || 'http';
    const protocol = body.protocol || (layer === 'http' ? 'HTTP' : 'TCP');
    const lifecycle = body.lifecycle || 'active';
    const isPublic = body.isPublic !== undefined ? body.isPublic : body.expectedBind === '0.0.0.0';

    // Prepare features config
    let initialFeatures: Record<string, { enabled: boolean; config: any }> = {};

    if (body.presetId) {
      const preset = await prisma.featurePreset.findUnique({ where: { id: body.presetId } });
      if (preset && typeof preset.features === 'object') {
        initialFeatures = preset.features as any;
      }
    } else if (body.presetName) {
      const preset = await prisma.featurePreset.findUnique({ where: { name: body.presetName } });
      if (preset && typeof preset.features === 'object') {
        initialFeatures = preset.features as any;
      }
    } else if (body.features && typeof body.features === 'object') {
      initialFeatures = body.features;
    } else {
      initialFeatures = getDefaultFeaturesForPort(layer, protocol);
    }

    const username = (request as any).user?.username || 'admin';

    // Transaction: Create port, features, and initial route
    const createdPort = await prisma.$transaction(async (tx) => {
      const port = await tx.port.create({
        data: {
          port: portNum,
          serverId,
          layer,
          protocol,
          purpose: body.purpose || '',
          notes: body.notes || '',
          processName: body.processName || null,
          listenAddress: body.listenAddress || body.expectedBind || null,
          expectedBind: body.expectedBind || null,
          isPublic,
          isExpected: true,
          isDocumented: true,
          lifecycle,
          lifecycleReason: body.lifecycleReason || null,
          targetDate: body.targetDate ? new Date(body.targetDate) : null,
          owner: body.owner || username,
          maintenanceFrom: body.maintenanceFrom ? new Date(body.maintenanceFrom) : null,
          maintenanceTo: body.maintenanceTo ? new Date(body.maintenanceTo) : null,
          tags: body.tags || [],
          customValues: body.customValues || {}
        }
      });

      // Insert features
      const allRegFeatures = getAllFeatures();
      for (const feat of allRegFeatures) {
        const featSetting = initialFeatures[feat.key];
        const isPlanned = lifecycle === 'planned' || lifecycle === 'reserved';
        const enabled = featSetting?.enabled !== undefined ? featSetting.enabled : (isPlanned ? false : feat.defaultEnabled(layer, protocol));
        const config = featSetting?.config || feat.defaultConfig;

        await tx.portFeature.create({
          data: {
            portId: port.id,
            featureKey: feat.key,
            enabled,
            config
          }
        });
      }

      // Attach optional initial route
      if (body.initialRoute && body.initialRoute.domain) {
        const rData = body.initialRoute;
        let backendId = rData.backendId || null;

        if (!backendId && rData.backendPort) {
          const bPort = parseInt(rData.backendPort);
          const bHost = rData.backendHost || '127.0.0.1';
          let backend = await tx.backend.findUnique({
            where: { host_port: { host: bHost, port: bPort } }
          });
          if (!backend) {
            backend = await tx.backend.create({
              data: { host: bHost, port: bPort, serverId }
            });
          }
          backendId = backend.id;
        }

        await tx.route.create({
          data: {
            portId: port.id,
            portNum: port.port,
            domain: rData.domain,
            domainRaw: rData.domain,
            path: rData.path || '/',
            paths: [rData.path || '/'],
            action: rData.action || 'Proxy',
            targetType: rData.targetType || (backendId ? 'upstream' : 'url'),
            targetRaw: rData.targetRaw || (backendId ? `http://${rData.backendHost || '127.0.0.1'}:${rData.backendPort}` : ''),
            backendId,
            configFileId: rData.configFileId || null,
            notes: rData.notes || ''
          }
        });
      }

      // Record audit log
      await tx.auditLog.create({
        data: {
          username,
          action: 'create',
          entity: 'port',
          entityId: port.id,
          afterState: port
        }
      });

      return port;
    });

    return reply.status(201).send(createdPort);
  });

  // POST /api/ports/bulk - Bulk add (range or pasted list/CSV)
  fastify.post('/ports/bulk', async (request: FastifyRequest, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const body = request.body as any;
    const {
      portRange,
      startPort,
      endPort,
      portsList,
      previewOnly = false,
      skipConflicts = true,
      layer = 'http',
      protocol = 'HTTP',
      purpose = '',
      lifecycle = 'active',
      presetId,
      serverId
    } = body;

    const itemsToProcess: Array<{
      port: number;
      layer: string;
      protocol: string;
      purpose: string;
      lifecycle: string;
      notes?: string;
    }> = [];

    let invalidItemsCount = 0;

    // Parse Range (e.g. "3000-3010" or numeric start/end)
    const effectiveStart = startPort !== undefined ? startPort : body.rangeStart;
    const effectiveEnd = endPort !== undefined ? endPort : body.rangeEnd;

    if (portRange && typeof portRange === 'string') {
      const match = portRange.match(/^(\d+)\s*-\s*(\d+)$/);
      if (match) {
        const start = parseInt(match[1]);
        const end = parseInt(match[2]);
        const minP = Math.min(start, end);
        const maxP = Math.max(start, end);
        if (maxP - minP > 500) {
          return reply.status(400).send({ error: 'Port range exceeds maximum limit of 500 ports' });
        }
        for (let p = minP; p <= maxP; p++) {
          itemsToProcess.push({ port: p, layer, protocol, purpose, lifecycle });
        }
      }
    } else if (effectiveStart !== undefined && effectiveEnd !== undefined) {
      const minP = Math.min(parseInt(effectiveStart), parseInt(effectiveEnd));
      const maxP = Math.max(parseInt(effectiveStart), parseInt(effectiveEnd));
      for (let p = minP; p <= maxP; p++) {
        itemsToProcess.push({ port: p, layer, protocol, purpose, lifecycle });
      }
    } else if (Array.isArray(portsList)) {
      // Pasted list or CSV rows
      for (const item of portsList) {
        const pNum = typeof item === 'number' ? item : parseInt(item.port);
        if (!isNaN(pNum) && pNum >= 1 && pNum <= 65535) {
          itemsToProcess.push({
            port: pNum,
            layer: item.layer || layer,
            protocol: item.protocol || protocol,
            purpose: item.purpose || purpose,
            lifecycle: item.lifecycle || lifecycle,
            notes: item.notes || ''
          });
        } else {
          invalidItemsCount++;
        }
      }
    }

    if (itemsToProcess.length === 0) {
      return reply.status(400).send({ error: 'No valid ports provided to bulk create' });
    }

    // Check existing active ports in DB
    const existingPorts = await prisma.port.findMany({
      where: {
        port: { in: itemsToProcess.map((i) => i.port) },
        archivedAt: null
      },
      select: { id: true, port: true, purpose: true, lifecycle: true }
    });

    const existingMap = new Map(existingPorts.map((p) => [p.port, p]));

    const validItems: typeof itemsToProcess = [];
    const conflictItems: Array<{ item: (typeof itemsToProcess)[0]; reason: string }> = [];

    // Track duplicates inside the bulk batch itself
    const seenBatchPorts = new Set<number>();

    for (const item of itemsToProcess) {
      if (seenBatchPorts.has(item.port)) {
        conflictItems.push({ item, reason: `Duplicate port ${item.port} inside bulk batch` });
      } else if (existingMap.has(item.port)) {
        const ex = existingMap.get(item.port)!;
        conflictItems.push({
          item,
          reason: `Port ${item.port} already exists in DB (${ex.lifecycle})`
        });
      } else {
        seenBatchPorts.add(item.port);
        validItems.push(item);
      }
    }

    // If preview requested, return dry-run analysis
    if (previewOnly) {
      return reply.send({
        preview: true,
        total: itemsToProcess.length,
        validCount: validItems.length,
        conflictCount: conflictItems.length,
        validItems,
        conflicts: conflictItems
      });
    }

    // If conflicts exist and skipConflicts is false, reject all-or-nothing
    if (conflictItems.length > 0 && !skipConflicts) {
      return reply.status(400).send({
        error: `Bulk creation cancelled: ${conflictItems.length} ports have conflicts.`,
        conflicts: conflictItems
      });
    }

    // Proceed to create valid ports
    const username = (request as any).user?.username || 'admin';
    const createdPorts: any[] = [];

    let presetFeatures: Record<string, any> | null = null;
    if (presetId) {
      const preset = await prisma.featurePreset.findUnique({ where: { id: presetId } });
      if (preset && typeof preset.features === 'object') {
        presetFeatures = preset.features as any;
      }
    }

    await prisma.$transaction(async (tx) => {
      const allRegFeatures = getAllFeatures();

      for (const item of validItems) {
        const created = await tx.port.create({
          data: {
            port: item.port,
            serverId: serverId || null,
            layer: item.layer,
            protocol: item.protocol,
            purpose: item.purpose,
            lifecycle: item.lifecycle,
            owner: username,
            notes: item.notes || '',
            isExpected: true,
            isDocumented: true
          }
        });

        // Add features
        for (const feat of allRegFeatures) {
          const isPlanned = item.lifecycle === 'planned' || item.lifecycle === 'reserved';
          const pSetting = presetFeatures ? presetFeatures[feat.key] : null;
          const enabled = pSetting?.enabled !== undefined ? pSetting.enabled : (isPlanned ? false : feat.defaultEnabled(item.layer, item.protocol));
          const config = pSetting?.config || feat.defaultConfig;

          await tx.portFeature.create({
            data: {
              portId: created.id,
              featureKey: feat.key,
              enabled,
              config
            }
          });
        }

        createdPorts.push(created);
      }

      await tx.auditLog.create({
        data: {
          username,
          action: 'bulk_create',
          entity: 'port',
          afterState: { count: createdPorts.length, portNumbers: createdPorts.map((p) => p.port) }
        }
      });
    });

    return reply.status(201).send({
      success: true,
      count: createdPorts.length,
      createdCount: createdPorts.length,
      skippedCount: conflictItems.length + invalidItemsCount,
      skipped: conflictItems,
      ports: createdPorts
    });
  });

  // GET /api/ports/:id - Full details for row drawer
  fastify.get('/ports/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;

    const port = await prisma.port.findUnique({
      where: { id },
      include: {
        server: true,
        routes: {
          where: { archivedAt: null },
          include: {
            backend: true,
            configFile: true
          }
        },
        issues: {
          where: { status: { in: ['open', 'acknowledged'] } }
        },
        features: true
      }
    });

    if (!port) {
      return reply.status(404).send({ error: 'Port not found' });
    }

    // Recent checks
    const recentChecks = await prisma.portCheck.findMany({
      where: { targetId: id },
      orderBy: { checkedAt: 'desc' },
      take: 50
    });

    // 24h Uptime bar
    const now = new Date();
    const uptimeBlocks: Array<{ hour: number; label: string; status: 'up' | 'down' | 'slow' | 'unknown' }> = [];

    for (let h = 23; h >= 0; h--) {
      const blockStart = new Date(now.getTime() - (h + 1) * 3600 * 1000);
      const blockEnd = new Date(now.getTime() - h * 3600 * 1000);

      const checksInHour = recentChecks.filter(
        (c) => new Date(c.checkedAt) >= blockStart && new Date(c.checkedAt) < blockEnd
      );

      let status: 'up' | 'down' | 'slow' | 'unknown' = 'unknown';
      if (checksInHour.length > 0) {
        if (checksInHour.some((c) => c.status === 'down')) status = 'down';
        else if (checksInHour.some((c) => c.status === 'slow')) status = 'slow';
        else if (checksInHour.some((c) => c.status === 'up')) status = 'up';
      } else if (port.status !== 'unknown') {
        status = port.status as any;
      }

      uptimeBlocks.push({
        hour: blockStart.getHours(),
        label: `${blockStart.getHours()}:00`,
        status
      });
    }

    // Status events timeline (lifecycle changes)
    const statusEvents = await prisma.statusEvent.findMany({
      where: { targetType: 'port', targetId: id },
      orderBy: { at: 'desc' },
      take: 30
    });

    // Audit trail
    const auditLogs = await prisma.auditLog.findMany({
      where: { entity: 'port', entityId: id },
      orderBy: { createdAt: 'desc' },
      take: 20
    });

    return reply.send({
      port,
      routes: port.routes,
      issues: port.issues,
      features: port.features,
      uptimeBlocks,
      recentChecks,
      statusEvents,
      auditLogs
    });
  });

  // PATCH /api/ports/:id - Edit port details & port number safety check
  fastify.patch('/ports/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const body = request.body as any;

    const existing = await prisma.port.findUnique({
      where: { id },
      include: { routes: { where: { archivedAt: null } } }
    });
    if (!existing) return reply.status(404).send({ error: 'Port not found' });

    // If port number is changing, verify active routes
    if (body.port !== undefined && parseInt(body.port) !== existing.port) {
      const newPortNum = parseInt(body.port);
      if (existing.routes.length > 0 && body.moveRoutes !== true) {
        return reply.status(400).send({
          error: `Cannot change port number: ${existing.routes.length} active routes depend on port ${existing.port}. Pass 'moveRoutes: true' to reassign them.`,
          routes: existing.routes
        });
      }

      // Check if new port number is free
      const duplicate = await prisma.port.findFirst({
        where: { port: newPortNum, archivedAt: null, id: { not: id } }
      });
      if (duplicate) {
        return reply.status(409).send({ error: `Port ${newPortNum} is already active in database.` });
      }

      if (body.moveRoutes && existing.routes.length > 0) {
        await prisma.route.updateMany({
          where: { portId: id },
          data: { portNum: newPortNum }
        });
      }
    }

    const updated = await prisma.port.update({
      where: { id },
      data: {
        port: body.port !== undefined ? parseInt(body.port) : existing.port,
        purpose: body.purpose !== undefined ? body.purpose : existing.purpose,
        notes: body.notes !== undefined ? body.notes : existing.notes,
        owner: body.owner !== undefined ? body.owner : existing.owner,
        expectedBind: body.expectedBind !== undefined ? body.expectedBind : existing.expectedBind,
        isPublic: body.isPublic !== undefined ? body.isPublic : existing.isPublic,
        isExpected: body.isExpected !== undefined ? body.isExpected : existing.isExpected,
        tags: body.tags !== undefined ? body.tags : existing.tags,
        customValues: body.customValues !== undefined ? body.customValues : existing.customValues,
        targetDate: body.targetDate !== undefined ? (body.targetDate ? new Date(body.targetDate) : null) : existing.targetDate,
        lifecycleReason: body.lifecycleReason !== undefined ? body.lifecycleReason : existing.lifecycleReason
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'update',
        entity: 'port',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send(updated);
  });

  // POST /api/ports/:id/lifecycle - Change port lifecycle with reason & timeline event
  fastify.post('/ports/:id/lifecycle', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const body = request.body as any;
    const { lifecycle, reason, targetDate, owner, maintenanceFrom, maintenanceTo } = body;

    const validLifecycles = ['planned', 'reserved', 'active', 'maintenance', 'deprecated', 'archived'];
    if (!validLifecycles.includes(lifecycle)) {
      return reply.status(400).send({ error: `Invalid lifecycle value: ${lifecycle}` });
    }

    const existing = await prisma.port.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Port not found' });

    const username = (request as any).user?.username || 'admin';
    const oldLifecycle = existing.lifecycle;

    const updated = await prisma.port.update({
      where: { id },
      data: {
        lifecycle,
        lifecycleReason: reason || existing.lifecycleReason,
        targetDate: targetDate !== undefined ? (targetDate ? new Date(targetDate) : null) : existing.targetDate,
        owner: owner || existing.owner || username,
        maintenanceFrom: maintenanceFrom !== undefined ? (maintenanceFrom ? new Date(maintenanceFrom) : null) : existing.maintenanceFrom,
        maintenanceTo: maintenanceTo !== undefined ? (maintenanceTo ? new Date(maintenanceTo) : null) : existing.maintenanceTo,
        archivedAt: lifecycle === 'archived' ? new Date() : (oldLifecycle === 'archived' ? null : existing.archivedAt),
        archivedBy: lifecycle === 'archived' ? username : (oldLifecycle === 'archived' ? null : existing.archivedBy)
      }
    });

    // Record status event for lifecycle transition timeline
    await prisma.statusEvent.create({
      data: {
        targetType: 'port',
        targetId: id,
        targetName: `Port ${existing.port}`,
        fromStatus: oldLifecycle,
        toStatus: lifecycle,
        details: {
          reason,
          targetDate,
          owner: updated.owner,
          changedBy: username
        }
      }
    });

    await prisma.auditLog.create({
      data: {
        username,
        action: 'lifecycle_change',
        entity: 'port',
        entityId: id,
        beforeState: { lifecycle: oldLifecycle },
        afterState: { lifecycle, reason }
      }
    });

    return reply.send(updated);
  });

  // GET /api/ports/:id/impact - Computes impact analysis before removal/archive
  fastify.get('/ports/:id/impact', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const port = await prisma.port.findUnique({
      where: { id },
      include: {
        routes: {
          where: { archivedAt: null },
          include: { backend: true }
        },
        issues: {
          where: { status: { in: ['open', 'acknowledged'] } }
        }
      }
    });

    if (!port) return reply.status(404).send({ error: 'Port not found' });

    const routes = port.routes;
    const domains = Array.from(new Set(routes.map((r) => r.domain)));

    // Find backends that would become orphaned if this port's routes are detached
    const backendIds = Array.from(new Set(routes.map((r) => r.backendId).filter(Boolean))) as string[];
    const orphanedBackends: any[] = [];

    for (const bId of backendIds) {
      const otherRoutesCount = await prisma.route.count({
        where: { backendId: bId, portId: { not: id }, archivedAt: null }
      });
      if (otherRoutesCount === 0) {
        const b = await prisma.backend.findUnique({ where: { id: bId } });
        if (b) orphanedBackends.push(b);
      }
    }

    const checksCount = await prisma.portCheck.count({ where: { targetId: id } });

    // Check if port is currently listening on host
    let isListening = false;
    try {
      const listeningMap = await hostListener.getListeningPorts();
      isListening = listeningMap.has(port.port);
    } catch (e) {
      // Ignore
    }

    // Determine warning level:
    // Safe: no routes, and planned/reserved/archived
    // Caution: routes or backends attached
    // Dangerous: currently listening, or active port without deprecation with live routes
    let warningLevel: 'safe' | 'caution' | 'dangerous' = 'safe';
    if (isListening || (port.lifecycle === 'active' && routes.length > 0)) {
      warningLevel = 'dangerous';
    } else if (routes.length > 0 || orphanedBackends.length > 0) {
      warningLevel = 'caution';
    }

    return reply.send({
      port: { id: port.id, port: port.port, lifecycle: port.lifecycle, purpose: port.purpose },
      routesCount: routes.length,
      routes,
      domainsCount: domains.length,
      domains,
      orphanedBackendsCount: orphanedBackends.length,
      orphanedBackends,
      issuesCount: port.issues.length,
      issues: port.issues,
      historyChecksCount: checksCount,
      isListening,
      warningLevel,
      notice: 'Removing or archiving this port modifies PortWatch documentation only. Any service running on the host server continues running.'
    });
  });

  // POST /api/ports/:id/archive - Archive port (soft delete, keep history, option to detach routes)
  fastify.post('/ports/:id/archive', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const body = request.body as any;
    const detachRoutes = body?.detachRoutes === true;

    const existing = await prisma.port.findUnique({
      where: { id },
      include: { routes: { where: { archivedAt: null } } }
    });
    if (!existing) return reply.status(404).send({ error: 'Port not found' });

    const username = (request as any).user?.username || 'admin';
    const now = new Date();

    await prisma.$transaction(async (tx) => {
      // Archive port
      await tx.port.update({
        where: { id },
        data: {
          lifecycle: 'archived',
          archivedAt: now,
          archivedBy: username
        }
      });

      // Detach routes if requested
      if (detachRoutes && existing.routes.length > 0) {
        await tx.route.updateMany({
          where: { portId: id },
          data: { portId: null }
        });
      }

      await tx.statusEvent.create({
        data: {
          targetType: 'port',
          targetId: id,
          targetName: `Port ${existing.port}`,
          fromStatus: existing.lifecycle,
          toStatus: 'archived',
          details: { detachRoutes, username }
        }
      });

      await tx.auditLog.create({
        data: {
          username,
          action: 'archive',
          entity: 'port',
          entityId: id,
          beforeState: existing,
          afterState: { lifecycle: 'archived', archivedAt: now, detachRoutes }
        }
      });
    });

    return reply.send({
      success: true,
      message: `Port ${existing.port} archived.`,
      portId: id,
      portNumber: existing.port
    });
  });

  // POST /api/ports/:id/restore - Restore an archived port
  fastify.post('/ports/:id/restore', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const existing = await prisma.port.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Port not found' });

    // Check if another active port is using this port number
    const activePort = await prisma.port.findFirst({
      where: { port: existing.port, archivedAt: null, id: { not: id } }
    });
    if (activePort) {
      return reply.status(400).send({
        error: `Cannot restore: Port ${existing.port} is already actively documented (ID: ${activePort.id}).`
      });
    }

    const username = (request as any).user?.username || 'admin';

    const restored = await prisma.port.update({
      where: { id },
      data: {
        lifecycle: 'active',
        archivedAt: null,
        archivedBy: null
      }
    });

    await prisma.statusEvent.create({
      data: {
        targetType: 'port',
        targetId: id,
        targetName: `Port ${existing.port}`,
        fromStatus: 'archived',
        toStatus: 'active',
        details: { restoredBy: username }
      }
    });

    await prisma.auditLog.create({
      data: {
        username,
        action: 'restore',
        entity: 'port',
        entityId: id,
        afterState: restored
      }
    });

    return reply.send({ success: true, port: restored });
  });

  // DELETE /api/ports/:id - Permanently delete port (admin only, typed confirmation, snapshot saved)
  fastify.delete('/ports/:id', async (request: FastifyRequest<{ Params: { id: string }; Querystring: { confirm?: string; deleteRoutes?: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const confirm = (request.query as any).confirm;
    const deleteRoutes = (request.query as any).deleteRoutes === 'true' || (request.query as any).deleteAttachedRoutes === 'true';

    const existing = await prisma.port.findUnique({
      where: { id },
      include: {
        routes: true,
        features: true,
        issues: true
      }
    });

    if (!existing) return reply.status(404).send({ error: 'Port not found' });

    // Require typed confirmation of the port number
    if (confirm !== String(existing.port)) {
      return reply.status(400).send({
        error: `Type '${existing.port}' to confirm permanent deletion.`
      });
    }

    // Block if routes are attached and deleteRoutes is not ticked
    if (existing.routes.length > 0 && !deleteRoutes) {
      return reply.status(409).send({
        error: `Cannot delete port: ${existing.routes.length} routes are attached. Detach routes or check 'also delete routes'.`,
        routesCount: existing.routes.length
      });
    }

    const username = (request as any).user?.username || 'admin';

    // Store restorable JSON snapshot before deletion
    const snapshotData = {
      port: existing,
      routes: existing.routes,
      features: existing.features
    };

    await prisma.trashSnapshot.create({
      data: {
        entityType: 'port',
        entityId: id,
        entityName: `Port ${existing.port}`,
        data: snapshotData,
        deletedBy: username
      }
    });

    await prisma.auditLog.create({
      data: {
        username,
        action: 'delete_permanent',
        entity: 'port',
        entityId: id,
        beforeState: snapshotData
      }
    });

    // Delete in transaction
    await prisma.$transaction(async (tx) => {
      if (deleteRoutes && existing.routes.length > 0) {
        await tx.route.deleteMany({ where: { portId: id } });
      }
      await tx.portFeature.deleteMany({ where: { portId: id } });
      await tx.issue.updateMany({ where: { relatedPortId: id }, data: { relatedPortId: null } });
      await tx.statusEvent.deleteMany({ where: { targetId: id } });
      await tx.portCheck.deleteMany({ where: { targetId: id, targetType: 'port' } });
      await tx.port.delete({ where: { id } });
    });

    return reply.send({ success: true, message: `Port ${existing.port} permanently deleted.` });
  });

  // GET /api/ports/:id/features - List features for a port merged with registry
  fastify.get('/ports/:id/features', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const port = await prisma.port.findUnique({
      where: { id },
      include: { features: true }
    });
    if (!port) return reply.status(404).send({ error: 'Port not found' });

    const allRegFeatures = getAllFeatures();
    const existingFeaturesMap = new Map(port.features.map((f) => [f.featureKey, f]));

    const featuresList = await Promise.all(
      allRegFeatures.map(async (feat) => {
        const existing = existingFeaturesMap.get(feat.key);
        const globallyEnabled = await isFeatureGloballyEnabled(prisma, feat.key);

        const isPlanned = port.lifecycle === 'planned' || port.lifecycle === 'reserved';
        const enabled = existing ? existing.enabled : (isPlanned ? false : feat.defaultEnabled(port.layer, port.protocol));
        const config = existing?.config || feat.defaultConfig;

        return {
          key: feat.key,
          label: feat.label,
          description: feat.description,
          settingsSchema: feat.settingsSchema,
          defaultConfig: feat.defaultConfig,
          applicableLayers: feat.applicableLayers,
          applicableProtocols: feat.applicableProtocols,
          enabled,
          config,
          globallyEnabled
        };
      })
    );

    return reply.send({
      portId: id,
      portNumber: port.port,
      lifecycle: port.lifecycle,
      features: featuresList
    });
  });

  // PUT /api/ports/:id/features - Update features for a port
  fastify.put('/ports/:id/features', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const { id } = request.params;
    const body = request.body as any;
    const featuresInput: Record<string, { enabled?: boolean; config?: any }> = body.features || body;

    const port = await prisma.port.findUnique({ where: { id } });
    if (!port) return reply.status(404).send({ error: 'Port not found' });

    const username = (request as any).user?.username || 'admin';

    await prisma.$transaction(async (tx) => {
      for (const [key, val] of Object.entries(featuresInput)) {
        if (!val || typeof val !== 'object') continue;

        await tx.portFeature.upsert({
          where: { portId_featureKey: { portId: id, featureKey: key } },
          update: {
            enabled: val.enabled !== undefined ? val.enabled : true,
            config: val.config || {}
          },
          create: {
            portId: id,
            featureKey: key,
            enabled: val.enabled !== undefined ? val.enabled : true,
            config: val.config || {}
          }
        });
      }

      await tx.auditLog.create({
        data: {
          username,
          action: 'update_features',
          entity: 'port',
          entityId: id,
          afterState: featuresInput
        }
      });
    });

    return reply.send({ success: true, portId: id });
  });

  // POST /api/ports/features/apply-preset - Apply preset to multiple ports with diff preview
  fastify.post('/ports/features/apply-preset', async (request: FastifyRequest, reply: FastifyReply) => {
    if (!checkAdminRole(request, reply)) return;

    const body = request.body as any;
    const { portIds, presetId, previewOnly = false } = body;

    if (!Array.isArray(portIds) || portIds.length === 0) {
      return reply.status(400).send({ error: 'No port IDs provided' });
    }

    const preset = presetId
      ? await prisma.featurePreset.findUnique({ where: { id: presetId } })
      : await prisma.featurePreset.findFirst({ where: { name: body.presetName } });

    if (!preset) {
      return reply.status(404).send({ error: 'Preset not found' });
    }

    const presetFeatures: Record<string, { enabled: boolean; config?: any }> = preset.features as any;
    const ports = await prisma.port.findMany({
      where: { id: { in: portIds } },
      include: { features: true }
    });

    // Compute diffs
    const diffs: Array<{
      portId: string;
      portNum: number;
      changes: Array<{
        featureKey: string;
        fromEnabled: boolean;
        toEnabled: boolean;
        configChanges: boolean;
      }>;
    }> = [];

    for (const p of ports) {
      const existingMap = new Map(p.features.map((f) => [f.featureKey, f]));
      const portChanges: (typeof diffs)[0]['changes'] = [];

      for (const [key, target] of Object.entries(presetFeatures)) {
        const cur = existingMap.get(key);
        const curEnabled = cur ? cur.enabled : false;
        const targetEnabled = target.enabled;

        const hasConfigChange = target.config && cur ? JSON.stringify(target.config) !== JSON.stringify(cur.config) : false;

        if (curEnabled !== targetEnabled || hasConfigChange) {
          portChanges.push({
            featureKey: key,
            fromEnabled: curEnabled,
            toEnabled: targetEnabled,
            configChanges: hasConfigChange
          });
        }
      }

      diffs.push({
        portId: p.id,
        portNum: p.port,
        changes: portChanges
      });
    }

    if (previewOnly) {
      return reply.send({
        preview: true,
        presetName: preset.name,
        portsCount: ports.length,
        diffs
      });
    }

    // Apply preset changes
    const username = (request as any).user?.username || 'admin';
    await prisma.$transaction(async (tx) => {
      for (const p of ports) {
        for (const [key, target] of Object.entries(presetFeatures)) {
          await tx.portFeature.upsert({
            where: { portId_featureKey: { portId: p.id, featureKey: key } },
            update: {
              enabled: target.enabled,
              config: target.config || {}
            },
            create: {
              portId: p.id,
              featureKey: key,
              enabled: target.enabled,
              config: target.config || {}
            }
          });
        }
      }

      await tx.auditLog.create({
        data: {
          username,
          action: 'apply_preset',
          entity: 'port',
          afterState: { presetId, presetName: preset.name, portIds }
        }
      });
    });

    return reply.send({
      success: true,
      presetName: preset.name,
      appliedCount: ports.length,
      diffs
    });
  });
}
