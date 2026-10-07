/**
 * Regression tests for BUG-021 (limit=Infinity / page=0 -> 500, unbounded limit) and
 * BUG-013 (raw validation internals returned to the client).
 *
 * Run:  node qa-report/tests/api-validation.test.mjs [API_URL]
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
    headers: { 'content-type': 'application/json', ...H() },
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

async function get(path) {
  const res = await fetch(API + path, { headers: H() });
  const text = await res.text();
  let json = null;
  try {
    json = JSON.parse(text);
  } catch {}
  return { status: res.status, text, json };
}

async function main() {
  const loggedIn = await login();
  if (!loggedIn) console.log("  note: login failed, continuing anonymously (expected on unpatched code)");

  console.log(`validation tests against ${API}\n`);

  let r = await get('/api/ports?limit=Infinity');
  check('?limit=Infinity -> 400 (was 500)', r.status === 400, `got ${r.status}`);

  r = await get('/api/ports?page=0');
  check('?page=0 -> 400 (was 500)', r.status === 400, `got ${r.status}`);

  r = await get('/api/ports?page=-3');
  check('?page=-3 -> 400', r.status === 400, `got ${r.status}`);

  r = await get('/api/ports?limit=999999');
  check('?limit=999999 -> 400 (bounded)', r.status === 400, `got ${r.status}`);

  // Bad query must not serialize the whole ZodError (issues/parameters tree)
  r = await get('/api/routes?page=abc');
  const zodLeak = r.text.includes('"issues"') && r.text.includes('"code"') && r.text.includes('received:');
  check('invalid query -> 400 without raw ZodError dump', r.status === 400 && !zodLeak,
    `got ${r.status}, zodLeak=${zodLeak}`);

  // Prisma/DB errors must come back as a generic 500 (no stack / file paths)
  const res = await fetch(API + '/api/issues', {
    method: 'POST',
    headers: { 'content-type': 'application/json', ...H() },
    body: JSON.stringify({ title: 12345 })
  });
  const body = await res.text();
  const leak = /PrismaClient|\.ts:\d+|node_modules/.test(body);
  check('bad issue payload -> 400 without internals', res.status === 400 && !leak,
    `got ${res.status}, leak=${leak}`);

  console.log(failures === 0 ? '\nALL PASS' : `\n${failures} FAILURE(S)`);
  process.exit(failures === 0 ? 0 : 1);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
