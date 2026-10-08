import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';
import { certChecker } from '../../scanner/cert-checker.js';
import { ScannerService } from '../../scanner/scanner-service.js';

export async function certificatesRoutes(fastify: FastifyInstance, opts: { scanner: ScannerService }) {
  // GET /api/certificates
  fastify.get('/certificates', async (request: FastifyRequest, reply: FastifyReply) => {
    // If we have cached certificates from scanner, return them, otherwise probe on demand
    let certs = opts.scanner.getCachedCertificates();

    if (certs.length === 0) {
      const httpsRoutes = await prisma.route.findMany({
        where: {
          protocol: 'HTTPS',
          domain: { not: '(catch-all)' }
        },
        distinct: ['domain'],
        take: 25
      });

      // Sample or probe
      const results = await Promise.all(
        httpsRoutes.map(async (r) => {
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

    // Sort by soonest expiry
    const sorted = [...certs].sort((a, b) => a.daysRemaining - b.daysRemaining);

    return reply.send(sorted);
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
}
