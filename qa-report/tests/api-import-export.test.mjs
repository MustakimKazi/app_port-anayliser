/**
 * Regression tests for BUG-002 (import wipes routes) and
 * BUG-006/007/008 (export filters, CSV injection, empty entity, BOM).
 *
 * Run:  node qa-report/tests/api-import-export.test.mjs [API_URL]
 * WARNING: the import test must only be run against a DISPOSABLE database
 * (set IMPORT_TEST=1 and point API_URL at a scratch instance, e.g. portwatch_qa).
 * It verifies that a garbage upload no longer destroys the route table.
 *
 * BEFORE the patches:
 *  - POST /api/import with a non-spreadsheet returns 500 "success-ish" paths and
 *    route.deleteMany({}) wipes all 106 routes when the parse yields 0 rows
 *  - GET /api/export?entity=nope returns 200 with an empty CSV
 *  - CSV has no UTF-8 BOM, includes archived rows, and does not escape =+-@ cells
 */
const API = process.argv[2] || process.env.API_URL || 'http://localhost:3100';
let failures = 0;

function check(name, cond, detail) {
  if (cond) console.log(`  PASS  ${name}`);
  else {
    failures++;
    console.log(`  FAIL  ${name}${detail ? ' — ' + detail : ''}`);
  }
}

// Acquire an admin session (required once the auth patches are applied;
// harmless before them, where requests are accepted anonymously).
let SESSION = '';
async function login() {
  const res = await fetch(API + '/api/auth/login', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({
      username: process.env.ADMIN_USER || 'admin',
      password: process.env.ADMIN_PASS || 'admin'
    })
  });
  if (res.ok) {
    const cookies =
      typeof res.headers.getSetCookie === 'function' ? res.headers.getSetCookie() : [];
    SESSION = cookies.map((c) => c.split(';')[0]).join('; ');
  }
  return res.ok;
}
const H = () => (SESSION ? { cookie: SESSION } : {});

async function routeCount() {
  const res = await fetch(API + '/api/routes?limit=1000', { headers: H() });
  const json = await res.json();
  return (json.data || json).length;
}

async function main() {
  const loggedIn = await login();
  if (!loggedIn) console.log("  note: login failed, continuing anonymously (expected on unpatched code)");

  console.log(`import/export tests against ${API}\n`);

  // ---------- Export ----------
  let res = await fetch(API + '/api/export?entity=not_an_entity&format=csv', { headers: H() });
  check('unknown export entity -> 400', res.status === 400, `got ${res.status}`);

  res = await fetch(API + '/api/export?entity=ports&format=csv', { headers: H() });
  const buf = Buffer.from(await res.arrayBuffer()); // NOTE: res.text() strips the BOM, so check raw bytes
  check('ports CSV starts with UTF-8 BOM (EF BB BF)', buf[0] === 0xef && buf[1] === 0xbb && buf[2] === 0xbf,
    `first bytes ${buf.subarray(0, 3).toString('hex')}`);
  const csv = buf.subarray(3).toString('utf8');
  const cd = res.headers.get('content-disposition') || '';
  check('filename contains date AND time', /portwatch-ports-\d{4}-\d{2}-\d{2}-\d{4}\.csv/.test(cd), cd);

  // archived rows are excluded unless explicitly requested
  const portsRes = await fetch(API + '/api/ports?limit=1000', { headers: H() });
  const portsJson = await portsRes.json();
  const activeTotal = portsJson.pagination?.total ?? portsJson.data?.length;
  const csvLines = csv.split('\n').filter((l) => l.trim()).length;
  check(`CSV row count matches visible (non-archived) rows (${activeTotal})`,
    csvLines >= activeTotal && csvLines <= activeTotal + 1,
    `csv lines=${csvLines}, active=${activeTotal}`);

  // formula injection: crafted cells must be neutralised. We cannot inject
  // through the API, so verify the helper behaviour on the issues export by
  // checking that no exported cell begins with a bare formula character in
  // column position (defence is server-side prefixing with an apostrophe).
  res = await fetch(API + '/api/export?entity=issues&format=csv', { headers: H() });
  const issuesCsv = await res.text();
  const badCells = issuesCsv
    .split('\n')
    .flatMap((line) => line.split(','))
    .filter((c) => /^[=+@]/.test(c.replace(/^"/, '')));
  check('no unescaped formula cells in issues CSV', badCells.length === 0,
    `${badCells.length} suspicious cells`);

  // routes export must contain flattened relation columns
  res = await fetch(API + '/api/export?entity=routes&format=csv', { headers: H() });
  const routesCsv = await res.text();
  check('routes CSV contains flattened relation headers',
    /port\./.test(routesCsv) || /backend\./.test(routesCsv),
    'no dotted relation columns found');

  // ---------- Import (disposable DB only!) ----------
  if (process.env.IMPORT_TEST === '1') {
    const before = await routeCount();
    const form = new FormData();
    form.append('file', new Blob(['this is not a spreadsheet']), 'wrong.txt');
    const imp = await fetch(API + '/api/import', { method: 'POST', body: form });
    const after = await routeCount();
    check('garbage upload -> 400 (not a fake success)', imp.status === 400, `got ${imp.status}`);
    check(`route table untouched (${before} rows before/after)`, before === after,
      `before=${before} after=${after}`);

    const empty = new FormData();
    empty.append('file', new Blob([Buffer.from('PK\u0003\u0004empty')]), 'empty.xlsx');
    const imp2 = await fetch(API + '/api/import', { method: 'POST', body: empty });
    const after2 = await routeCount();
    check('unparseable workbook -> 400', imp2.status === 400, `got ${imp2.status}`);
    check('route table still untouched', before === after2,
      `before=${before} after=${after2}`);
  } else {
    console.log('  SKIP  import destruction tests (set IMPORT_TEST=1 on a scratch DB)');
  }

  console.log(failures === 0 ? '\nALL PASS' : `\n${failures} FAILURE(S)`);
  process.exit(failures === 0 ? 0 : 1);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
