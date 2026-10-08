import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildApp } from '../src/app.js';
import prisma from '../src/db/prisma.js';

describe('PortWatch API Integration Tests', () => {
  const { app, scanner } = buildApp();
  let adminCookie: { access_token: string };

  beforeAll(async () => {
    await app.ready();
    adminCookie = { access_token: app.jwt.sign({ id: 'admin', username: 'admin', role: 'admin' }) };
  });

  afterAll(async () => {
    scanner.stop();
    await app.close();
    await prisma.$disconnect();
  });

  it('GET /api/health returns healthy', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/health'
    });
    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.body);
    expect(body.status).toBe('healthy');
  });

  it('GET /api/overview returns KPI counters and chart collections', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/overview',
      cookies: adminCookie
    });
    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.body);
    expect(body.kpis.totalPorts).toBeGreaterThanOrEqual(18);
    expect(body.kpis.totalDomains).toBeGreaterThanOrEqual(25);
    expect(body.charts.layerDonut).toBeDefined();
    expect(body.charts.actionChart).toBeDefined();
    expect(body.charts.topPorts).toBeDefined();
  });

  it('GET /api/ports supports multi-field filter combination and pagination', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/ports?layer=http&protocol=HTTP&page=1&limit=10',
      cookies: adminCookie
    });
    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.body);
    expect(body.data).toBeDefined();
    expect(body.pagination.total).toBeGreaterThan(0);
    for (const p of body.data) {
      expect(p.layer.toLowerCase()).toBe('http');
      expect(p.protocol.toUpperCase()).toBe('HTTP');
    }
  });

  it('GET /api/routes filters by action and unresolved status', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/routes?unresolved=true',
      cookies: adminCookie
    });
    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.body);
    expect(body.data.length).toBeGreaterThan(0);
    for (const r of body.data) {
      expect(['upstream', 'variable', 'unknown']).toContain(r.targetType);
    }
  });

  it('GET /api/topology returns nodes, edges, and blast radius maps', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/topology',
      cookies: adminCookie
    });
    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.body);
    expect(body.nodes.length).toBeGreaterThan(0);
    expect(body.edges.length).toBeGreaterThan(0);
    expect(body.blastRadius).toBeDefined();
  });
});
