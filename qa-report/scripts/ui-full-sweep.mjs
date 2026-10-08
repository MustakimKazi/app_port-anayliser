/* Full-site UI sweep: routes × viewports — console errors, page errors,
 * failed requests, horizontal overflow, stuck loaders, screenshots.
 * Run: node qa-report/scripts/ui-full-sweep.mjs
 */
import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

const BASE = process.env.PORTWATCH_WEB || 'http://localhost:5174';
const OUT = 'qa-report/evidence/ui-sweep';
fs.mkdirSync(OUT, { recursive: true });

const ROUTES = [
  ['/', 'dashboard'],
  ['/ports', 'ports'],
  ['/routes', 'routes'],
  ['/backends', 'backends'],
  ['/issues', 'issues'],
  ['/config-files', 'config-files'],
  ['/certificates', 'certificates'],
  ['/port-map', 'port-map'],
  ['/history', 'history'],
  ['/settings', 'settings'],
  ['/login', 'login'],
  ['/does-not-exist', 'wildcard'],
];
const VIEWPORTS = [
  ['desktop', 1440, 900],
  ['tablet', 768, 1024],
  ['mobile', 390, 844],
];

const findings = [];
const add = (sev, where, detail) => {
  findings.push({ sev, where, detail });
  console.log(`[${sev}] ${where}: ${detail}`);
};

const browser = await chromium.launch();

async function login(page) {
  await page.goto(BASE + '/login', { waitUntil: 'domcontentloaded' });
  const onLogin = await page.locator('input[type="password"]').count();
  if (onLogin) {
    await page.fill('input[name="username"], input#username, input[type="text"]', 'admin');
    await page.fill('input[type="password"]', 'admin');
    await page.click('button[type="submit"]');
    await page.waitForURL((u) => !u.pathname.includes('/login'), { timeout: 10000 }).catch(() => {});
  }
}

for (const [vpName, w, h] of VIEWPORTS) {
  const ctx = await browser.newContext({ viewport: { width: w, height: h } });
  const page = await ctx.newPage();
  const consoleMsgs = [];
  const pageErrors = [];
  const failedReq = [];
  page.on('console', (m) => {
    if (m.type() === 'error' || m.type() === 'warning') consoleMsgs.push(`[${m.type()}] ${m.text()}`);
  });
  page.on('pageerror', (e) => pageErrors.push(String(e)));
  page.on('response', (r) => {
    if (r.status() >= 400 && r.url().includes('/api/')) failedReq.push(`${r.status()} ${r.request().method()} ${r.url().replace(BASE, '')}`);
  });

  await login(page);

  for (const [route, name] of ROUTES) {
    consoleMsgs.length = 0; pageErrors.length = 0; failedReq.length = 0;
    try {
      await page.goto(BASE + route, { waitUntil: 'networkidle', timeout: 20000 });
    } catch {
      add('HIGH', `${name}@${vpName}`, 'navigation timeout / never reached networkidle');
    }
    await page.waitForTimeout(1200);

    // redirect detection (wildcard should land on /)
    const landed = new URL(page.url()).pathname;
    if (name === 'wildcard' && landed !== '/') add('INFO', 'wildcard', `unknown route redirected to ${landed} (expected /)`);
    if (name !== 'login' && name !== 'wildcard' && landed === '/login') add('HIGH', `${name}@${vpName}`, 'bounced to /login (session lost)');

    // horizontal overflow
    const ov = await page.evaluate(() => {
      const d = document.documentElement;
      const over = d.scrollWidth - d.clientWidth;
      let worst = null;
      if (over > 2) {
        for (const el of document.querySelectorAll('body *')) {
          const r = el.getBoundingClientRect();
          if (r.right > d.clientWidth + 2 && r.width > 8) {
            const sel = el.tagName.toLowerCase() + (el.className && typeof el.className === 'string' ? '.' + el.className.split(/\s+/).slice(0, 3).join('.') : '');
            if (!worst || r.right > worst.right) worst = { right: Math.round(r.right), sel: sel.slice(0, 120) };
          }
        }
      }
      return { over, clientWidth: d.clientWidth, worst };
    });
    if (ov.over > 2) add('MED', `${name}@${vpName}`, `horizontal overflow ${ov.over}px (client ${ov.clientWidth}); widest: ${ov.worst ? ov.worst.sel + ' right=' + ov.worst.right : 'n/a'}`);

    // stuck loader: any spinner still rotating after settle
    const spinners = await page.evaluate(() =>
      [...document.querySelectorAll('[class*="animate-spin"], [class*="loading"], [role="progressbar"]')].filter((e) => {
        const r = e.getBoundingClientRect();
        return r.width > 0 && r.height > 0;
      }).length
    );
    if (spinners > 0 && name !== 'login') add('MED', `${name}@${vpName}`, `${spinners} visible spinner(s) still shown after settle`);

    // empty main content
    const mainEmpty = await page.evaluate(() => {
      const main = document.querySelector('main') || document.querySelector('#root > div');
      return main ? main.innerText.trim().length : -1;
    });
    if (mainEmpty === 0) add('HIGH', `${name}@${vpName}`, 'main content area is EMPTY');

    // console errors / page errors / failed API calls
    const interesting = consoleMsgs.filter(
      (t) => !t.includes('Download the React DevTools') && !t.includes('future flag') && !t.includes('v7_startTransition') && !t.includes('v7_relativeSplatPath')
    );
    for (const t of interesting) add(t.startsWith('[error]') ? 'HIGH' : 'INFO', `${name}@${vpName}`, `console ${t.slice(0, 300)}`);
    for (const e of pageErrors) add('HIGH', `${name}@${vpName}`, `pageerror ${e.slice(0, 300)}`);
    for (const f of [...new Set(failedReq)]) {
      if (f.includes(' 404 ')) add('MED', `${name}@${vpName}`, `API 404 ${f}`);
      else add('HIGH', `${name}@${vpName}`, `API ${f}`);
    }

    // duplicate element ids (a11y/DOM integrity)
    const dupIds = await page.evaluate(() => {
      const seen = new Map();
      for (const el of document.querySelectorAll('[id]')) seen.set(el.id, (seen.get(el.id) || 0) + 1);
      return [...seen.entries()].filter(([, c]) => c > 1).map(([id, c]) => `${id}×${c}`);
    });
    if (dupIds.length) add('LOW', `${name}@${vpName}`, `duplicate DOM ids: ${dupIds.slice(0, 8).join(', ')}`);

    // images without alt
    const noAlt = await page.evaluate(() => [...document.querySelectorAll('img')].filter((i) => !i.hasAttribute('alt')).length);
    if (noAlt) add('LOW', `${name}@${vpName}`, `${noAlt} <img> without alt`);

    if (vpName === 'desktop') {
      await page.screenshot({ path: path.join(OUT, `${name}-desktop.png`), fullPage: true }).catch(() => {});
    }
    if (vpName === 'mobile') {
      await page.screenshot({ path: path.join(OUT, `${name}-mobile.png`), fullPage: true }).catch(() => {});
    }
    console.log(`done ${name}@${vpName} (findings so far: ${findings.length})`);
  }
  await ctx.close();
}

await browser.close();
fs.writeFileSync(path.join(OUT, 'sweep-findings.json'), JSON.stringify(findings, null, 2));
const counts = findings.reduce((a, f) => ((a[f.sev] = (a[f.sev] || 0) + 1), a), {});
console.log('\nTOTAL', findings.length, counts);
