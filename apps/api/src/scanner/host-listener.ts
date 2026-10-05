import { execFile } from 'child_process';
import { promisify } from 'util';
import { config } from '../config/env.js';

const execFileAsync = promisify(execFile);

export interface ListeningPortInfo {
  port: number;
  bindAddress: string;
  isPublic: boolean;
  processName?: string;
  pid?: number;
}

export class HostListener {
  /**
   * Scans local listening ports on the host system.
   * Uses safe execFile with argument arrays to prevent shell injection.
   */
  async getListeningPorts(): Promise<Map<number, ListeningPortInfo>> {
    const results = new Map<number, ListeningPortInfo>();

    if (config.scannerMode === 'mock') {
      // In isolated demo/mock mode, return simulated state based on common ports
      return this.getMockListeningPorts();
    }

    try {
      // Try ss -tlnpH (socket statistics, TCP, listening, numeric, processes, no header)
      const { stdout } = await execFileAsync('ss', ['-tlnpH'], { timeout: 4000 });
      this.parseSsOutput(stdout, results);
      return results;
    } catch (ssErr) {
      try {
        // Fallback to netstat -tlnp
        const { stdout } = await execFileAsync('netstat', ['-tlnp'], { timeout: 4000 });
        this.parseNetstatOutput(stdout, results);
        return results;
      } catch (netstatErr) {
        // If neither command is available (e.g. strict docker container without host network)
        // Return empty or mock based on mode
        console.warn('Could not read host listening sockets via ss/netstat');
        return results;
      }
    }
  }

  private parseSsOutput(stdout: string, results: Map<number, ListeningPortInfo>) {
    const lines = stdout.split('\n');
    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed) continue;

      // ss columns typically: State Recv-Q Send-Q Local Address:Port Peer Address:Port Process
      const parts = trimmed.split(/\s+/);
      if (parts.length < 4) continue;

      // Local address is usually at index 3
      const localAddr = parts[3];
      const parsed = this.parseAddressPort(localAddr);
      if (!parsed) continue;

      const { port, bindAddress, isPublic } = parsed;

      // Process info may be in column 5 or 6 (e.g. users:(("nginx",pid=123,fd=4)))
      let processName: string | undefined;
      let pid: number | undefined;

      const processPart = parts.slice(5).join(' ');
      const match = processPart.match(/users:\(\("([^"]+)",pid=(\d+)/);
      if (match) {
        processName = match[1];
        pid = parseInt(match[2], 10);
      }

      results.set(port, {
        port,
        bindAddress,
        isPublic,
        processName,
        pid
      });
    }
  }

  private parseNetstatOutput(stdout: string, results: Map<number, ListeningPortInfo>) {
    const lines = stdout.split('\n');
    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('Active') || trimmed.startsWith('Proto')) continue;

      const parts = trimmed.split(/\s+/);
      if (parts.length < 4) continue;

      const localAddr = parts[3];
      const parsed = this.parseAddressPort(localAddr);
      if (!parsed) continue;

      const { port, bindAddress, isPublic } = parsed;

      let processName: string | undefined;
      let pid: number | undefined;

      const procStr = parts[parts.length - 1]; // e.g. 1234/nginx
      if (procStr && procStr.includes('/')) {
        const [pidStr, name] = procStr.split('/');
        pid = parseInt(pidStr, 10);
        processName = name;
      }

      results.set(port, {
        port,
        bindAddress,
        isPublic,
        processName,
        pid
      });
    }
  }

  private parseAddressPort(addrStr: string): { port: number; bindAddress: string; isPublic: boolean } | null {
    // Examples: 0.0.0.0:80, *:80, 127.0.0.1:8080, [::]:443, [::1]:8080, :::80, 192.168.1.100:3000
    const lastColon = addrStr.lastIndexOf(':');
    if (lastColon === -1) return null;

    const portStr = addrStr.substring(lastColon + 1);
    const port = parseInt(portStr, 10);
    if (isNaN(port)) return null;

    let bindAddress = addrStr.substring(0, lastColon);
    bindAddress = bindAddress.replace(/^\[|\]$/g, ''); // Remove IPv6 brackets

    const isLocal =
      bindAddress === '127.0.0.1' ||
      bindAddress === '::1' ||
      bindAddress === 'localhost';

    const isPublic = !isLocal;

    return { port, bindAddress, isPublic };
  }

  private getMockListeningPorts(): Map<number, ListeningPortInfo> {
    const mock = new Map<number, ListeningPortInfo>();
    const known = [80, 443, 3009, 3021, 3022, 4000, 4020, 8080, 10080, 10081, 10180, 10181, 28096, 7001, 7002, 7003, 60007, 60008, 60009];
    for (const p of known) {
      mock.set(p, {
        port: p,
        bindAddress: p === 8080 ? '127.0.0.1' : '0.0.0.0',
        isPublic: p !== 8080,
        processName: 'nginx',
        pid: 1042
      });
    }
    return mock;
  }
}

export const hostListener = new HostListener();
