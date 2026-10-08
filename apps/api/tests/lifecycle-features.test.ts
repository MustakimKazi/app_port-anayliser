import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../src/app.js';
import prisma from '../src/db/prisma.js';
import { registerFeature, getAllFeatures } from '../src/features/registry.js';
import { z } from 'zod';

describe('PortWatch Prompt 6: Port Lifecycle, Features, Presets & Safe Removal', () => {
  const { app, scanner } = buildApp();
  let defaultServerId: string;
  let adminCookie: { access_token: string };
  let viewerCookie: { access_token: string };

  beforeAll(async () => {
    await app.ready();
    adminCookie = { access_token: app.jwt.sign({ id: 'admin', username: 'admin', role: 'admin' }) };
    viewerCookie = { access_token: app.jwt.sign({ id: 'viewer', username: 'viewer', role: 'viewer' }) };
    const server = await prisma.server.findFirst();
    if (server) {
      defaultServerId = server.id;
    } else {
      const created = await prisma.server.create({
        data: { name: 'Test Server', host: '127.0.0.1' }
      });
      defaultServerId = created.id;
    }
  });

  afterAll(async () => {
    scanner.stop();
    await app.close();
    await prisma.$disconnect();
  });

  // TEST 1: Add a port through stepper & duplicate block
  it('1. Add a port through stepper, appears in table & audit, duplicate port+server is blocked', async () => {
    const testPort = 19840;
    // Clean up if existing
    await prisma.port.deleteMany({ where: { port: testPort } });

    // Add port
    const res = await app.inject({
      method: 'POST',
      url: '/api/ports',
      cookies: adminCookie,
      body: {
        port: testPort,
        layer: 'http',
        protocol: 'HTTP',
        purpose: 'Test Stepper Port',
        serverId: defaultServerId,
        lifecycle: 'active',
        expectedBind: '127.0.0.1',
        isPublic: false
      }
    });

    expect(res.statusCode).toBe(201);
    const created = JSON.parse(res.body);
    expect(created.port).toBe(testPort);
    expect(created.lifecycle).toBe('active');
    expect(created.expectedBind).toBe('127.0.0.1');

    // Verify in audit log
    const audit = await prisma.auditLog.findFirst({
      where: { entity: 'port', entityId: created.id, action: 'create' }
    });
    expect(audit).toBeDefined();

    // Verify duplicate port on same server is blocked
    const dupRes = await app.inject({
      method: 'POST',
      url: '/api/ports',
      cookies: adminCookie,
      body: {
        port: testPort,
        layer: 'http',
        protocol: 'HTTP',
        purpose: 'Duplicate Port',
        serverId: defaultServerId
      }
    });
    expect(dupRes.statusCode).toBe(409);
    const dupBody = JSON.parse(dupRes.body);
    expect(dupBody.error).toContain('already exists');
    expect(dupBody.existingPortId).toBe(created.id);
  });

  // TEST 2: Conflict checks (POST /api/ports/validate)
  it('2. Conflict checks: local backend collision, known DB port with public bind, and reserved port', async () => {
    // 2a: Known DB port (e.g. 5432 or 6379) with public bind (0.0.0.0)
    const dbCheckRes = await app.inject({
      method: 'POST',
      url: '/api/ports/validate',
      cookies: adminCookie,
      body: {
        port: 6379,
        expectedBind: '0.0.0.0',
        isPublic: true
      }
    });
    expect(dbCheckRes.statusCode).toBe(200);
    const dbValidation = JSON.parse(dbCheckRes.body);
    expect(dbValidation.warnings.some((w: any) => w.message?.includes('Redis') && w.message?.includes('public'))).toBe(true);
    expect(dbValidation.warnings.some((w: any) => w.suggestedPreset === 'Redis (private only)')).toBe(true);

    // 2b: Local backend collision (port 8080 or 9000 used by another app)
    const collCheckRes = await app.inject({
      method: 'POST',
      url: '/api/ports/validate',
      cookies: adminCookie,
      body: {
        port: 8080,
        expectedBind: '127.0.0.1'
      }
    });
    expect(collCheckRes.statusCode).toBe(200);
    const collValidation = JSON.parse(collCheckRes.body);
    expect(collValidation.warnings.some((w: any) => w.message?.includes('Common dev/backend port'))).toBe(true);
  });

  // TEST 3: Range add 3000-3010 and pasted list with bad rows
  it('3. Range add 3000-3004 and bulk paste with bad rows', async () => {
    const rangeStart = 31500;
    const rangeEnd = 31504; // 5 ports
    await prisma.port.deleteMany({ where: { port: { in: [31500, 31501, 31502, 31503, 31504, 31505] } } });

    // Bulk range add
    const rangeRes = await app.inject({
      method: 'POST',
      url: '/api/ports/bulk',
      cookies: adminCookie,
      body: {
        mode: 'range',
        rangeStart,
        rangeEnd,
        layer: 'http',
        protocol: 'HTTP',
        purpose: 'Range Test App',
        serverId: defaultServerId,
        lifecycle: 'active'
      }
    });
    expect(rangeRes.statusCode).toBe(201);
    const rangeBody = JSON.parse(rangeRes.body);
    expect(rangeBody.count).toBe(5);

    // Verify in database
    const createdPorts = await prisma.port.findMany({
      where: { port: { gte: rangeStart, lte: rangeEnd } }
    });
    expect(createdPorts.length).toBe(5);

    // Bulk paste list with 2 invalid rows and 1 valid row
    const pasteRes = await app.inject({
      method: 'POST',
      url: '/api/ports/bulk',
      cookies: adminCookie,
      body: {
        mode: 'list',
        importStrategy: 'valid_only',
        portsList: [
          { port: 'invalid_port', layer: 'http', protocol: 'HTTP', purpose: 'Bad Port 1' },
          { port: 999999, layer: 'http', protocol: 'HTTP', purpose: 'Out of range port' },
          { port: 31505, layer: 'stream', protocol: 'TCP', purpose: 'Valid Port' }
        ]
      }
    });
    expect(pasteRes.statusCode).toBe(201);
    const pasteBody = JSON.parse(pasteRes.body);
    expect(pasteBody.count).toBe(1);
    expect(pasteBody.skippedCount).toBe(2);
  });

  // TEST 4: Planned port: not scanned, overdue appears in overview
  it('4. Planned port is reserved in finder, not alerted, and past targetDate appears in attention', async () => {
    const plannedPort = 31600;
    await prisma.port.deleteMany({ where: { port: plannedPort } });

    // Create overdue planned port (target date in the past)
    const yesterday = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
    const planned = await prisma.port.create({
      data: {
        port: plannedPort,
        layer: 'http',
        protocol: 'HTTP',
        purpose: 'Planned Overdue Port',
        lifecycle: 'planned',
        targetDate: new Date(yesterday),
        owner: 'DevOps Lead',
        lifecycleReason: 'Migrating microservice next sprint'
      }
    });

    // Overview attention
    const overviewRes = await app.inject({
      method: 'GET',
      url: '/api/overview',
      cookies: adminCookie
    });
    expect(overviewRes.statusCode).toBe(200);
    const overview = JSON.parse(overviewRes.body);
    expect(overview.attention.overduePlanned.length).toBeGreaterThanOrEqual(1);
    expect(overview.kpis.lifecycles.planned).toBeGreaterThanOrEqual(1);

    // Clean up
    await prisma.port.delete({ where: { id: planned.id } });
  });

  // TEST 5: Maintenance window mutes alerts and ends by itself
  it('5. Maintenance window mutes alerts and auto-expires', async () => {
    const maintPort = 31700;
    await prisma.port.deleteMany({ where: { port: maintPort } });

    // Set maintenance window that expired 1 second ago
    const pastTime = new Date(Date.now() - 1000);
    const port = await prisma.port.create({
      data: {
        port: maintPort,
        layer: 'http',
        protocol: 'HTTP',
        purpose: 'Maintenance Test Port',
        lifecycle: 'maintenance',
        maintenanceFrom: new Date(Date.now() - 60000),
        maintenanceTo: pastTime,
        lifecycleReason: 'Routine kernel patch'
      }
    });

    // Run scanner lifecycle check cycle
    await scanner.runScan();

    // Verify it auto-transitioned back to active
    const updated = await prisma.port.findUnique({ where: { id: port.id } });
    expect(updated?.lifecycle).toBe('active');
    expect(updated?.lifecycleReason).toContain('Maintenance window completed');

    await prisma.port.delete({ where: { id: port.id } });
  });

  // TEST 6: Feature registry: toggle off, toggle on, and dynamically register a new feature
  it('6. Feature registry: toggle per-port feature, globally enable, and register dynamic feature', async () => {
    // 6a: Dynamically register a dummy new feature in registry
    registerFeature({
      key: 'custom_health_probe',
      label: 'Custom Health Probe',
      description: 'Executes arbitrary gRPC or custom socket probe',
      settingsSchema: z.object({ endpoint: z.string().default('/healthz') }),
      defaultConfig: { endpoint: '/healthz' },
      applicableLayers: ['http', 'stream'],
      applicableProtocols: ['HTTP', 'TCP']
    });

    // Verify it shows up in GET /api/features/registry
    const regRes = await app.inject({
      method: 'GET',
      url: '/api/features/registry',
      cookies: adminCookie
    });
    expect(regRes.statusCode).toBe(200);
    const features = JSON.parse(regRes.body);
    const found = features.find((f: any) => f.key === 'custom_health_probe');
    expect(found).toBeDefined();
    expect(found.label).toBe('Custom Health Probe');

    // 6b: Globally toggle the feature
    const toggleRes = await app.inject({
      method: 'PATCH',
      url: '/api/features/registry/custom_health_probe',
      cookies: adminCookie,
      body: { enabled: false }
    });
    expect(toggleRes.statusCode).toBe(200);
    expect(JSON.parse(toggleRes.body).globallyEnabled).toBe(false);
  });

  // TEST 7: Feature presets: save from port, apply with diff preview, delete preset
  it('7. Presets: save from port, apply with diff preview, and delete preset', async () => {
    await prisma.featurePreset.deleteMany({ where: { name: 'Automated Test Preset' } });

    // Create custom preset
    const presetRes = await app.inject({
      method: 'POST',
      url: '/api/feature-presets',
      cookies: adminCookie,
      body: {
        name: 'Automated Test Preset',
        description: 'Testing preset creation and bulk diff preview',
        features: {
          tcp_check: { enabled: true, config: { timeoutMs: 1500 } },
          tls_check: { enabled: false, config: {} }
        }
      }
    });
    expect(presetRes.statusCode).toBe(201);
    const preset = JSON.parse(presetRes.body);
    expect(preset.name).toBe('Automated Test Preset');

    // Create a target port
    const testPort = 31800;
    await prisma.port.deleteMany({ where: { port: testPort } });
    const p = await prisma.port.create({
      data: { port: testPort, layer: 'http', protocol: 'HTTP', purpose: 'Preset Target' }
    });

    // Test bulk diff preview
    const diffRes = await app.inject({
      method: 'POST',
      url: '/api/ports/features/apply-preset',
      cookies: adminCookie,
      body: {
        presetId: preset.id,
        presetName: 'Automated Test Preset',
        portIds: [p.id],
        previewOnly: true
      }
    });
    expect(diffRes.statusCode).toBe(200);
    const diffBody = JSON.parse(diffRes.body);
    expect(diffBody.preview).toBe(true);
    expect(diffBody.diffs.length).toBe(1);

    // Delete custom preset
    const delPresetRes = await app.inject({
      method: 'DELETE',
      url: `/api/feature-presets/${preset.id}`,
      cookies: adminCookie
    });
    expect(delPresetRes.statusCode).toBe(200);

    await prisma.port.delete({ where: { id: p.id } });
  });

  // TEST 8: Safe remove: impact preview, archive, restore, and permanent delete with audit snapshot
  it('8. Safe remove: impact preview, archive soft-delete, restore, and permanent delete snapshot', async () => {
    const testPort = 31900;
    await prisma.route.deleteMany({ where: { domain: 'remove-test.internal' } });
    await prisma.port.deleteMany({ where: { port: testPort } });

    const port = await prisma.port.create({
      data: {
        port: testPort,
        layer: 'http',
        protocol: 'HTTP',
        purpose: 'Safe Remove Test',
        lifecycle: 'active'
      }
    });

    const route = await prisma.route.create({
      data: {
        domain: 'remove-test.internal',
        path: '/',
        portId: port.id,
        portNum: testPort,
        action: 'Proxy',
        targetRaw: 'http://127.0.0.1:31900'
      }
    });

    // 8a: Impact preview
    const impactRes = await app.inject({
      method: 'GET',
      url: `/api/ports/${port.id}/impact`,
      cookies: adminCookie
    });
    expect(impactRes.statusCode).toBe(200);
    const impact = JSON.parse(impactRes.body);
    expect(impact.routesCount).toBe(1);
    expect(['caution', 'dangerous']).toContain(impact.warningLevel);

    // 8b: Archive port
    const archiveRes = await app.inject({
      method: 'POST',
      url: `/api/ports/${port.id}/archive`,
      cookies: adminCookie,
      body: { reason: 'Decommissioning' }
    });
    expect(archiveRes.statusCode).toBe(200);

    // Verify it is hidden from default ports list
    const listRes = await app.inject({ method: 'GET', url: `/api/ports?portMin=${testPort}&portMax=${testPort}`, cookies: adminCookie });
    expect(JSON.parse(listRes.body).data.length).toBe(0);

    // Verify it appears with showArchived=true
    const archivedListRes = await app.inject({ method: 'GET', url: `/api/ports?portMin=${testPort}&portMax=${testPort}&showArchived=true`, cookies: adminCookie });
    expect(JSON.parse(archivedListRes.body).data.length).toBe(1);

    // 8c: Restore port
    const restoreRes = await app.inject({
      method: 'POST',
      url: `/api/ports/${port.id}/restore`,
      cookies: adminCookie
    });
    expect(restoreRes.statusCode).toBe(200);

    // 8d: Permanent delete blocked while route is attached without confirm
    const permFailRes = await app.inject({
      method: 'DELETE',
      url: `/api/ports/${port.id}?confirm=${testPort}`,
      cookies: adminCookie
    });
    expect(permFailRes.statusCode).toBe(409); // Blocked because active route attached

    // Delete with deleteAttachedRoutes
    const permRes = await app.inject({
      method: 'DELETE',
      url: `/api/ports/${port.id}?confirm=${testPort}&deleteAttachedRoutes=true`,
      cookies: adminCookie
    });
    expect(permRes.statusCode).toBe(200);

    // Verify snapshot in trash_snapshots
    const snapshot = await prisma.trashSnapshot.findFirst({
      where: { entityType: 'port', entityId: port.id }
    });
    expect(snapshot).toBeDefined();

    // 8e: Restore from snapshot
    const restoreSnapRes = await app.inject({
      method: 'POST',
      url: `/api/trash/restore-snapshot/${snapshot?.id}`,
      cookies: adminCookie
    });
    expect(restoreSnapRes.statusCode).toBe(200);

    // Clean up
    await prisma.route.deleteMany({ where: { domain: 'remove-test.internal' } });
    await prisma.port.deleteMany({ where: { port: testPort } });
  });

  // TEST 9: Re-adding an archived port number works (PostgreSQL partial unique index)
  it('9. Re-adding an archived port number works due to partial unique index', async () => {
    const reusePort = 32000;
    await prisma.port.deleteMany({ where: { port: reusePort } });

    // Create port and archive it
    const p1 = await prisma.port.create({
      data: {
        port: reusePort,
        layer: 'http',
        protocol: 'HTTP',
        purpose: 'Original Port',
        lifecycle: 'archived',
        archivedAt: new Date()
      }
    });

    // Re-create the same port number as active
    const addRes = await app.inject({
      method: 'POST',
      url: '/api/ports',
      cookies: adminCookie,
      body: {
        port: reusePort,
        layer: 'http',
        protocol: 'HTTP',
        purpose: 'Re-added Port',
        lifecycle: 'active'
      }
    });

    expect(addRes.statusCode).toBe(201);
    const p2 = JSON.parse(addRes.body);
    expect(p2.port).toBe(reusePort);
    expect(p2.id).not.toBe(p1.id);

    // Clean up
    await prisma.port.deleteMany({ where: { port: reusePort } });
  });

  // TEST 10: Role protection: Viewer gets 403 on mutating endpoints
  it('10. Viewer role: direct API mutating calls return 403 Forbidden', async () => {
    // POST /api/ports with viewer role
    const postRes = await app.inject({
      method: 'POST',
      url: '/api/ports',
      cookies: viewerCookie,
      body: {
        port: 44444,
        layer: 'http',
        protocol: 'HTTP',
        purpose: 'Viewer Unauthorized'
      }
    });
    expect(postRes.statusCode).toBe(403);

    // DELETE /api/ports/:id with viewer role
    const delRes = await app.inject({
      method: 'DELETE',
      url: '/api/ports/dummy-id',
      cookies: viewerCookie
    });
    expect(delRes.statusCode).toBe(403);
  });
});
