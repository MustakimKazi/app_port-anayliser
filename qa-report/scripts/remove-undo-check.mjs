import { chromium } from '@playwright/test';
const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: 1920, height: 1080 } });
const page = await ctx.newPage();
const log = [];
page.on('pageerror', e => log.push('pageerror ' + e.message));

await page.goto('http://localhost:5173/ports?q=44441', { waitUntil: 'networkidle' });
await page.waitForTimeout(900);
const row = page.locator('table tbody tr').first();
const rowText = await row.innerText().catch(() => 'NO ROW');
log.push(`row: ${JSON.stringify(rowText.replace(/\n/g, ' | '))}`);
// open row actions: click row or a menu button
await row.click().catch(() => {});
await page.waitForTimeout(700);
await page.screenshot({ path: 'qa-report/evidence/port-drawer-dark-1920.png' });
// look for Remove button in drawer
const removeBtn = page.getByRole('button', { name: /^Remove$/i }).first();
const hasRemove = await removeBtn.count();
log.push(`Remove button present: ${hasRemove > 0}`);
if (hasRemove) {
  await removeBtn.click();
  await page.waitForTimeout(700);
  await page.screenshot({ path: 'qa-report/evidence/remove-dialog-dark-1920.png' });
  const dlgText = await page.locator('[role="dialog"], .fixed').last().innerText().catch(() => '');
  log.push(`remove dialog text: ${JSON.stringify(dlgText.slice(0, 600).replace(/\n+/g, ' | '))}`);
  // try to confirm: archive is default?
  const archiveBtn = page.getByRole('button', { name: /Archive/i }).first();
  const confirmBtn = page.getByRole('button', { name: /Confirm|Yes|Delete|Archive/i }).last();
  log.push(`archive option visible: ${await archiveBtn.count()}, confirm-ish: ${await confirmBtn.count()}`);
  await confirmBtn.click().catch(e => log.push('confirm click failed'));
  await page.waitForTimeout(1200);
  await page.screenshot({ path: 'qa-report/evidence/after-remove-dark-1920.png' });
  // undo toast?
  const undo = page.getByRole('button', { name: /Undo/i }).count();
  log.push(`Undo button visible: ${undo}`);
  if (undo) {
    await page.getByRole('button', { name: /Undo/i }).first().click();
    await page.waitForTimeout(1200);
    await page.goto('http://localhost:5173/ports?q=44441', { waitUntil: 'networkidle' });
    await page.waitForTimeout(800);
    const back = await page.locator('table tbody tr').count();
    log.push(`rows after undo: ${back}`);
  }
}
console.log(log.join('\n'));
await browser.close();
