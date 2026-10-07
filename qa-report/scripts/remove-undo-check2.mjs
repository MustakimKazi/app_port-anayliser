import { chromium } from '@playwright/test';
const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: 1920, height: 1080 } });
const page = await ctx.newPage();
const log = [];
page.on('pageerror', e => log.push('pageerror ' + e.message));

await page.goto('http://localhost:5173/ports?q=44441', { waitUntil: 'networkidle' });
await page.waitForTimeout(900);
const btn = page.locator('button[title="Remove / Archive Port"]').first();
log.push(`remove icon present: ${await btn.count()}`);
await btn.click();
await page.waitForTimeout(800);
await page.screenshot({ path: 'qa-report/evidence/remove-port-dialog-dark-1920.png' });
const overlay = page.locator('.fixed.inset-0').last();
const txt = await overlay.innerText().catch(() => '');
log.push(`dialog text: ${JSON.stringify(txt.replace(/\n+/g, ' | ').slice(0, 900))}`);
// click the primary/confirm button
const buttons = await overlay.locator('button').allInnerTexts();
log.push(`dialog buttons: ${JSON.stringify(buttons)}`);
const arch = overlay.locator('button', { hasText: /Archive/i }).last();
if (await arch.count()) {
  await arch.click();
  await page.waitForTimeout(1500);
  await page.screenshot({ path: 'qa-report/evidence/after-archive-undo-dark-1920.png' });
  const undoCount = await page.getByRole('button', { name: /Undo/i }).count();
  log.push(`undo button count: ${undoCount}`);
  const pageTxt = await page.locator('main').innerText();
  const m = pageTxt.match(/Undo[^\n]*/);
  log.push(`undo area: ${JSON.stringify(m ? m[0] : 'none')}`);
  if (undoCount) {
    await page.getByRole('button', { name: /Undo/i }).first().click();
    await page.waitForTimeout(1500);
    await page.goto('http://localhost:5173/ports?q=44441', { waitUntil: 'networkidle' });
    await page.waitForTimeout(800);
    log.push(`rows after undo: ${await page.locator('table tbody tr').count()}`);
  } else {
    // maybe it disappeared -> check trash
    await page.goto('http://localhost:5173/ports?q=44441', { waitUntil: 'networkidle' });
    await page.waitForTimeout(600);
    log.push(`rows after archive: ${await page.locator('table tbody tr').count()}`);
  }
}
console.log(log.join('\n'));
await browser.close();
