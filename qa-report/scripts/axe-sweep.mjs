/* axe accessibility sweep over all pages × themes. Run: node qa-report/scripts/axe-sweep.mjs */
import { chromium } from '@playwright/test';
import fs from 'fs';
import path from 'path';

const BASE = process.env.PORTWATCH_WEB || 'http://localhost:5174';
const axePath = path.resolve('node_modules/axe-core/axe.min.js');
const axeSource = fs.readFileSync(axePath, 'utf8');
const pages = ['/', '/ports', '/routes', '/backends', '/issues', '/config-files', '/certificates', '/port-map', '/history', '/settings', '/login'];
const browser = await chromium.launch();
const out = [];
for (const theme of ['dark', 'light']) {
  const ctx = await browser.newContext({ viewport: { width: 1920, height: 1080 } });
  const page = await ctx.newPage();
  await page.goto(BASE + '/login', { waitUntil: 'networkidle' });
  if (await page.locator('input[type="password"]').count()) {
    await page.fill('input[type="text"]', 'admin');
    await page.fill('input[type="password"]', 'admin');
    await page.click('button[type="submit"]');
    await page.waitForTimeout(1500);
  }
  await page.addInitScript((t) => localStorage.setItem('theme', t), theme);
  for (const p of pages) {
    await page.goto(BASE + p, { waitUntil: 'networkidle', timeout: 25000 }).catch(() => {});
    await page.waitForTimeout(1000);
    await page.addScriptTag({ content: axeSource });
    const res = await page.evaluate(async () => await window.axe.run(document, { resultTypes: ['violations'] }));
    const v = res.violations.map((x) => ({ id: x.id, impact: x.impact, nodes: x.nodes.length, sample: x.nodes[0]?.html?.slice(0, 140) }));
    out.push({ page: p, theme, violations: v, total: v.length });
    if (v.length) await page.screenshot({ path: `qa-report/evidence/ui-sweep/axe-${p === '/' ? 'dashboard' : p.replace(/\//g, '')}-${theme}.png` });
  }
  await ctx.close();
}
fs.writeFileSync('qa-report/evidence/ui-sweep/axe-results-patched.json', JSON.stringify(out, null, 2));
for (const r of out) if (r.total) console.log(r.page, r.theme, '=>', JSON.stringify(r.violations));
const tot = out.reduce((a, r) => a + r.total, 0);
console.log('pages with violations:', out.filter((r) => r.total).length, '/', out.length, '| total rule-hits:', tot);
await browser.close();
