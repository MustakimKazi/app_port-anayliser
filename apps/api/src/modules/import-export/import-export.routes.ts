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
    try {
      const wb = xlsx.read(buffer, { type: 'buffer' });
      const parsed = parseWorkbook(wb);
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
      return reply.status(500).send({
        error: 'Failed to process spreadsheet file',
        details: err.message
      });
    }
  });

  // GET /api/export - Export table data to CSV, XLSX, or JSON
  fastify.get('/export', async (request: FastifyRequest, reply: FastifyReply) => {
    const { entity = 'ports', format = 'csv' } = request.query as { entity?: string; format?: string };

    let data: any[] = [];
    let filename = `portwatch-${entity}-${new Date().toISOString().split('T')[0]}`;

    if (entity === 'ports') {
      data = await prisma.$queryRawUnsafe('SELECT * FROM v_port_overview ORDER BY port ASC');
    } else if (entity === 'routes') {
      data = await prisma.route.findMany({
        orderBy: { rowNum: 'asc' },
        include: { port: true, backend: true, configFile: true }
      });
    } else if (entity === 'backends') {
      data = await prisma.backend.findMany({
        orderBy: [{ host: 'asc' }, { port: 'asc' }],
        include: { server: true }
      });
    } else if (entity === 'issues') {
      data = await prisma.issue.findMany({
        orderBy: { issueNum: 'asc' }
      });
    }

    if (format === 'json') {
      reply.header('Content-Type', 'application/json');
      reply.header('Content-Disposition', `attachment; filename="${filename}.json"`);
      return reply.send(data);
    }

    const worksheet = xlsx.utils.json_to_sheet(data);
    const workbook = xlsx.utils.book_new();
    xlsx.utils.book_append_sheet(workbook, worksheet, entity);

    if (format === 'xlsx') {
      const buffer = xlsx.write(workbook, { type: 'buffer', bookType: 'xlsx' });
      reply.header('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      reply.header('Content-Disposition', `attachment; filename="${filename}.xlsx"`);
      return reply.send(buffer);
    }

    // Default: CSV
    const csv = xlsx.utils.sheet_to_csv(worksheet);
    reply.header('Content-Type', 'text/csv');
    reply.header('Content-Disposition', `attachment; filename="${filename}.csv"`);
    return reply.send(csv);
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
