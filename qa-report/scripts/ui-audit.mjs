import { chromium, firefox } from '@playwright/test';
import fs from 'fs';

const OUT = 'qa-report/evidence';
const pages = ['/', '/ports', '/routes', '/backends', '/issues', '/config-files', '/certificates', '/port-map', '/history', '/settings'];
const widths = [1920, 1366, 768, 390];
const results = [];

async function audit(browser, browserName) {
  for (const theme of ['dark', 'light']) {
    for (const w of widths) {
      const ctx = await browser.newContext({ viewport: { width: w, height: 1000 } });
      const page = await ctx.newPage();
      const errs = [];
      page.on('console', m => { if (m.type() === 'error') errs.push(m.text().slice(0, 200)); });
      page.on('pageerror', e => errs.push('pageerror: ' + e.message.slice(0, 200)));
      await page.addInitScript(t => localStorage.setItem('theme', t), theme);
      for (const p of pages) {
        await page.goto('http://localhost:5173' + p, { waitUntil: 'networkidle', timeout: 25000 }).catch(() => {});
        await page.waitForTimeout(500);
        const name = p === '/' ? 'dashboard' : p.replace(/\//g, '');
        // screenshot at 1920 all themes, plus all widths for ports/settings/dashboard
        if (w === 1920 || ['/ports', '/settings', '/'].includes(p)) {
          await page.screenshot({ path: `${OUT}/${browserName}-${name}-${theme}-${w}.png`, fullPage: w === 1920 });
        }
        const overflow = await page.evaluate(() => ({
          scrollW: document.documentElement.scrollWidth,
          clientW: document.documentElement.clientWidth
        }));
        if (overflow.scrollW > overflow.clientW + 2) {
          results.push({ type: 'h-overflow', browser: browserName, theme, width: w, page: p, detail: `${overflow.scrollW} > ${overflow.clientW}` });
        }
        // background colour sanity
        const bg = await page.evaluate(() => getComputedStyle(document.body).backgroundColor);
        const expected = theme === 'light' ? 'rgb(244, 240, 229)' : null;
        if (theme === 'light' && bg !== expected) {
          results.push({ type: 'light-bg', browser: browserName, width: w, page: p, detail: `expected #F4F0E5 got ${bg}` });
        }
      }
      for (const e of [...new Set(errs)]) results.push({ type: 'console-error', browser: browserName, theme, width: w, detail: e });
      await ctx.close();
    }
  }
}

const b1 = await chromium.launch();
await audit(b1, 'chromium');
await b1.close();
try {
  const b2 = await firefox.launch();
  await audit(b2, 'firefox');
  await b2.close();
} catch (e) { results.push({ type: 'firefox-error', detail: String(e).slice(0, 300) }); }

fs.writeFileSync(`${OUT}/ui-audit-results.json`, JSON.stringify(results, null, 2));
console.log(JSON.stringify(results, null, 2));
