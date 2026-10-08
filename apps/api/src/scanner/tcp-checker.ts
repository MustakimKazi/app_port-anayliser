import net from 'net';

export interface TCPCheckResult {
  status: 'up' | 'down' | 'slow';
  /**
   * Round-trip time of a SUCCESSFUL connection. `null` for failed checks:
   * a connection that never completed has no meaningful latency, and storing
   * "latency for a down port" corrupts uptime/latency reporting.
   */
  latencyMs: number | null;
  error?: string;
}

export class TCPChecker {
  /**
   * Connects to host:port via TCP socket.
   * Measures latency. Resolves 'up', 'down', or 'slow' based on slow threshold.
   */
  async check(
    host: string,
    port: number,
    timeoutMs: number = 3000,
    slowThresholdMs: number = 1500
  ): Promise<TCPCheckResult> {
    const startTime = performance.now();

    return new Promise((resolve) => {
      const socket = new net.Socket();
      let resolved = false;

      const finish = (status: 'up' | 'down' | 'slow', err?: string) => {
        if (resolved) return;
        resolved = true;
        // Only successful checks (up/slow) report a latency value
        const latencyMs =
          status === 'down' ? null : Math.round(performance.now() - startTime);
        socket.destroy();
        resolve({
          status,
          latencyMs,
          error: err
        });
      };

      socket.setTimeout(timeoutMs);

      socket.connect(port, host === 'localhost' ? '127.0.0.1' : host, () => {
        const latencyMs = Math.round(performance.now() - startTime);
        const status = latencyMs > slowThresholdMs ? 'slow' : 'up';
        finish(status);
      });

      socket.on('timeout', () => {
        finish('down', `TCP connection timed out after ${timeoutMs}ms`);
      });

      socket.on('error', (err) => {
        finish('down', err.message);
      });
    });
  }
}

export const tcpChecker = new TCPChecker();
