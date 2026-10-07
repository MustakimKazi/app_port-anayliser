import { chromium } from '@playwright/test';
import fs from 'fs';
const axeSource = fs.readFileSync('node_modules/axe-core/axe.min.js', 'utf8');
const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: 1920, height: 1080 } });
const page = await ctx.newPage();
await page.addInitScript(() => localStorage.setItem('theme', 'light'));
await page.goto('http://localhost:5173/issues', { waitUntil: 'networkidle' });
await page.addScriptTag({ content: axeSource });
const res = await page.evaluate(async () => await window.axe.run(document));
for (const v of res.violations.filter(v => ['color-contrast','label','select-name'].includes(v.id))) {
  console.log('##', v.id, v.impact, v.nodes.length);
  v.nodes.slice(0, 4).forEach(n => console.log('  -', n.target.join(' '), '|', (n.any[0]?.message||'').slice(0,180)));
}
// ports labels
await page.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
await page.addScriptTag({ content: axeSource });
const res2 = await page.evaluate(async () => await window.axe.run(document));
for (const v of res2.violations.filter(v => ['label','select-name','color-contrast'].includes(v.id))) {
  console.log('PORTS ##', v.id, v.impact, v.nodes.length);
  v.nodes.slice(0, 5).forEach(n => console.log('  -', n.target.join(' '), '|', (n.any[0]?.message||'').slice(0,160)));
}
await browser.close();
