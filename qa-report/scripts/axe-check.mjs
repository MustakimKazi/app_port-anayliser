import { chromium } from '@playwright/test';
import fs from 'fs';
import path from 'path';
const axePath = path.resolve('node_modules/axe-core/axe.min.js');
const axeSource = fs.readFileSync(axePath, 'utf8');
const pages = ['/', '/ports', '/routes', '/backends', '/issues', '/config-files', '/certificates', '/port-map', '/history', '/settings'];
const browser = await chromium.launch();
const out = [];
for (const theme of ['dark', 'light']) {
  const ctx = await browser.newContext({ viewport: { width: 1920, height: 1080 } });
  const page = await ctx.newPage();
  await page.addInitScript(t => localStorage.setItem('theme', t), theme);
  for (const p of pages) {
    await page.goto('http://localhost:5173' + p, { waitUntil: 'networkidle', timeout: 25000 }).catch(() => {});
    await page.waitForTimeout(600);
    await page.addScriptTag({ content: axeSource });
    const res = await page.evaluate(async () => await window.axe.run(document, { resultTypes: ['violations'] }));
    const v = res.violations.map(x => ({ id: x.id, impact: x.impact, nodes: x.nodes.length }));
    out.push({ page: p, theme, violations: v, total: v.length });
    if (v.length) await page.screenshot({ path: `qa-report/evidence/axe-${p === '/' ? 'dashboard' : p.replace(/\//g, '')}-${theme}-1920.png` });
  }
  await ctx.close();
}
fs.writeFileSync('qa-report/evidence/axe-results.json', JSON.stringify(out, null, 2));
for (const r of out) console.log(r.page, r.theme, '=>', r.total, JSON.stringify(r.violations));
await browser.close();
