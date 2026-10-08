/* Deep interactive UI test pass. Run: node qa-report/scripts/ui-interactive.mjs */
import { chromium } from 'playwright';
import fs from 'fs';

const BASE = process.env.PORTWATCH_WEB || 'http://localhost:5174';
const OUT = 'qa-report/evidence/ui-sweep/interactive-findings.json';
const findings = [];
const log = (sev, area, detail) => { findings.push({ sev, area, detail }); console.log(`[${sev}] ${area}: ${detail}`); };
const step = (s) => console.log(`--- ${s}`);

async function shot(page, name) {
  await page.screenshot({ path: `qa-report/evidence/ui-sweep/${name}.png`, fullPage: false }).catch(() => {});
}
async function login(page, user = 'admin', pass = 'admin') {
  await page.goto(BASE + '/login', { waitUntil: 'networkidle' });
  if (await page.locator('input[type="password"]').count()) {
    await page.fill('input[type="text"]', user);
    await page.fill('input[type="password"]', pass);
    await page.click('button[type="submit"]');
    await page.waitForURL((u) => !u.pathname.includes('/login'), { timeout: 10000 }).catch(() => {});
    await page.waitForTimeout(800);
  }
}

const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
const page = await ctx.newPage();
const pageErrors = [];
page.on('pageerror', (e) => pageErrors.push(String(e)));
page.on('dialog', async (d) => { log('MED', 'dialog', `native ${d.type()} dialog: ${d.message().slice(0, 120)}`); await d.dismiss(); });

await login(page);

/* ---------- PORTS PAGE ---------- */
step('ports: filters + pagination + history');
await page.goto(BASE + '/ports', { waitUntil: 'networkidle' });
await page.waitForTimeout(1000);

// search filter
const search = page.locator('input[aria-label="Search ports"], input[placeholder*="earch"]').first();
if (await search.count()) {
  await search.fill('nginx');
  await page.waitForTimeout(900);
  const rows1 = await page.locator('tbody tr').count();
  await search.fill('');
  await page.waitForTimeout(900);
  const rows2 = await page.locator('tbody tr').count();
  log('INFO', 'ports/search', `rows with q=nginx: ${rows1}, cleared: ${rows2}`);
  if (rows1 >= rows2 && rows2 > 0) log('MED', 'ports/search', 'search did not reduce row count');
  // history depth: filter changes must not push entries (BUG-029 fix)
  const depthBefore = await page.evaluate(() => history.length);
  await search.fill('x');
  await page.waitForTimeout(700);
  const depthAfter = await page.evaluate(() => history.length);
  if (depthAfter > depthBefore) log('MED', 'ports/history', `filter pushed browser history (+${depthAfter - depthBefore}) — Back will need multiple presses`);
  else log('INFO', 'ports/history', 'filter uses replaceState — history depth unchanged');
  await search.fill('');
  await page.waitForTimeout(600);
} else log('HIGH', 'ports/search', 'search input not found');

// pagination controls
const pagText = await page.locator('text=/Page \\d+ of \\d+/').count();
if (pagText) {
  const nextBtn = page.locator('button[aria-label*="next" i], button:has-text("Next")').first();
  if (await nextBtn.count() && await nextBtn.isEnabled()) {
    const before = await page.evaluate(() => history.length);
    await nextBtn.click(); await page.waitForTimeout(900);
    const pageLabel = await page.locator('text=/Page \\d+ of \\d+/').first().innerText().catch(() => '');
    log('INFO', 'ports/pagination', `next works: ${pageLabel.replace(/\n/g, ' ')}`);
    if (pageLabel && !/Page 2 of/.test(pageLabel)) log('MED', 'ports/pagination', `expected Page 2, got "${pageLabel.replace(/\n/g, ' ')}"`);
  } else log('MED', 'ports/pagination', 'pagination label present but Next button missing/disabled');
} else log('MED', 'ports/pagination', 'no "Page X of Y" label — pagination UI absent');

