import { chromium } from '@playwright/test';
const b = await chromium.launch();
const p = await b.newPage({ viewport: { width: 1920, height: 1080 } });
await p.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
await p.waitForTimeout(1000);
const found = await p.evaluate(() => document.body.innerHTML.includes('grid-cols-24'));
console.log('grid-cols-24 present in DOM:', found);
const info = await p.evaluate(() => {
  const els = [...document.querySelectorAll('div')].filter(e => e.className && String(e.className).includes('grid-cols-24'));
  return els.slice(0,1).map(e => ({ gtc: getComputedStyle(e).gridTemplateColumns, kids: e.children.length, rect: e.getBoundingClientRect().toJSON() }));
});
console.log(JSON.stringify(info, null, 1));
await b.close();
