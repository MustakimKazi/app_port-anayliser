/**
 * QA script: compare nginx_documentation.xlsx row-by-row with the database.
 *
 * Usage:
 *   DATABASE_URL=postgresql://.../portwatch_qa npx tsx qa-report/scripts/compare-excel-vs-db.ts
 *
 * Exits non-zero if any mismatch is found.
 */
import * as path from 'path';
import * as xlsx from 'xlsx';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const EXPECTED = { routes: 106, ports: 19, backends: 34, configFiles: 48, issues: 12 };

let failures = 0;
const fail = (msg: string) => { failures++; console.log('  MISMATCH: ' + msg); };
const ok = (msg: string) => console.log('  ok: ' + msg);

async function main() {
  const file = path.resolve(process.cwd(), 'nginx_documentation.xlsx');
  const wb = xlsx.readFile(file);
  const db = process.env.DATABASE_URL || '';
  console.log('DB: ' + db.replace(/:[^:@]*@/, ':***@'));

  // ---------- counts ----------
  console.log('\n[1] Row counts');
  const [nRoutes, nPorts, nBackends, nFiles, nIssues] = await Promise.all([
    prisma.route.count(),
    prisma.port.count(),
    prisma.backend.count(),
    prisma.configFile.count(),
    prisma.issue.count()
  ]);
  const counts: [string, number, number][] = [
    ['routes', EXPECTED.routes, nRoutes],
    ['ports', EXPECTED.ports, nPorts],
    ['backends', EXPECTED.backends, nBackends],
    ['config_files', EXPECTED.configFiles, nFiles],
    ['issues', EXPECTED.issues, nIssues]
  ];
  for (const [name, exp, got] of counts) {
    (got === exp ? ok : fail)(`${name}: expected ${exp}, got ${got}`);
  }

  // ---------- Domain Map (routes) ----------
  console.log('\n[2] Domain Map -> routes (row by row)');
  const rawRoutes = xlsx.utils.sheet_to_json<any>(wb.Sheets['Domain Map'], { defval: '' });
  const dbRoutes = await prisma.route.findMany({ include: { port: true, backend: true, configFile: true } });
  const byRowNum = new Map<number, typeof dbRoutes[number]>();
  for (const r of dbRoutes) if (r.rowNum != null) byRowNum.set(r.rowNum, r);

  let missing = 0, fieldMismatch = 0;
  for (const r of rawRoutes) {
    const num = parseInt(String(r['#']));
    if (isNaN(num)) continue;
    const db = byRowNum.get(num);
    if (!db) { missing++; fail(`route rowNum ${num} (${r['Domain']} ${r['Path']}) not in DB`); continue; }
    const xDomain = String(r['Domain'] || '').trim();
    const xPort = parseInt(String(r['Port']));
    const xPath = String(r['Path'] || '').trim();
    const xTarget = String(r['Target / Backend'] || '').trim();
    const xAction = String(r['Action'] || '').trim();

    if (db.action !== xAction) { fieldMismatch++; fail(`#${num} action: excel "${xAction}" db "${db.action}"`); }
    if (!isNaN(xPort) && db.portNum !== xPort) { fieldMismatch++; fail(`#${num} port: excel ${xPort} db ${db.portNum}`); }
    if (db.targetRaw !== xTarget) { fieldMismatch++; fail(`#${num} target: excel "${xTarget}" db "${db.targetRaw}"`); }
    const excelPaths = xPath.split(/[,\n]/).map((p: string) => p.trim()).filter(Boolean);
    for (const p of excelPaths) {
      if (!db.paths.includes(p)) { fieldMismatch++; fail(`#${num} path "${p}" missing from db paths [${db.paths.join(' | ')}]`); }
    }
    if (xDomain.toLowerCase().includes('server_name _') || !xDomain) {
      if (!db.isCatchAll) { fieldMismatch++; fail(`#${num} catch-all not flagged (domain "${xDomain}")`); }
    } else {
      const clean = xDomain.replace(/\s*\(server_name _\)/i, '').replace(/\s*\(catch-all.*?\)/i, '').replace(/^\(|\)$/g, '').trim();
      if (db.domain !== clean && db.domainRaw !== xDomain) {
        fieldMismatch++; fail(`#${num} domain: excel "${xDomain}" db "${db.domain}"`);
      }
    }
  }
  if (!missing && !fieldMismatch) ok(`all ${rawRoutes.length} Domain Map rows match`);

  // extras in DB not in Excel (beyond expected seed)
  const excelRowNums = new Set(rawRoutes.map((r: any) => parseInt(String(r['#']))).filter((n: number) => !isNaN(n)));
  const extras = dbRoutes.filter(r => r.rowNum != null && !excelRowNums.has(r.rowNum));
  if (extras.length) fail(`${extras.length} routes in DB have no Excel row (rowNums: ${extras.map(e => e.rowNum).join(',')})`);

  // ---------- special route semantics ----------
  console.log('\n[3] Special route semantics');
  const catchAlls = dbRoutes.filter(r => r.isCatchAll);
  const excelCatchAlls = rawRoutes.filter((r: any) => {
    const d = String(r['Domain'] || '').toLowerCase();
    return d.includes('server_name _') || d.includes('catch-all') || !d.trim();
  }).length;
  (catchAlls.length === excelCatchAlls ? ok : fail)(`catch-all routes: excel ${excelCatchAlls}, db ${catchAlls.length}`);

  const upstreams = dbRoutes.filter(r => r.targetType === 'upstream');
  const variables = dbRoutes.filter(r => r.targetType === 'variable');
  const excelUpstream = rawRoutes.filter((r: any) => String(r['Target / Backend'] || '').toLowerCase().includes('upstream')).length;
  const excelVar = rawRoutes.filter((r: any) => {
    const t = String(r['Target / Backend'] || ''); const h = String(r['Backend Host'] || '');
    return t.includes('$') || t.includes('(variable)') || h.includes('$') || h.includes('variable');
  }).length;
  (upstreams.length === excelUpstream ? ok : fail)(`upstream targets: excel ${excelUpstream}, db ${upstreams.length}`);
  (variables.length === excelVar ? ok : fail)(`$variable targets: excel ${excelVar}, db ${variables.length}`);

  const notCaptured = rawRoutes.filter((r: any) => String(r['Target / Backend'] || '').toLowerCase().includes('not captured')).length;
  const dbUnknown = dbRoutes.filter(r => r.targetType === 'unknown').length;
  (dbUnknown >= notCaptured ? ok : fail)(`(not captured) targets: excel ${notCaptured}, db unknown-type ${dbUnknown}`);

  const formulaCells = rawRoutes.filter((r: any) => typeof r['Target / Backend'] === 'string' && /^\=\w/.test(r['Target / Backend'])).length;
  (formulaCells === 0 ? ok : fail)(`formula-looking target cells in Excel: ${formulaCells} (must be imported as text)`);

  // ---------- Port Summary ----------
  console.log('\n[4] Port Summary -> ports');
  const rawPorts = xlsx.utils.sheet_to_json<any>(wb.Sheets['Port Summary'], { defval: '' });
  const dbPorts = await prisma.port.findMany();
  const dbPortNums = new Set(dbPorts.map(p => p.port));
  for (const r of rawPorts) {
    const p = parseInt(String(r['Port']));
    if (isNaN(p)) continue;
    if (!dbPortNums.has(p)) fail(`port ${p} (${r['Purpose']}) missing in DB`);
  }
  if (rawPorts.filter((r: any) => !isNaN(parseInt(String(r['Port'])))).length === rawPorts.length && dbPorts.length === rawPorts.length) {
    ok(`all ${rawPorts.length} ports present, no extras`);
  } else if (dbPorts.length !== rawPorts.length) {
    fail(`port count excel ${rawPorts.length} vs db ${dbPorts.length}`);
  }

  // ---------- Backends ----------
  console.log('\n[5] Backends -> backends');
  const rawBackends = xlsx.utils.sheet_to_json<any>(wb.Sheets['Backends'], { defval: '' });
  const dbBackends = await prisma.backend.findMany();
  const dbKey = new Set(dbBackends.map(b => `${b.host}:${b.port}`));
  let beMissing = 0;
  for (const r of rawBackends) {
    const h = String(r['Backend Host'] || '').trim();
    const p = parseInt(String(r['Backend Port']));
    if (!h || isNaN(p)) continue;
    if (!dbKey.has(`${h}:${p}`)) { beMissing++; fail(`backend ${h}:${p} missing in DB`); }
  }
  if (!beMissing) ok(`all backends present (db has ${dbBackends.length}, excel ${rawBackends.length})`);

  // ---------- Config Files ----------
  console.log('\n[6] Config Files -> config_files');
  const rawFiles = xlsx.utils.sheet_to_json<any>(wb.Sheets['Config Files'], { defval: '' });
  const dbFiles = await prisma.configFile.findMany();
  const dbNames = new Set(dbFiles.map(f => f.filename));
  let cfMissing = 0;
  for (const r of rawFiles) {
    const name = String(r['Config File'] || '').trim();
    if (!name) continue;
    if (!dbNames.has(name)) { cfMissing++; fail(`config file "${name}" missing in DB`); }
  }
  if (!cfMissing) ok(`all config files present (db ${dbFiles.length}, excel ${rawFiles.length})`);
  const excelBackups = rawFiles.filter((r: any) => /backup|save|old|inactive|not loaded/i.test(String(r['Status'] || ''))).length;
  const dbBackups = dbFiles.filter(f => f.status === 'backup').length;
  (excelBackups === dbBackups ? ok : fail)(`backup config files: excel ${excelBackups}, db ${dbBackups}`);

  // ---------- Issues ----------
  console.log('\n[7] Issues & Checks -> issues');
  const rawIssues = xlsx.utils.sheet_to_json<any>(wb.Sheets['Issues & Checks'], { defval: '' });
  const dbIssues = await prisma.issue.findMany({ where: { source: 'imported' } });
  const dbTitles = new Set(dbIssues.map(i => i.title));
  for (const r of rawIssues) {
    const t = String(r['Item'] || '').trim();
    if (!t) continue;
    if (!dbTitles.has(t)) fail(`imported issue "${t}" missing in DB`);
  }
  if (dbIssues.length === rawIssues.length) ok(`all ${rawIssues.length} imported issues present`);

  console.log(`\n==== ${failures === 0 ? 'PASS' : failures + ' MISMATCHES'} ====`);
  await prisma.$disconnect();
  process.exit(failures === 0 ? 0 : 1);
}

main().catch(e => { console.error(e); process.exit(2); });
