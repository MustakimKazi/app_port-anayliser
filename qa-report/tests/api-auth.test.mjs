/**
 * Regression tests for BUG-001 / BUG-003 / BUG-004 / BUG-008 / BUG-010 / BUG-013 / BUG-019.
 *
 * Run:  node qa-report/tests/api-auth.test.mjs [API_URL]
 * Exit code 0 = all assertions pass (i.e. patches applied), 1 = failures.
 *
 * BEFORE the patches these tests FAIL:
 *  - unauthenticated requests are promoted to admin (x-role / default admin)
 *  - viewer can POST /api/scan, PATCH /api/settings, POST /api/issues
 *  - bad logins all return 401 (no rate limit)
 *  - CORS reflects any Origin with credentials; no security headers
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

async function req(method, path, { body, headers, raw } = {}) {
  try {
    const res = await fetch(API + path, {
      method,
      headers: {
        ...(body ? { 'content-type': 'application/json' } : {}),
        ...(headers || {})
      },
      body: body ? JSON.stringify(body) : undefined
    });
    return { status: res.status, body: await res.text() };
  } catch (e) {
    return { status: 0, body: String(e) };
  }
}

async function main() {
  console.log(`api-auth tests against ${API}\n`);

  // 1. Unauthenticated read must be rejected
  let r = await req('GET', '/api/ports');
  check('unauthenticated GET /api/ports -> 401', r.status === 401, `got ${r.status}`);

  // 2. The x-role / x-user header backdoor must not work
  r = await req('GET', '/api/ports', { headers: { 'x-role': 'admin', 'x-user': 'attacker' } });
  check('x-role header is ignored -> 401', r.status === 401, `got ${r.status}`);

  // 3. Forged cookie is rejected
  r = await req('GET', '/api/ports', { headers: { cookie: 'access_token=not-a-jwt' } });
  check('forged cookie -> 401', r.status === 401, `got ${r.status}`);

  // 4. Settings (secrets) unreachable without auth
  r = await req('GET', '/api/settings');
  check('unauthenticated GET /api/settings -> 401', r.status === 401, `got ${r.status}`);

  // 5. Login endpoint still exists (public)
  r = await req('POST', '/api/auth/login', { body: { username: '', password: '' } });
  check('POST /api/auth/login reachable -> 400/401', r.status === 400 || r.status === 401, `got ${r.status}`);

  // 6. Brute-force protection: after 10 bad attempts expect 429
  let saw429 = false;
  for (let i = 0; i < 12; i++) {
    const res = await fetch(API + '/api/auth/login', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ username: 'qa_rate_limit_probe', password: 'wrong' })
    });
    if (res.status === 429) {
      saw429 = true;
      break;
    }
  }
  check('login rate limit returns 429 within 12 attempts', saw429);

  // 7. Viewer role cannot mutate (needs a valid viewer session if present)
  const viewerCookie = process.env.VIEWER_COOKIE;
  if (viewerCookie) {
    r = await req('POST', '/api/scan', { headers: { cookie: viewerCookie } });
    check('viewer POST /api/scan -> 403', r.status === 403, `got ${r.status}`);
    r = await req('PATCH', '/api/settings', {
      body: { scanIntervalSec: 31 },
      headers: { cookie: viewerCookie }
    });
    check('viewer PATCH /api/settings -> 403', r.status === 403, `got ${r.status}`);
    r = await req('GET', '/api/ports', { headers: { cookie: viewerCookie } });
    check('viewer GET /api/ports -> 200', r.status === 200, `got ${r.status}`);
  } else {
    console.log('  SKIP  viewer role checks (set VIEWER_COOKIE to enable)');
  }

  // 8. No stack traces / file paths in error bodies (authenticated — mutations need a session)
  let adminCookie = '';
  try {
    const login = await fetch(API + '/api/auth/login', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        username: process.env.ADMIN_USER || 'admin',
        password: process.env.ADMIN_PASS || 'admin'
      })
    });
    if (login.ok) {
      const cookies =
        typeof login.headers.getSetCookie === 'function' ? login.headers.getSetCookie() : [];
      adminCookie = cookies.map((c) => c.split(';')[0]).join('; ');
    }
  } catch { /* unpatched code may not even need this */ }
  r = await req('POST', '/api/issues', {
    body: { wrong: true },
    headers: adminCookie ? { cookie: adminCookie } : {}
  });
  const leaky = /at .*\.ts:\d+|node_modules|PrismaClient/.test(r.body);
  check('invalid issue body -> 400 without stack trace', r.status === 400 && !leaky,
    `got ${r.status}, leak=${leaky}`);

  // 9. CORS must not reflect arbitrary origins with credentials (BUG-010)
  try {
    const pre = await fetch(API + '/api/ports', {
      method: 'OPTIONS',
      headers: {
        Origin: 'https://evil.example',
        'Access-Control-Request-Method': 'POST',
        'Access-Control-Request-Headers': 'content-type'
      }
    });
    const acao = pre.headers.get('access-control-allow-origin');
    check('CORS does not reflect arbitrary Origin', acao === null || acao === 'null' ||
      (!acao.includes('evil.example') && acao !== '*'), `acao=${acao}`);
  } catch (e) {
    check('CORS preflight reachable', false, String(e));
  }

  // 10. Security headers present (BUG-019)
  try {
    const h = await fetch(API + '/api/health');
    const nosniff = (h.headers.get('x-content-type-options') || '').toLowerCase();
    check('security headers: x-content-type-options=nosniff', nosniff === 'nosniff',
      `got "${nosniff || '(missing)'}"`);
  } catch (e) {
    check('security header request reachable', false, String(e));
  }

  console.log(failures === 0 ? '\nALL PASS' : `\n${failures} FAILURE(S)`);
  process.exit(failures === 0 ? 0 : 1);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
