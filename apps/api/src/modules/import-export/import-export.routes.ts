import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import * as xlsx from 'xlsx';
import prisma from '../../db/prisma.js';
import { parseWorkbook, importParsedData } from './import-excel.js';

export async function importExportRoutes(fastify: FastifyInstance) {
  // POST /api/import - Upload .xlsx or .csv and import into database
  fastify.post('/import', async (request: FastifyRequest, reply: FastifyReply) => {
    const data = await request.file();
    if (!data) {
      return reply.status(400).send({ error: 'No file uploaded' });
    }

    const buffer = await data.toBuffer();
    let phase: 'parse' | 'write' = 'parse';
    try {
      const wb = xlsx.read(buffer, { type: 'buffer' });
      const parsed = parseWorkbook(wb);
      phase = 'write';
      const result = await importParsedData(prisma, parsed);

      await prisma.auditLog.create({
        data: {
          username: (request as any).user?.username || 'admin',
          action: 'import',
          entity: 'workbook',
          afterState: result as any
        }
      });

      return reply.send({
        success: true,
        message: 'Import completed successfully',
        result
      });
    } catch (err: any) {
      request.log.error({ err, phase }, 'import failed');
      if (phase === 'parse') {
        // Bad/foreign/empty file: report it, change nothing (HTTP 400)
        return reply.status(400).send({ error: `Could not import file: ${err.message}` });
      }
      return reply.status(500).send({ error: 'Import failed while writing to the database' });
    }
  });

  // GET /api/export - Export table data to CSV, XLSX, or JSON
  fastify.get('/export', async (request: FastifyRequest, reply: FastifyReply) => {
    const query = request.query as Record<string, string | undefined>;
    const { entity = 'ports', format = 'csv' } = query;

    // Allowlist: an unknown entity used to return 200 with an empty file
    const EXPORTABLE = ['ports', 'routes', 'backends', 'issues'];
    if (!EXPORTABLE.includes(entity)) {
      return reply
        .status(400)
        .send({ error: `Unknown entity '${entity}'. Supported: ${EXPORTABLE.join(', ')}` });
    }

    const showArchived = query.showArchived === 'true';
    const q = (query.q || '').toLowerCase();
    const statusFilter = query.status;
    const lifecycleFilter = query.lifecycle
      ? query.lifecycle.split(',').map((s) => s.trim().toLowerCase())
      : null;

    let data: any[] = [];
    const now = new Date();
    const pad = (n: number) => String(n).padStart(2, '0');
    const timestamp = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}` +
      `-${pad(now.getHours())}${pad(now.getMinutes())}`; // date + time (date alone was ambiguous)
    let filename = `portwatch-${entity}-${timestamp}`;

    if (entity === 'ports') {
      data = await prisma.$queryRawUnsafe('SELECT * FROM v_port_overview ORDER BY port ASC');
      // Same visibility rules as the Ports page: archived rows are excluded
      // unless the caller explicitly asks for them
      if (!showArchived) {
        data = data.filter(
          (r: any) => !r.archivedAt && String(r.lifecycle || '').toLowerCase() !== 'archived'
        );
      }
      if (statusFilter) data = data.filter((r: any) => r.status === statusFilter);
      if (lifecycleFilter) {
        data = data.filter((r: any) => lifecycleFilter.includes(String(r.lifecycle || '').toLowerCase()));
      }
      if (q) {
        data = data.filter((r: any) =>
          [r.port, r.purpose, r.processName, r.listenAddress, r.lifecycle]
            .some((v) => String(v ?? '').toLowerCase().includes(q))
        );
      }
    } else if (entity === 'routes') {
      data = await prisma.route.findMany({
        where: showArchived ? {} : { archivedAt: null },
        orderBy: { rowNum: 'asc' },
        include: { port: true, backend: true, configFile: true }
      });
      if (q) {
        data = data.filter((r: any) =>
          [r.domain, r.domainRaw, r.targetRaw, r.path].some((v) =>
            String(v ?? '').toLowerCase().includes(q)
          )
        );
      }
    } else if (entity === 'backends') {
      data = await prisma.backend.findMany({
        where: showArchived ? {} : { archivedAt: null },
        orderBy: [{ host: 'asc' }, { port: 'asc' }],
        include: { server: true }
      });
      if (q) {
        data = data.filter((r: any) =>
          [r.host, r.port, r.label].some((v) => String(v ?? '').toLowerCase().includes(q))
        );
      }
    } else if (entity === 'issues') {
      data = await prisma.issue.findMany({
        orderBy: { issueNum: 'asc' }
      });
      if (q) {
        data = data.filter((r: any) =>
          [r.title, r.observed, r.recommendation].some((v) =>
            String(v ?? '').toLowerCase().includes(q)
          )
        );
      }
    }

    if (format === 'json') {
      reply.header('Content-Type', 'application/json');
      reply.header('Content-Disposition', `attachment; filename="${filename}.json"`);
      return reply.send(data);
    }

    // Flatten nested relations into dotted columns (ports.port, backend.host, ...)
    // so CSV/XLSX cells are not blank, and neutralise CSV formula injection
    // (cells starting with =, +, -, @, TAB, CR get a leading apostrophe)
    const flattenRow = (row: any): Record<string, any> => {
      const out: Record<string, any> = {};
      for (const [k, v] of Object.entries(row)) {
        if (v !== null && typeof v === 'object') {
          if (Array.isArray(v)) {
            out[k] = JSON.stringify(v);
          } else {
            for (const [k2, v2] of Object.entries(v as object)) {
              out[`${k}.${k2}`] = v2 === null || v2 === undefined
                ? ''
                : typeof v2 === 'object'
                  ? JSON.stringify(v2)
                  : v2;
            }
          }
        } else {
          out[k] = v;
        }
      }
      for (const [k, v] of Object.entries(out)) {
        if (typeof v === 'string' && /^[=+\-@\t\r]/.test(v)) {
          out[k] = `'${v}`;
        }
      }
      return out;
    };

    const flatData = data.map(flattenRow);
    const worksheet = xlsx.utils.json_to_sheet(flatData);
    const workbook = xlsx.utils.book_new();
    xlsx.utils.book_append_sheet(workbook, worksheet, entity);

    if (format === 'xlsx') {
      const buffer = xlsx.write(workbook, { type: 'buffer', bookType: 'xlsx' });
      reply.header('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      reply.header('Content-Disposition', `attachment; filename="${filename}.xlsx"`);
      return reply.send(buffer);
    }

    // Default: CSV (with UTF-8 BOM so Excel renders non-ASCII correctly)
    const csv = xlsx.utils.sheet_to_csv(worksheet);
    reply.header('Content-Type', 'text/csv; charset=utf-8');
    reply.header('Content-Disposition', `attachment; filename="${filename}.csv"`);
    return reply.send(`\ufeff${csv}`); // BOM
  });

  // GET /api/backup - Full database backup in JSON
  fastify.get('/backup', async (request: FastifyRequest, reply: FastifyReply) => {
    const [servers, ports, routes, backends, configFiles, issues, customFields, alertRules, settings] = await Promise.all([
      prisma.server.findMany(),
      prisma.port.findMany(),
      prisma.route.findMany(),
      prisma.backend.findMany(),
      prisma.configFile.findMany(),
      prisma.issue.findMany(),
      prisma.customField.findMany(),
      prisma.alertRule.findMany(),
      prisma.setting.findMany()
    ]);

    const backupData = {
      version: '1.0',
      exportedAt: new Date(),
      servers,
      ports,
      routes,
      backends,
      configFiles,
      issues,
      customFields,
      alertRules,
      settings
    };

    reply.header('Content-Type', 'application/json');
    reply.header('Content-Disposition', `attachment; filename="portwatch-backup-${new Date().toISOString().split('T')[0]}.json"`);
    return reply.send(backupData);
  });
}
