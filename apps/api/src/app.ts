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

export function buildApp() {
  const app = Fastify({
    logger: {
      level: config.nodeEnv === 'development' ? 'info' : 'warn'
    }
  });

  const scanner = new ScannerService(prisma);

  // Plugins
  app.register(cors, {
    origin: true,
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

  // Swagger Documentation
  app.register(swagger, {
    openapi: {
      info: {
        title: 'PortWatch API',
        description: 'Server Port & Route Monitoring Dashboard API',
        version: '1.0.0'
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
  }, { prefix: '/api' });

  return { app, scanner };
}
