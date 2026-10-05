import { FastifyReply } from 'fastify';

interface SSEClient {
  id: string;
  reply: FastifyReply;
}

class SSEManager {
  private clients: Map<string, SSEClient> = new Map();

  addClient(id: string, reply: FastifyReply) {
    this.clients.set(id, { id, reply });

    // Send initial ping
    reply.raw.write(`event: connected\ndata: ${JSON.stringify({ message: 'Connected to PortWatch SSE stream', time: new Date() })}\n\n`);

    // Clean up when client disconnects
    reply.raw.on('close', () => {
      this.clients.delete(id);
    });
  }

  removeClient(id: string) {
    this.clients.delete(id);
  }

  broadcast(event: string, data: any) {
    const payload = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
    for (const [id, client] of this.clients.entries()) {
      try {
        client.reply.raw.write(payload);
      } catch (err) {
        this.clients.delete(id);
      }
    }
  }

  getClientCount(): number {
    return this.clients.size;
  }
}

export const sseManager = new SSEManager();
