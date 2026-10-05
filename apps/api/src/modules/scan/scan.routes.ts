import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { ScannerService } from '../../scanner/scanner-service.js';
import { sseManager } from '../../realtime/sse.js';

export async function scanRoutes(fastify: FastifyInstance, opts: { scanner: ScannerService }) {
  // POST /api/scan - Trigger full system scan
  fastify.post('/scan', async (request: FastifyRequest, reply: FastifyReply) => {
    if (opts.scanner.isCurrentlyScanning()) {
      return reply.send({ message: 'Scan already in progress' });
    }

    // Run asynchronously or await
    const resultPromise = opts.scanner.runScan();
    return reply.send({
      message: 'Scan triggered successfully',
      status: 'running'
    });
  });

  // POST /api/scan/:type/:id - Trigger individual target check
  fastify.post('/scan/:type/:id', async (
    request: FastifyRequest<{ Params: { type: 'port' | 'backend'; id: string } }>,
    reply: FastifyReply
  ) => {
    const { type, id } = request.params;
    if (type !== 'port' && type !== 'backend') {
      return reply.status(400).send({ error: "Type must be 'port' or 'backend'" });
    }

    try {
      const result = await opts.scanner.checkTarget(type, id);
      return reply.send({
        success: true,
        target: `${type}:${id}`,
        result
      });
    } catch (e: any) {
      return reply.status(404).send({ error: e.message });
    }
  });

  // GET /api/scan/status
  fastify.get('/scan/status', async (request: FastifyRequest, reply: FastifyReply) => {
    return reply.send({
      isScanning: opts.scanner.isCurrentlyScanning(),
      lastScanTime: opts.scanner.getLastScanTime()
    });
  });

  // GET /api/stream - Server-Sent Events (SSE)
  fastify.get('/stream', async (request: FastifyRequest, reply: FastifyReply) => {
    reply.raw.setHeader('Content-Type', 'text/event-stream');
    reply.raw.setHeader('Cache-Control', 'no-cache');
    reply.raw.setHeader('Connection', 'keep-alive');
    reply.raw.setHeader('Access-Control-Allow-Origin', '*');

    const clientId = Math.random().toString(36).substring(2, 9);
    sseManager.addClient(clientId, reply);

    // Keep connection open
    await new Promise(() => {});
  });
}
