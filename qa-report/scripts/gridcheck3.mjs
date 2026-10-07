import { chromium } from '@playwright/test';
const b = await chromium.launch();
const p = await b.newPage({ viewport: { width: 1920, height: 1080 } });
await p.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
await p.waitForTimeout(900);
await p.locator('table tbody tr').first().click();
await p.waitForTimeout(1200);
const info = await p.evaluate(() => {
  const els = [...document.querySelectorAll('div')].filter(e => String(e.className).includes('grid-cols-24'));
  if (!els.length) return 'not found';
  const e = els[0];
  return { gtc: getComputedStyle(e).gridTemplateColumns, kids: e.children.length, rect: e.getBoundingClientRect().toJSON() };
});
console.log(JSON.stringify(info, null, 1));
if (typeof info === 'object' && info.gtc) await p.screenshot({ path: 'qa-report/evidence/port-drawer-uptime-strip.png', clip: { x: 1200, y: 0, width: 720, height: 1080 } });
await b.close();