// row drawer
const firstRow = page.locator('tbody tr').first();
if (await firstRow.count()) {
  await firstRow.click();
  await page.waitForTimeout(900);
  const drawerVisible = await page.locator('[role="dialog"], aside, [class*="drawer" i]').first().isVisible().catch(() => false);
  if (!drawerVisible) log('MED', 'ports/drawer', 'clicking a row did not open any drawer/dialog');
  else {
    step('ports: uptime strip cells');
    const cells = await page.evaluate(() => {
      const els = [...document.querySelectorAll('*')].filter((e) => /24|uptime|hour/i.test(e.className?.toString?.() || '') && e.children.length >= 12);
      return els.map((e) => ({ cls: e.className.toString().slice(0, 80), kids: e.children.length, tag: e.tagName }));
    });
    log('INFO', 'ports/uptime', `candidate uptime strips: ${JSON.stringify(cells).slice(0, 300)}`);
    // ESC closes drawer
    await page.keyboard.press('Escape');
    await page.waitForTimeout(500);
    const stillOpen = await page.locator('[role="dialog"], aside').first().isVisible().catch(() => false);
    if (stillOpen) log('LOW', 'ports/drawer', 'Escape does not close the port drawer');
    else log('INFO', 'ports/drawer', 'Escape closes drawer');
  }
} else log('MED', 'ports/rows', 'no table rows rendered');

step('ports: Add Port modal validation');
const addBtn = page.locator('button:has-text("Add Port"), button[aria-label*="Add Port" i]').first();
if (await addBtn.count()) {
  await addBtn.click(); await page.waitForTimeout(700);
  const modal = page.locator('[role="dialog"]').first();
  if (await modal.isVisible().catch(() => false)) {
    // submit empty/invalid
    const portInput = modal.locator('input[type="number"], input[name*="port" i]').first();
    if (await portInput.count()) {
      await portInput.fill('99999'); // invalid port > 65535
      const submit = modal.locator('button[type="submit"], button:has-text("Add"), button:has-text("Create")').last();
      await submit.click().catch(() => {});
      await page.waitForTimeout(700);
      const err = await modal.locator('[class*="red"], [class*="danger"], [role="alert"], text=/invalid|between|65535|required/i').count();
      if (err === 0) log('MED', 'ports/add-modal', 'invalid port 99999 submitted with no visible validation error');
      else log('INFO', 'ports/add-modal', 'validation error shown for invalid port');
      await shot(page, 'ports-add-validation');
    }
    // close modal
    await page.keyboard.press('Escape'); await page.waitForTimeout(400);
    if (await modal.isVisible().catch(() => false)) {
      const closeBtn = modal.locator('button[aria-label*="close" i], button:has-text("Cancel")').first();
      if (await closeBtn.count()) await closeBtn.click().catch(() => {});
      await page.waitForTimeout(400);
      if (await modal.isVisible().catch(() => false)) log('MED', 'ports/add-modal', 'modal cannot be dismissed (ESC + cancel failed)');
    }
  } else log('MED', 'ports/add-modal', 'Add Port button present but no [role=dialog] opened');
} else log('MED', 'ports/add-modal', 'Add Port button not found');

step('ports: export menu discoverability');
const exportBtn = page.locator('button:has-text("Export"), [aria-label*="export" i]').first();
if (await exportBtn.count()) {
  const vis = await exportBtn.isVisible();
  log('INFO', 'ports/export', `export control present, visible=${vis}`);
} else log('LOW', 'ports/export', 'no export control on Ports page');

/* ---------- ISSUES ---------- */
step('issues: filters + acknowledge');
await page.goto(BASE + '/issues', { waitUntil: 'networkidle' });
await page.waitForTimeout(1200);
const issueRows = await page.locator('tbody tr').count();
log('INFO', 'issues', `${issueRows} rows`);
const ackBtn = page.locator('button:has-text("Acknowledge"), button:has-text("Ack"), button[aria-label*="ack" i]').first();
if (await ackBtn.count()) {
  await ackBtn.click(); await page.waitForTimeout(1200);
  const toast = await page.locator('[role="alert"], [class*="toast" i]').count();
  log('INFO', 'issues/ack', `ack clicked; visible toasts/alerts after: ${toast}`);
  await shot(page, 'issues-after-ack');
} else log('INFO', 'issues/ack', 'no acknowledge button found (may need row expansion)');

