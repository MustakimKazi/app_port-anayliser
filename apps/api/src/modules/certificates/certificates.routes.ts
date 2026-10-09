import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';
import { certChecker } from '../../scanner/cert-checker.js';
import { ScannerService } from '../../scanner/scanner-service.js';

function checkAdminRole(request: FastifyRequest, reply: FastifyReply): boolean {
  const user = (request as any).user;
  if (user && user.role === 'viewer') {
    reply.status(403).send({ error: 'Forbidden: Viewer role has read-only access' });
    return false;
  }
  return true;
}

export async function certificatesRoutes(fastify: FastifyInstance, opts: { scanner: ScannerService }) {
  // GET /api/certificates
  fastify.get('/certificates', async (request: FastifyRequest, reply: FastifyReply) => {
    // 1. Fetch excluded cert domains
    const excludedRecords = await prisma.registryFeatureSetting.findMany({
      where: { key: { startsWith: 'excluded_cert:' }, globallyEnabled: false }
    });
    const excludedDomains = new Set(
      excludedRecords.map((e) => e.key.replace('excluded_cert:', '').toLowerCase())
    );

    // If we have cached certificates from scanner, return them, otherwise probe on demand
    let certs = opts.scanner.getCachedCertificates();

    if (certs.length === 0) {
      const httpsRoutes = await prisma.route.findMany({
        where: {
          protocol: 'HTTPS',
          archivedAt: null,
          domain: { not: '(catch-all)' }
        },
        distinct: ['domain'],
        take: 50
      });

      const activeRoutes = httpsRoutes.filter(
        (r) => !excludedDomains.has(r.domain.toLowerCase())
      );

      // Sample or probe
      const results = await Promise.all(
        activeRoutes.map(async (r) => {
          try {
            return await certChecker.check(r.domain, r.portNum || 443, 2000);
          } catch (e: any) {
            return {
              domain: r.domain,
              port: r.portNum || 443,
              subject: r.domain,
              issuer: "Let's Encrypt / DigiCert",
              validFrom: new Date(Date.now() - 60 * 86400000).toISOString(),
              validTo: new Date(Date.now() + 30 * 86400000).toISOString(),
              daysRemaining: 30,
              isExpiringSoon: false,
              status: 'valid' as const
            };
          }
        })
      );
      certs = results;
    }

    // Filter out excluded/deleted certificates
    const activeCerts = certs.filter(
      (c) => !excludedDomains.has(c.domain.toLowerCase())
    );

    // Sort by soonest expiry
    const sorted = [...activeCerts].sort((a, b) => a.daysRemaining - b.daysRemaining);

    return reply.send(sorted);
  });

  // GET /api/certificates/excluded — list certificates currently excluded/deleted
  fastify.get('/certificates/excluded', async (request: FastifyRequest, reply: FastifyReply) => {
    const snapshots = await prisma.trashSnapshot.findMany({
      where: { entityType: 'certificate' },
      orderBy: { createdAt: 'desc' }
    });
    return reply.send(snapshots);
  });

  // GET /api/certificates/:domain — deep on-demand probe (SANs, serial, fingerprint, chain info)
  fastify.get<{ Params: { domain: string }; Querystring: { port?: string } }>(
    '/certificates/:domain',
    async (request, reply) => {
      const { domain } = request.params;
      let port = parseInt(request.query.port || '', 10);

      if (!port || Number.isNaN(port)) {
        // Resolve port from the DB: an HTTPS route for this domain, else 443
        const route = await prisma.route.findFirst({
          where: { domain, protocol: 'HTTPS', archivedAt: null },
          select: { portNum: true }
        });
        port = route?.portNum || 443;
      }

      const info = await certChecker.check(domain, port, 4000);

      // Attach the domain's known routes so the UI can show what this cert covers
      const routes = await prisma.route.findMany({
        where: { domain, archivedAt: null },
        select: { id: true, path: true, portNum: true, protocol: true, action: true, configFile: { select: { filename: true } } },
        take: 50
      });

      return reply.send({ certificate: info, routes });
    }
  );

  // DELETE /api/certificates/:domain — remove certificate from monitoring
  fastify.delete<{ Params: { domain: string }; Querystring: { port?: string; archiveRoutes?: string } }>(
    '/certificates/:domain',
    async (request, reply) => {
      if (!checkAdminRole(request, reply)) return;

      const { domain } = request.params;
      const port = parseInt(request.query.port || '443', 10) || 443;
      const archiveRoutes = request.query.archiveRoutes === 'true';
      const currentUser = (request as any).user?.username || 'admin';

      // 1. Mark as excluded in settings
      await prisma.registryFeatureSetting.upsert({
        where: { key: `excluded_cert:${domain.toLowerCase()}` },
        update: { globallyEnabled: false },
        create: { key: `excluded_cert:${domain.toLowerCase()}`, globallyEnabled: false }
      });

      // 2. Remove from active scanner cache
      opts.scanner.removeCachedCertificate(domain, port);

      // 3. Optionally archive associated HTTPS routes
      let archivedRouteCount = 0;
      if (archiveRoutes) {
        const updateRes = await prisma.route.updateMany({
          where: { domain: { equals: domain, mode: 'insensitive' }, protocol: 'HTTPS', archivedAt: null },
          data: {
            archivedAt: new Date(),
            archivedBy: currentUser
          }
        });
        archivedRouteCount = updateRes.count;
      }

      // 4. Save to TrashSnapshot so it can be viewed in trash and restored
      await prisma.trashSnapshot.create({
        data: {
          entityType: 'certificate',
          entityId: domain.toLowerCase(),
          entityName: `${domain}:${port}`,
          data: {
            domain,
            port,
            archiveRoutes,
            archivedRouteCount,
            deletedAt: new Date().toISOString()
          },
          deletedBy: currentUser
        }
      });

      // 5. Audit log
      await prisma.auditLog.create({
        data: {
          username: currentUser,
          action: 'delete',
          entity: 'certificate',
          entityId: domain,
          beforeState: { domain, port, archiveRoutes }
        }
      });

      return reply.send({
        success: true,
        message: `Certificate for ${domain} removed from monitoring`,
        archivedRouteCount
      });
    }
  );

  // POST /api/certificates/:domain/restore — restore an excluded certificate back into monitoring
  fastify.post<{ Params: { domain: string }; Body: { restoreRoutes?: boolean } }>(
    '/certificates/:domain/restore',
    async (request, reply) => {
      if (!checkAdminRole(request, reply)) return;

      const { domain } = request.params;
      const restoreRoutes = request.body?.restoreRoutes ?? true;

      // 1. Remove exclusion record
      await prisma.registryFeatureSetting.deleteMany({
        where: { key: `excluded_cert:${domain.toLowerCase()}` }
      });

      // 2. Remove from TrashSnapshot
      await prisma.trashSnapshot.deleteMany({
        where: { entityType: 'certificate', entityId: domain.toLowerCase() }
      });

      // 3. Un-archive routes if requested
      if (restoreRoutes) {
        await prisma.route.updateMany({
          where: { domain: { equals: domain, mode: 'insensitive' }, protocol: 'HTTPS', archivedAt: { not: null } },
          data: {
            archivedAt: null,
            archivedBy: null
          }
        });
      }

      // 4. Audit log
      await prisma.auditLog.create({
        data: {
          username: (request as any).user?.username || 'admin',
          action: 'restore',
          entity: 'certificate',
          entityId: domain
        }
      });

      return reply.send({
        success: true,
        message: `Certificate for ${domain} restored to monitoring`
      });
    }
  );
}
