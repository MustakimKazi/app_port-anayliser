import Fastify from 'fastify';
import cors from '@fastify/cors';
import cookie from '@fastify/cookie';
import jwt from '@fastify/jwt';
import multipart from '@fastify/multipart';
import swagger from '@fastify/swagger';
import swaggerUi from '@fastify/swagger-ui';
import { config } from './config/env.js';
import prisma from './db/prisma.js';
import { ScannerService } from './scanner/scanner-service.js';

// Route modules
import { authRoutes } from './modules/auth/auth.routes.js';
import { overviewRoutes } from './modules/overview/overview.routes.js';
import { portsRoutes } from './modules/ports/ports.routes.js';
import { routesRoutes } from './modules/routes/routes.routes.js';
import { backendsRoutes } from './modules/backends/backends.routes.js';
import { serversRoutes } from './modules/servers/servers.routes.js';
import { issuesRoutes } from './modules/issues/issues.routes.js';
import { configFilesRoutes } from './modules/config-files/config-files.routes.js';
import { certificatesRoutes } from './modules/certificates/certificates.routes.js';
import { portMapRoutes } from './modules/port-map/port-map.routes.js';
import { historyRoutes } from './modules/history/history.routes.js';
import { customFieldsRoutes } from './modules/custom-fields/custom-fields.routes.js';
import { alertsRoutes } from './modules/alerts/alerts.routes.js';
import { auditRoutes } from './modules/audit/audit.routes.js';
import { savedViewsRoutes } from './modules/saved-views/saved-views.routes.js';
import { importExportRoutes } from './modules/import-export/import-export.routes.js';
import { scanRoutes } from './modules/scan/scan.routes.js';
import { featuresRoutes } from './modules/features/features.routes.js';
import { trashRoutes } from './modules/trash/trash.routes.js';

export function buildApp() {
  const app = Fastify({
    logger: {
      level: config.nodeEnv === 'development' ? 'info' : 'warn'
    }
  });

  const scanner = new ScannerService(prisma);

  // Plugins
  const allowedOrigins = (
    process.env.CORS_ORIGINS ||
    'http://localhost:5173,http://127.0.0.1:5173,http://localhost:4173'
  )
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);

  app.register(cors, {
    origin: (origin, cb) => {
      // Same-origin / non-browser requests send no Origin header
      if (!origin || allowedOrigins.includes(origin)) {
        cb(null, true);
      } else {
        cb(null, false);
      }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS']
  });

  app.register(cookie);

  app.register(jwt, {
    secret: config.jwtSecret,
    cookie: {
      cookieName: 'access_token',
      signed: false
    }
  });

  app.register(multipart, {
    limits: {
      fileSize: 10 * 1024 * 1024 // 10MB
    }
  });

  // User auth / role preHandler hook.
  // FAIL-CLOSED: an invalid/missing JWT yields an anonymous user and 401 for
  // every API route (public paths excepted). The x-role / x-user request
  // headers are never trusted and there is no default admin fallback.
  app.addHook('preHandler', async (request, reply) => {
    if (!request.url.startsWith('/api')) return;

    const path = request.url.split('?')[0];
    const isPublic =
      path === '/api/auth/login' ||
      path === '/api/health' ||
      path.startsWith('/api/docs');

    try {
      const decoded: any = await request.jwtVerify();
      (request as any).user = decoded;
    } catch (e) {
      (request as any).user = null;
      if (isPublic) return;
      return reply.status(401).send({ error: 'Authentication required' });
    }

    if (isPublic) return;

    // Role guard: viewer = read-only. All mutations and reads that expose
    // secrets require role === 'admin'. /api/auth/* stays open to any
    // authenticated user (e.g. logout, /auth/me).
    const user = (request as any).user;
    const isAdmin = user?.role === 'admin';
    const isAuthPath = path.startsWith('/api/auth/');
    const sensitiveRead =
      path === '/api/settings' ||
      path.startsWith('/api/backup');

    if (!isAdmin && !isAuthPath && (request.method !== 'GET' || sensitiveRead)) {
      return reply.status(403).send({ error: 'Forbidden: admin role required' });
    }
  });

  // Basic security headers (no helmet dependency)
  app.addHook('onSend', async (request, reply) => {
    reply.header('X-Content-Type-Options', 'nosniff');
    reply.header('X-Frame-Options', 'DENY');
    reply.header('Referrer-Policy', 'no-referrer');
    reply.header('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
    if (request.url.startsWith('/api')) {
      reply.header('Cache-Control', 'no-store');
    }
  });

  // Swagger Documentation
  app.register(swagger, {
    openapi: {
      info: {
        title: 'PortWatch API',
        description: 'Server Port & Route Monitoring Dashboard API with Per-Port Feature Registry & Lifecycle Management',
        version: '1.1.0'
      },
      servers: [
        { url: `http://${config.host}:${config.port}`, description: 'Local server' }
      ]
    }
  });

  app.register(swaggerUi, {
    routePrefix: '/api/docs',
    uiConfig: {
      docExpansion: 'list',
      deepLinking: false
    }
  });

  // Health check
  app.get('/api/health', async () => {
    return {
      status: 'healthy',
      time: new Date(),
      uptimeSeconds: Math.round(process.uptime()),
      dbConnected: true
    };
  });

  // Register API routes
  app.register(async (api) => {
    await api.register(authRoutes, { prefix: '/auth' });
    await api.register(overviewRoutes, { scanner });
    await api.register(portsRoutes, { scanner });
    await api.register(routesRoutes);
    await api.register(backendsRoutes, { scanner });
    await api.register(serversRoutes);
    await api.register(issuesRoutes);
    await api.register(configFilesRoutes);
    await api.register(certificatesRoutes, { scanner });
    await api.register(portMapRoutes);
    await api.register(historyRoutes);
    await api.register(customFieldsRoutes);
    await api.register(alertsRoutes);
    await api.register(auditRoutes);
    await api.register(savedViewsRoutes);
    await api.register(importExportRoutes);
    await api.register(scanRoutes, { scanner });
    await api.register(featuresRoutes);
    await api.register(trashRoutes);
  }, { prefix: '/api' });

  // Never leak stack traces / Prisma error internals / source paths to clients
  app.setErrorHandler((error, request, reply) => {
    const status = error.statusCode && error.statusCode >= 400 ? error.statusCode : 500;
    if (status >= 500) {
      request.log.error({ err: error }, 'unhandled error');
      return reply.status(status).send({ error: 'Internal Server Error' });
    }
    return reply.status(status).send({ error: error.message });
  });

  return { app, scanner };
}
