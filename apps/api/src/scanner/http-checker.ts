import https from 'https';
import http from 'http';

export interface HTTPCheckResult {
  status: 'up' | 'down' | 'slow';
  statusCode?: number;
  latencyMs: number;
  error?: string;
}

export class HTTPChecker {
  /**
   * Performs an HTTP or HTTPS probe to a route.
   * Respects SNI (Server Name Indication) using the domain.
   */
  async check(
    protocol: string,
    domain: string,
    port: number,
    path: string = '/',
    timeoutMs: number = 3500,
    slowThresholdMs: number = 1500
  ): Promise<HTTPCheckResult> {
    const isHttps = protocol.toUpperCase() === 'HTTPS' || port === 443;
    const client = isHttps ? https : http;
    const startTime = performance.now();

    return new Promise((resolve) => {
      let resolved = false;

      const finish = (status: 'up' | 'down' | 'slow', statusCode?: number, err?: string) => {
        if (resolved) return;
        resolved = true;
        const latencyMs = Math.round(performance.now() - startTime);
        resolve({
          status,
          statusCode,
          latencyMs,
          error: err
        });
      };

      const options: https.RequestOptions = {
        hostname: domain === '(catch-all)' || domain.includes('default') ? '127.0.0.1' : domain,
        port,
        path: path.startsWith('/') ? path : `/${path}`,
        method: 'GET',
        headers: {
          'User-Agent': 'PortWatch-Prober/1.0',
          'Host': domain === '(catch-all)' ? 'localhost' : domain
        },
        timeout: timeoutMs,
        rejectUnauthorized: false, // Allow checking servers with self-signed / internal certs
        servername: isHttps ? (domain.includes('.') ? domain : undefined) : undefined // SNI
      };

      const req = client.request(options, (res) => {
        res.resume(); // Consume data
        const latencyMs = Math.round(performance.now() - startTime);
        const status = latencyMs > slowThresholdMs ? 'slow' : 'up';
        finish(status, res.statusCode);
      });

      req.on('timeout', () => {
        req.destroy();
        finish('down', undefined, `HTTP request timed out after ${timeoutMs}ms`);
      });

      req.on('error', (err) => {
        finish('down', undefined, err.message);
      });

      req.end();
    });
  }
}

export const httpChecker = new HTTPChecker();
