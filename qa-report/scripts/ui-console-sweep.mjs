/**
 * UI sweep: console errors across all routes x themes, plus viewer-role controls.
 * Checklist item 4. Writes qa-report/evidence/ui-console-errors.txt (run via tee).
 * Requires: web :5173 (login page present pre-WEB-002) and API :3100.
 * Run: node /tmp/opencode/ui-console-sweep.mjs
 */
import { chromium } from '@playwright/test';

const WEB = process.env.WEB_URL || 'http://localhost:5173';
const API = process.env.API_URL || 'http://localhost:3100';
const ROUTES = ['/', '/ports', '/routes', '/backends', '/issues',
                '/config-files', '/certificates', '/port-map', '/history', '/settings'];

async function login(context, user, pass) {
  // Baseline build has no /login page (BUG-005) — obtain the access_token cookie
  // directly from the API and let context.request store it in the cookie jar.
  const res = await context.request.post(API + '/api/auth/login', {
    data: { username: user, password: pass },
  });
  if (!res.ok()) throw new Error(`login ${user} -> HTTP ${res.status()}`);
  const body = await res.json();
  console.log(`login ${user} -> ${body.username || '?'} role=${body.role}`);
}

async function setTheme(page, theme) {
  await page.evaluate((t) => {
    localStorage.setItem('theme', t);
    document.documentElement.classList.toggle('dark', t === 'dark');
  }, theme);
  await page.waitForTimeout(300);
}

function attach(page, sink) {
  page.on('console', (m) => {
    if (m.type() === 'error' || m.type() === 'warning') {
      sink.push(`[${m.type()}] ${m.text().slice(0, 300)}`);
    }
  });
  page.on('pageerror', (e) => sink.push(`[pageerror] ${String(e).slice(0, 300)}`));
}

const browser = await chromium.launch();
const issues = [];
let total = 0;

// ---- Admin: all routes x both themes @1366 ----
{
  const ctx = await browser.newContext({ viewport: { width: 1366, height: 900 } });
  const page = await ctx.newPage();
  const sink = []; attach(page, sink);
  await login(ctx, process.env.ADMIN_USER || 'admin', process.env.ADMIN_PASS || 'admin');
  for (const theme of ['dark', 'light']) {
    for (const route of ROUTES) {
      sink.length = 0;
      await page.goto(WEB + route, { waitUntil: 'networkidle' });
      await setTheme(page, theme);
      await page.reload({ waitUntil: 'networkidle' });
      await setTheme(page, theme);
      await page.waitForTimeout(700);
      total++;
      if (sink.length) issues.push(`[admin ${theme} ${route}]\n  ` + sink.join('\n  '));
    }
  }
  // spot-check 390px
  await page.setViewportSize({ width: 390, height: 844 });
  for (const route of ['/', '/ports', '/settings']) {
    for (const theme of ['dark', 'light']) {
      sink.length = 0;
      await page.goto(WEB + route, { waitUntil: 'networkidle' });
      await setTheme(page, theme);
      await page.waitForTimeout(700);
      total++;
      if (sink.length) issues.push(`[admin ${theme} ${route} @390]\n  ` + sink.join('\n  '));
    }
  }
  await ctx.close();
}

// ---- Viewer: gating + console ----
{
  const ctx = await browser.newContext({ viewport: { width: 1366, height: 900 } });
  const page = await ctx.newPage();
  const sink = []; attach(page, sink);
  await login(ctx, 'viewer', 'viewer123');
  const role = await page.evaluate(async () => {
    const r = await fetch('/api/auth/me', { credentials: 'include' });
    return r.ok ? (await r.json()).role : `http ${r.status}`;
  }).catch((e) => `eval fail ${e}`);
  console.log(`viewer /auth/me -> ${role}`);

  for (const route of ['/ports', '/settings', '/issues']) {
    sink.length = 0;
    await page.goto(WEB + route, { waitUntil: 'networkidle' });
    await setTheme(page, 'dark');
    await page.waitForTimeout(800);
    total++;
    if (sink.length) issues.push(`[viewer dark ${route}]\n  ` + sink.join('\n  '));
  }

  // viewer control gating on /ports
  await page.goto(WEB + '/ports', { waitUntil: 'networkidle' });
  await page.waitForTimeout(800);
  const gates = await page.evaluate(() => {
    const btnTexts = [...document.querySelectorAll('button')]
      .map((b) => (b.textContent || '').trim())
      .filter((t) => /add port|scan now|delete|export|import|bulk/i.test(t));
    return btnTexts;
  });
  console.log(`viewer /ports admin-ish buttons visible: ${JSON.stringify(gates)}`);

  await page.goto(WEB + '/settings', { waitUntil: 'networkidle' });
  await page.waitForTimeout(800);
  const saveVisible = await page.evaluate(() =>
    [...document.querySelectorAll('button')]
      .map((b) => (b.textContent || '').trim())
      .filter((t) => /save|send test|add rule/i.test(t)));
  console.log(`viewer /settings action buttons: ${JSON.stringify(saveVisible)}`);
  await ctx.close();
}

await browser.close();

console.log(`\n${total} route x theme x viewport visits; ${issues.length} with console errors`);
if (issues.length) console.log('\n' + issues.join('\n'));
