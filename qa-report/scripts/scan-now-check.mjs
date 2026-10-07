import { chromium } from '@playwright/test';
const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: 1920, height: 1080 } });
const page = await ctx.newPage();
const log = [];
page.on('pageerror', e => log.push('pageerror ' + e.message));
page.on('console', m => { if (m.type() === 'error') log.push('console: ' + m.text().slice(0, 150)); });
await page.goto('http://localhost:5173/', { waitUntil: 'networkidle' });
await page.waitForTimeout(600);
const scanBtn = page.getByRole('button', { name: /Scan Now/i });
log.push(`scan button: ${await scanBtn.count()}`);
if (await scanBtn.count()) {
  await scanBtn.click();
  await page.waitForTimeout(1500);
  const header = await page.locator('header').innerText();
  log.push(`header after scan: ${JSON.stringify(header.replace(/\n+/g, ' | ').slice(0, 300))}`);
  await page.screenshot({ path: 'qa-report/evidence/scan-now-dark-1920.png' });
}
// live SSE indicator
const sse = await page.getByText(/Live SSE/).count();
log.push(`SSE indicator: ${sse}`);
// last scan time
const t = await page.locator('main').innerText();
const last = t.match(/Last scan[^\n]*/i);
log.push(`last scan text: ${JSON.stringify(last ? last[0] : 'not found')}`);
console.log(log.join('\n'));
await browser.close();