/* ---------- SETTINGS ---------- */
step('settings: tabs + save feedback');
await page.goto(BASE + '/settings', { waitUntil: 'networkidle' });
await page.waitForTimeout(900);
for (const tab of ['Alerts', 'Features', 'Custom Fields', 'Import / Export', 'Audit']) {
  const t = page.locator(`button:has-text("${tab}")`).first();
  if (await t.count()) {
    await t.click(); await page.waitForTimeout(700);
    const bodyText = await page.evaluate(() => document.querySelector('main')?.innerText || '');
    if (bodyText.trim().length < 40) log('MED', `settings/${tab}`, 'tab body nearly empty');
    if (/something went wrong|error loading|failed to fetch/i.test(bodyText)) log('MED', `settings/${tab}`, 'tab shows an error state');
    await shot(page, `settings-${tab.replace(/[^a-z]/gi, '').toLowerCase()}`);
  } else log('INFO', `settings/${tab}`, 'tab button not found');
}
// scanner save
const scannerSave = page.locator('button:has-text("Save")').first();
if (await scannerSave.count()) {
  const before = await page.locator('[role="alert"], [class*="toast" i]').count();
  await scannerSave.click(); await page.waitForTimeout(1200);
  const after = await page.locator('[role="alert"], [class*="toast" i]').count();
  const bodyText = await page.evaluate(() => document.querySelector('main')?.innerText || '');
  log('INFO', 'settings/save', `save clicked; alerts before=${before} after=${after}; inline "saved" text=${/saved/i.test(bodyText)}`);
  if (after === before && !/saved/i.test(bodyText)) log('MED', 'settings/save', 'Save shows no success feedback anywhere');
}

/* ---------- COMMAND PALETTE + SHORTCUTS ---------- */
step('command palette');
await page.goto(BASE + '/', { waitUntil: 'networkidle' });
await page.waitForTimeout(600);
await page.keyboard.press('Control+k');
await page.waitForTimeout(600);
let paletteOpen = await page.locator('input[placeholder*="command" i]').isVisible().catch(() => false);
if (!paletteOpen) { await page.keyboard.press('Meta+k'); await page.waitForTimeout(500); paletteOpen = await page.locator('input[placeholder*="command" i]').isVisible().catch(() => false); }
if (paletteOpen) {
  log('INFO', 'palette', 'opens with Ctrl+K');
  await page.keyboard.type('certificates'); await page.waitForTimeout(600);
  const opts = await page.locator('[role="option"], [class*="palette"] li, [class*="command-item"]').count();
  log('INFO', 'palette', `search results rows: ${opts}`);
  await page.keyboard.press('Enter'); await page.waitForTimeout(900);
  const landed = new URL(page.url()).pathname;
  if (landed !== '/certificates') log('MED', 'palette', `Enter on "certificates" landed on ${landed}`);
  else log('INFO', 'palette', 'Enter navigates to selection');
} else log('HIGH', 'palette', 'Ctrl+K did not open the command palette');

// dead G , shortcut (BUG-045 status check)
await page.goto(BASE + '/', { waitUntil: 'networkidle' });
await page.waitForTimeout(500);
const urlBefore = page.url();
await page.keyboard.press('g'); await page.keyboard.press(','); await page.waitForTimeout(600);
if (page.url() === urlBefore) log('INFO', 'shortcuts', 'G , still does nothing (BUG-045 open — expected, unpatched)');
else log('INFO', 'shortcuts', `G , navigated to ${new URL(page.url()).pathname} (BUG-045 fixed)`);

// G P navigation
await page.keyboard.press('g'); await page.keyboard.press('p'); await page.waitForTimeout(700);
const gp = new URL(page.url()).pathname;
if (gp !== '/ports') log('MED', 'shortcuts', `G P did not navigate to /ports (landed ${gp})`);
else log('INFO', 'shortcuts', 'G P works');

/* ---------- THEME ---------- */
step('theme toggle');
await page.goto(BASE + '/', { waitUntil: 'networkidle' });
const themeBtn = page.locator('button[aria-label*="heme" i]').first();
if (await themeBtn.count()) {
  const seen = new Set();
  for (let i = 0; i < 3; i++) {
    await themeBtn.click(); await page.waitForTimeout(400);
    const htmlCls = await page.evaluate(() => document.documentElement.className);
    const stored = await page.evaluate(() => localStorage.getItem('theme'));
    seen.add(`${htmlCls}|${stored}`);
  }
  log('INFO', 'theme', `cycle states: ${[...seen].join('  ')}`);
  // persistence across reload
  await page.reload({ waitUntil: 'networkidle' }); await page.waitForTimeout(600);
  const after = await page.evaluate(() => document.documentElement.className + '|' + localStorage.getItem('theme'));
  log('INFO', 'theme', `after reload: ${after}`);
} else log('MED', 'theme', 'theme toggle button not found');

