/**
 * QA script: compare PortWatch's stored port statuses against the live `ss -tlnpH` output.
 *
 * Usage:  npx tsx qa-report/scripts/verify-scan.ts [DATABASE_URL]
 *
 * Prints "matches N of M ports" plus every disagreement, and checks the
 * scanner-specific rules that can be verified from data:
 *   - DOWN ports must not carry a bind address / process / latency
 *   - port_checks must not store latency for failed checks
 *   - status vocabulary must be up|down|slow|unknown
 */
import { execFile } from 'child_process';
import { promisify } from 'util';
import { PrismaClient } from '@prisma/client';

const execFileAsync = promisify(execFile);
const prisma = new PrismaClient();

async function liveSs(): Promise<Set<number>> {
  try {
    const { stdout } = await execFileAsync('ss', ['-tlnpH']);
    const ports = new Set<number>();
    for (const line of stdout.split('\n')) {
      const m = line.match(/:(\d+)\s/);
      if (m) ports.add(parseInt(m[1]));
    }
    return ports;
  } catch (e) {
    console.error('ss failed:', e);
    return new Set();
  }
}

async function main() {
  const listening = await liveSs();
  const ports = await prisma.port.findMany({ where: { archivedAt: null } });

  let matches = 0;
  const disagreements: string[] = [];
  for (const p of ports) {
    const shouldBeUp = listening.has(p.port);
    const isUp = p.status === 'up';
    if (shouldBeUp === isUp) matches++;
    else disagreements.push(
      `port ${p.port}: app=${p.status} ss=${shouldBeUp ? 'LISTENING' : 'not listening'}` +
        ` (listenAddress=${p.listenAddress ?? '-'}, bindFromSs=${shouldBeUp})`
    );
  }

  console.log(`Live listening ports on this host: ${listening.size}`);
  console.log(`Documented (non-archived) ports:    ${ports.length}`);
  console.log(`Matches: ${matches} of ${ports.length}`);
  if (disagreements.length) {
    console.log('\nDisagreements:');
    disagreements.forEach(d => console.log('  - ' + d));
  }

  console.log('\n[rule] status vocabulary');
  const badStatus = ports.filter(p => !['up', 'down', 'slow', 'unknown'].includes(p.status));
  console.log(badStatus.length === 0 ? '  ok: only up|down|slow|unknown used'
    : `  FAIL: unexpected statuses ${badStatus.map(b => b.status).join(',')}`);
  console.log('  note: spec-required states down_refused / unreachable do not exist in the schema');

  console.log('\n[rule] DOWN ports must show no bind/process/latency');
  const downWithBind = ports.filter(p => (p.status === 'down' || p.status === 'unknown') && p.listenAddress);
  console.log(downWithBind.length === 0 ? '  ok: no stale bind on non-up ports'
    : `  FAIL: ${downWithBind.length} non-up ports still carry listenAddress: ` +
      downWithBind.slice(0, 8).map(p => `${p.port}=${p.listenAddress}`).join(', '));
  const downWithLatency = ports.filter(p => (p.status === 'down' || p.status === 'unknown') && p.latencyMs != null);
  console.log(downWithLatency.length === 0 ? '  ok: no latency on non-up ports'
    : `  FAIL: ${downWithLatency.length} non-up ports carry latencyMs: ` +
      downWithLatency.slice(0, 8).map(p => `${p.port}=${p.latencyMs}ms`).join(', '));

  console.log('\n[rule] port_checks must not store latency for failed checks');
  const failedWithLatency = await prisma.portCheck.count({
    where: { status: 'down', latencyMs: { not: null } }
  });
  const failedTotal = await prisma.portCheck.count({ where: { status: 'down' } });
  console.log(failedWithLatency === 0 ? '  ok'
    : `  FAIL: ${failedWithLatency} of ${failedTotal} failed checks store a latency value`);

  console.log('\n[rule] $variable targets must never be probed (status unknown, no latency)');
  const variableRoutes = await prisma.route.count({ where: { targetType: { in: ['variable', 'upstream'] } } });
  console.log(`  routes with $variable/upstream targets: ${variableRoutes}`);
  const variableBackends = await prisma.backend.findMany({ where: { host: { contains: '$' } } });
  const probed = variableBackends.filter(
    (b) => b.status !== 'unknown' || b.latencyMs != null
  );
  console.log(`  $-variable backends: ${variableBackends.length} (existence is fine; probing is not)`);
  console.log(probed.length === 0
    ? '  ok: no $variable backend was probed (all status=unknown, latency=null)'
    : `  FAIL: ${probed.length} probed $-variable backends: ` +
      probed.map((b) => `${b.host}=${b.status}/${b.latencyMs}ms`).join(', '));

  await prisma.$disconnect();
}

main().catch(e => { console.error(e); process.exit(1); });
