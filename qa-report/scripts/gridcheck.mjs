import { chromium } from '@playwright/test';
const b = await chromium.launch();
const p = await b.newPage({ viewport: { width: 1920, height: 1080 } });
await p.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
await p.waitForTimeout(800);
const info = await p.evaluate(() => {
  const el = document.querySelector('[class*="grid-cols-24"]');
  if (!el) return 'element with grid-cols-24 not found';
  const cs = getComputedStyle(el);
  return { gtc: cs.gridTemplateColumns, childCount: el.children.length, h: el.getBoundingClientRect().height, w: el.getBoundingClientRect().width };
});
console.log(JSON.stringify(info, null, 1));
if (typeof info === 'object' && info.gtc === 'none') {
  const el = await p.locator('[class*="grid-cols-24"]').first();
  await el.screenshot({ path: 'qa-report/evidence/uptime-strip-broken-grid.png' }).catch(()=>{});
}
await b.close();