/* ---------- simulated API failure: toast + error boundary (BUG-022/023 fixes) ---------- */
step('simulated API 500 on dashboard');
await page.route('**/api/overview*', (r) => r.fulfill({ status: 500, contentType: 'application/json', body: '{"error":"boom"}' }));
await page.route('**/api/issues/stats*', (r) => r.fulfill({ status: 500, contentType: 'application/json', body: '{"error":"boom"}' }));
await page.goto(BASE + '/', { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(2500);
const toastCount = await page.locator('[role="alert"]').count();
const bodyText = await page.evaluate(() => document.body.innerText);
const stillSkeleton = await page.locator('[class*="animate-pulse"]').count();
log('INFO', 'api-fail', `toasts=${toastCount}, pulse-skeletons=${stillSkeleton}, page mentions error=${/error|failed|something/i.test(bodyText)}`);
if (stillSkeleton > 3) log('HIGH', 'api-fail', `dashboard still shows ${stillSkeleton} skeleton blocks after API 500 (BUG-023 regression)`);
if (toastCount === 0) log('MED', 'api-fail', 'no error toast after API 500 (query errors may be silently swallowed)');
await shot(page, 'dashboard-api-500');
await page.unroute('**/api/overview*');
await page.unroute('**/api/issues/stats*');

/* ---------- LOGOUT ---------- */
step('logout');
await page.goto(BASE + '/', { waitUntil: 'networkidle' });
const signout = page.locator('button[aria-label*="ign out" i], button:has-text("Sign out")').first();
if (await signout.count()) {
  await signout.click(); await page.waitForTimeout(1500);
  const path = new URL(page.url()).pathname;
  if (path !== '/login') log('MED', 'logout', `Sign out landed on ${path}, expected /login`);
  else log('INFO', 'logout', 'sign out redirects to /login');
  // cookie cleared?
  const cookies = await ctx.cookies();
  const hasCookie = cookies.some((c) => c.name === 'access_token');
  if (hasCookie) log('MED', 'logout', 'access_token cookie still present after logout');
  else log('INFO', 'logout', 'access_token cookie cleared');
} else log('MED', 'logout', 'Sign out control not found');

/* ---------- VIEWER ROLE GATING (BUG-053 status) ---------- */
step('viewer role');
const ctx2 = await browser.newContext({ viewport: { width: 1440, height: 900 } });
const vp = await ctx2.newPage();
await login(vp, 'viewer', 'viewer123');
const vPath = new URL(vp.url()).pathname;
if (vPath === '/login') log('HIGH', 'viewer', 'viewer login failed (credentials viewer/viewer123 rejected)');
else {
  await vp.goto(BASE + '/', { waitUntil: 'networkidle' }); await vp.waitForTimeout(800);
  const scanNow = await vp.locator('button:has-text("Scan Now")').count();
  const roleTxt = await vp.evaluate(() => document.body.innerText.match(/\b(viewer|admin)\b/i)?.[0] || 'none');
  log('INFO', 'viewer', `role badge=${roleTxt}; "Scan Now" visible=${scanNow > 0}`);
  if (scanNow > 0) log('MED', 'viewer', 'viewer sees "Scan Now" mutation button (BUG-053 still open)');
  // viewer attempting a mutation via API
  const apiMut = await vp.evaluate(async () => {
    const r = await fetch('/api/ports', { method: 'POST', headers: { 'Content-Type': 'application/json' }, credentials: 'include', body: JSON.stringify({ port: 59999, host: 'x', layer: 'test', protocol: 'TCP' }) });
    return r.status;
  });
  log('INFO', 'viewer', `POST /api/ports as viewer -> ${apiMut} (403 = API guard OK)`);
  if (apiMut !== 403) log('HIGH', 'viewer', `viewer POST /api/ports returned ${apiMut}, expected 403`);
  await shot(vp, 'viewer-dashboard');
}
await ctx2.close();

/* ---------- BROWSER BACK AFTER NAVIGATION ---------- */
step('browser back');
await page.goto(BASE + '/ports', { waitUntil: 'networkidle' });
await page.waitForTimeout(600);
const s2 = page.locator('input[aria-label="Search ports"], input[placeholder*="earch"]').first();
if (await s2.count()) { await s2.fill('zzq'); await page.waitForTimeout(800); await s2.fill(''); await page.waitForTimeout(600); }
await page.goBack(); await page.waitForTimeout(800);
log('INFO', 'back', `after one Back: ${new URL(page.url()).pathname}`);

if (pageErrors.length) for (const e of pageErrors) log('HIGH', 'pageerror', e.slice(0, 300));
else log('INFO', 'pageerror', 'none across all interactive steps');

fs.writeFileSync(OUT, JSON.stringify(findings, null, 2));
console.log('\nTOTAL findings:', findings.length, findings.reduce((a, f) => ((a[f.sev] = (a[f.sev] || 0) + 1), a), {}));
await browser.close();
