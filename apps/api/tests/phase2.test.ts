import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../src/app.js';
import prisma from '../src/db/prisma.js';

const SCRATCH_DOMAIN = 'phase2-test.example.com';

describe('Phase 2: domains, config files, certificates APIs', () => {
  const { app, scanner } = buildApp();

  let adminCookie: { access_token: string };
  let viewerCookie: { access_token: string };

  beforeAll(async () => {
    await app.ready();
    adminCookie = { access_token: app.jwt.sign({ id: 'admin', username: 'admin', role: 'admin' }) };
    viewerCookie = { access_token: app.jwt.sign({ id: 'viewer', username: 'viewer', role: 'viewer' }) };
  });

  afterAll(async () => {
    scanner.stop();
    await app.close();
    await prisma.$disconnect();
  });

  describe('GET /api/domains', () => {
    it('returns aggregated domains with ports/backends/actions', async () => {
      const res = await app.inject({ method: 'GET', url: '/api/domains', cookies: adminCookie });
      expect(res.statusCode).toBe(200);
      const body = res.json();
      expect(body.count).toBeGreaterThan(0);
      expect(Array.isArray(body.domains)).toBe(true);

      const d = body.domains.find((x: any) => x.domain === 'abg.leadows.com');
      expect(d).toBeDefined();
      expect(d.routeCount).toBeGreaterThanOrEqual(2);
      expect(d.ports).toContain(443);
      expect(d.actions.Proxy).toBeGreaterThanOrEqual(1);
      expect(typeof d.catchAll).toBe('number');

      // list entries must not leak raw routes
      expect(d.routes).toBeUndefined();
    });

    it('supports showArchived=true', async () => {
      const res = await app.inject({ method: 'GET', url: '/api/domains?showArchived=true', cookies: adminCookie });
      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.json().domains)).toBe(true);
    });
  });

  describe('GET /api/domains/:domain', () => {
    it('returns detail with routes, ports, backends, config files', async () => {
      const res = await app.inject({ method: 'GET', url: '/api/domains/abg.leadows.com', cookies: adminCookie });
      expect(res.statusCode).toBe(200);
      const body = res.json();
      expect(body.domain).toBe('abg.leadows.com');
      expect(body.routes.length).toBeGreaterThanOrEqual(2);
      expect(body.counts.routes).toBe(body.routes.length);
      expect(body.ports.length).toBeGreaterThanOrEqual(1);
      expect(body.configFiles.length).toBeGreaterThanOrEqual(1);
      expect(body.configFiles[0].filename).toContain('.conf');
      expect(body.routes[0]).toHaveProperty('action');
      expect(body.routes[0]).toHaveProperty('path');
    });

    it('404s for unknown domain', async () => {
      const res = await app.inject({ method: 'GET', url: '/api/domains/nope.invalid', cookies: adminCookie });
      expect(res.statusCode).toBe(404);
    });
  });

  describe('GET /api/domains/:domain/impact', () => {
    it('returns impact summary with caution warning for routed domain', async () => {
      const res = await app.inject({ method: 'GET', url: '/api/domains/abg.leadows.com/impact', cookies: adminCookie });
      expect(res.statusCode).toBe(200);
      const body = res.json();
      expect(body.routesCount).toBeGreaterThanOrEqual(2);
      expect(body.warningLevel).toBe('caution');
      expect(body.notice).toMatch(/NOT deleted/);
      expect(body.ports.length).toBeGreaterThanOrEqual(1);
      expect(Array.isArray(body.routes)).toBe(true);
    });

    it('404s for unknown domain', async () => {
      const res = await app.inject({ method: 'GET', url: '/api/domains/nope.invalid/impact', cookies: adminCookie });
      expect(res.statusCode).toBe(404);
    });
  });

  describe('domain lifecycle: bulk create → archive → restore → delete', () => {
    it('creates the scratch domain via /routes/bulk', async () => {
      const res = await app.inject({
        method: 'POST',
        url: '/api/routes/bulk',
        cookies: adminCookie,
        payload: {
          routesList: [
            { domain: SCRATCH_DOMAIN, path: '/', action: 'Proxy', portNum: 443, targetRaw: 'http://10.0.0.99:1234', targetType: 'url' },
            { domain: SCRATCH_DOMAIN, path: '/api', action: 'Proxy', portNum: 443, targetRaw: 'http://10.0.0.99:1235', targetType: 'url' }
          ]
        }
      });
      expect(res.statusCode).toBe(201);
      expect(res.json().count).toBe(2);
    });

    it('lists the new domain', async () => {
      const res = await app.inject({ method: 'GET', url: '/api/domains', cookies: adminCookie });
      const d = res.json().domains.find((x: any) => x.domain === SCRATCH_DOMAIN);
      expect(d).toBeDefined();
      expect(d.routeCount).toBe(2);
    });

    it('rejects viewer role for archive', async () => {
      const res = await app.inject({ method: 'POST', url: `/api/domains/${SCRATCH_DOMAIN}/archive`, cookies: viewerCookie });
      expect(res.statusCode).toBe(403);
    });

    it('archives the domain (all routes leave the active list)', async () => {
      const res = await app.inject({ method: 'POST', url: `/api/domains/${SCRATCH_DOMAIN}/archive`, cookies: adminCookie });
      expect(res.statusCode).toBe(200);
      expect(res.json().archived).toBe(2);

      const active = await app.inject({ method: 'GET', url: '/api/domains', cookies: adminCookie });
      expect(active.json().domains.find((x: any) => x.domain === SCRATCH_DOMAIN)).toBeUndefined();

      const archived = await app.inject({ method: 'GET', url: '/api/domains?showArchived=true', cookies: adminCookie });
      expect(archived.json().domains.find((x: any) => x.domain === SCRATCH_DOMAIN)).toBeDefined();
    });

    it('restores the domain', async () => {
      const res = await app.inject({ method: 'POST', url: `/api/domains/${SCRATCH_DOMAIN}/restore`, cookies: adminCookie });
      expect(res.statusCode).toBe(200);
      expect(res.json().restored).toBe(2);

      const active = await app.inject({ method: 'GET', url: '/api/domains', cookies: adminCookie });
      expect(active.json().domains.find((x: any) => x.domain === SCRATCH_DOMAIN)).toBeDefined();
    });

    it('rejects viewer role for delete', async () => {
      const res = await app.inject({
        method: 'DELETE',
        url: `/api/domains/${SCRATCH_DOMAIN}?confirm=${SCRATCH_DOMAIN}`,
        cookies: viewerCookie
      });
      expect(res.statusCode).toBe(403);
    });

    it('refuses delete without matching confirmation', async () => {
      const noConfirm = await app.inject({ method: 'DELETE', url: `/api/domains/${SCRATCH_DOMAIN}`, cookies: adminCookie });
      expect(noConfirm.statusCode).toBe(400);
      const wrong = await app.inject({
        method: 'DELETE',
        url: `/api/domains/${SCRATCH_DOMAIN}?confirm=WRONG`,
        cookies: adminCookie
      });
      expect(wrong.statusCode).toBe(400);

      // still there
      const active = await app.inject({ method: 'GET', url: '/api/domains', cookies: adminCookie });
      expect(active.json().domains.find((x: any) => x.domain === SCRATCH_DOMAIN)).toBeDefined();
    });

    it('deletes with matching confirmation and writes trash snapshot', async () => {
      const before = await prisma.trashSnapshot.count({ where: { entityName: { startsWith: SCRATCH_DOMAIN } } });

      const res = await app.inject({
        method: 'DELETE',
        url: `/api/domains/${SCRATCH_DOMAIN}?confirm=${SCRATCH_DOMAIN}`,
        cookies: adminCookie
      });
      expect(res.statusCode).toBe(200);
      expect(res.json().deleted).toBe(2);

      const after = await app.inject({ method: 'GET', url: `/api/domains/${SCRATCH_DOMAIN}`, cookies: adminCookie });
      expect(after.statusCode).toBe(404);

      const snapshots = await prisma.trashSnapshot.count({ where: { entityName: { startsWith: SCRATCH_DOMAIN } } });
      expect(snapshots).toBe(before + 2);

      const audit = await prisma.auditLog.findFirst({
        where: { action: 'delete', entity: 'domain', entityId: SCRATCH_DOMAIN },
        orderBy: { createdAt: 'desc' }
      });
      expect(audit).not.toBeNull();
      expect(audit!.username).toBe('admin');
    });
  });

  describe('config files content API', () => {
    let fileId: string;
    let originalContent: string | null = null;

    it('list exposes hasContent/contentLength but not content', async () => {
      const res = await app.inject({ method: 'GET', url: '/api/config-files', cookies: adminCookie });
      expect(res.statusCode).toBe(200);
      const files = res.json().files;
      expect(files.length).toBeGreaterThan(0);
      for (const f of files) {
        expect(f).not.toHaveProperty('content');
        expect(typeof f.hasContent).toBe('boolean');
        expect(typeof f.contentLength).toBe('number');
      }
      const withContent = files.find((f: any) => f.hasContent);
      expect(withContent).toBeDefined();
      fileId = withContent.id;

      // capture original content so the PATCH test can restore it
      const detail = await app.inject({ method: 'GET', url: `/api/config-files/${fileId}`, cookies: adminCookie });
      originalContent = detail.json().content ?? null;
    });

    it('GET /config-files/:id returns full detail with content', async () => {
      const res = await app.inject({ method: 'GET', url: `/api/config-files/${fileId}`, cookies: adminCookie });
      expect(res.statusCode).toBe(200);
      const body = res.json();
      expect(body.id).toBe(fileId);
      expect(typeof body.content).toBe('string');
      expect(body.content.length).toBeGreaterThan(0);
      expect(Array.isArray(body.routes)).toBe(true);
    });

    it('GET /config-files/:id 404s for unknown id', async () => {
      const res = await app.inject({ method: 'GET', url: '/api/config-files/does-not-exist', cookies: adminCookie });
      expect(res.statusCode).toBe(404);
    });

    it('PATCH updates content and GET reflects it', async () => {
      const marker = '# phase2-test-marker\nserver { server_name marker.test; }';
      const patch = await app.inject({
        method: 'PATCH',
        url: `/api/config-files/${fileId}`,
        cookies: adminCookie,
        payload: { content: marker }
      });
      expect(patch.statusCode).toBe(200);

      const detail = await app.inject({ method: 'GET', url: `/api/config-files/${fileId}`, cookies: adminCookie });
      expect(detail.json().content).toBe(marker);

      const list = await app.inject({ method: 'GET', url: '/api/config-files', cookies: adminCookie });
      const entry = list.json().files.find((f: any) => f.id === fileId);
      expect(entry.hasContent).toBe(true);
      expect(entry.contentLength).toBe(marker.length);
      expect(entry).not.toHaveProperty('content');
    });

    it('restores the original content', async () => {
      const res = await app.inject({
        method: 'PATCH',
        url: `/api/config-files/${fileId}`,
        cookies: adminCookie,
        payload: { content: originalContent }
      });
      expect(res.statusCode).toBe(200);
      const detail = await app.inject({ method: 'GET', url: `/api/config-files/${fileId}`, cookies: adminCookie });
      expect(detail.json().content).toBe(originalContent);
    });
  });

  describe('GET /api/certificates/:domain', () => {
    it('returns certificate error info (not crash) for unroutable domain', async () => {
      const res = await app.inject({
        method: 'GET',
        url: '/api/certificates/does-not-exist.invalid',
        cookies: adminCookie
      });
      expect(res.statusCode).toBe(200);
      const body = res.json();
      expect(body.certificate).toBeDefined();
      expect(body.certificate.status).toBe('error');
      expect(body.certificate.error).toBeTruthy();
      expect(Array.isArray(body.routes)).toBe(true);
    }, 15000);
  });

  describe('GET /api/backends/:id/impact', () => {
    it('returns impact for a backend with attached routes', async () => {
      const list = await app.inject({ method: 'GET', url: '/api/backends', cookies: adminCookie });
      const withRoutes = list.json().find((b: any) => (b.routes?.length || 0) > 0);
      expect(withRoutes).toBeDefined();

      const res = await app.inject({ method: 'GET', url: `/api/backends/${withRoutes.id}/impact`, cookies: adminCookie });
      expect(res.statusCode).toBe(200);
      const body = res.json();
      expect(body.routesCount).toBeGreaterThanOrEqual(1);
      expect(body.warningLevel).toBe('caution');
      expect(body.notice).toBeTruthy();
      expect(Array.isArray(body.routes)).toBe(true);
    });

    it('404s for unknown backend', async () => {
      const res = await app.inject({ method: 'GET', url: '/api/backends/nope/impact', cookies: adminCookie });
      expect(res.statusCode).toBe(404);
    });
  });
});
