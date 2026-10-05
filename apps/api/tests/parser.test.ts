import { describe, it, expect } from 'vitest';
import * as path from 'path';
import * as xlsx from 'xlsx';
import { parseWorkbook } from '../src/modules/import-export/import-excel.js';

describe('Workbook Parser Unit Tests', () => {
  const filePath = path.resolve(process.cwd(), '../../nginx_documentation.xlsx');
  const wb = xlsx.readFile(filePath);
  const parsed = parseWorkbook(wb);

  it('parses exactly 48 config files', () => {
    expect(parsed.configFiles.length).toBe(48);
    const backupFiles = parsed.configFiles.filter(f => f.status === 'backup');
    expect(backupFiles.length).toBe(10);
  });

  it('parses all ports (19 ports: 13 HTTP + 6 TCP stream)', () => {
    expect(parsed.ports.length).toBe(19);
    const streamPorts = parsed.ports.filter(p => p.layer === 'stream');
    expect(streamPorts.length).toBe(6);
    expect(streamPorts.map(p => p.port)).toEqual([7001, 7002, 7003, 60007, 60008, 60009]);
  });

  it('parses exactly 34 backends', () => {
    expect(parsed.backends.length).toBe(34);
    const localhostBackends = parsed.backends.filter(b => b.host === 'localhost');
    expect(localhostBackends.length).toBeGreaterThan(0);
  });

  it('parses exactly 106 routes from Domain Map', () => {
    expect(parsed.routes.length).toBe(106);

    // Verify unresolved target handling (not crashing or null)
    const helixRoute = parsed.routes.find(r => r.targetRaw.includes('helix_backend'));
    expect(helixRoute).toBeDefined();
    expect(helixRoute?.targetType).toBe('upstream');

    const jellyfinRoute = parsed.routes.find(r => r.targetRaw.includes('$jellyfin'));
    expect(jellyfinRoute).toBeDefined();
    expect(jellyfinRoute?.targetType).toBe('variable');

    // Verify row 106 uncaptured port handling
    const row106 = parsed.routes.find(r => r.rowNum === 106);
    expect(row106).toBeDefined();
    expect(row106?.portRaw).toBe('(not captured)');
    expect(row106?.portNum).toBeNull();
    expect(row106?.isCatchAll).toBe(true);
  });

  it('parses exactly 12 issues & checks', () => {
    expect(parsed.issues.length).toBe(12);
    const highIssues = parsed.issues.filter(i => i.priority === 'High');
    expect(highIssues.length).toBe(3);
  });
});
