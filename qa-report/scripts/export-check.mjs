import { chromium } from '@playwright/test';
import fs from 'fs';
const OUT = 'qa-report/evidence';
const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: 1920, height: 1080 }, acceptDownloads: true });
const page = await ctx.newPage();
const log = [];

// filter ports by free-text "443"
await page.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
await page.locator('input[placeholder*="Search"]').first().fill('443');
await page.waitForTimeout(1200);
const visibleRows = await page.locator('table tbody tr').count();
log.push(`visible rows after filter q=443: ${visibleRows}`);

// hover export, click "Export CSV"
const exportWrap = page.locator('div.group:has(button:has-text("Export"))');
await exportWrap.hover();
await page.waitForTimeout(300);
const menuVisible = await page.getByText('Export CSV').isVisible().catch(() => false);
log.push(`export menu visible on hover: ${menuVisible}`);
const dlPromise = page.waitForEvent('download', { timeout: 8000 }).catch(() => null);
if (menuVisible) await page.getByText('Export CSV', { exact: true }).click();
const dl = await dlPromise;
if (dl) {
  const p = `${OUT}/export-ports-q443.csv`;
  await dl.saveAs(p);
  const content = fs.readFileSync(p, 'utf8');
  const rows = content.trim().split(/\r?\n/).length - 1;
  log.push(`filename: ${dl.suggestedFilename()}`);
  log.push(`CSV data rows: ${rows} (visible filtered rows: ${visibleRows})`);
  log.push(`BOM: ${content.charCodeAt(0) === 0xfeff}`);
  // does it contain 443 only?
  const portsInCsv = [...new Set(content.trim().split(/\r?\n/).slice(1).map(l => l.split(',')[2]))];
  log.push(`distinct port column values in export: ${portsInCsv.slice(0, 20).join(',')} (count ${portsInCsv.length})`);
} else log.push('no download event');

// keyboard accessibility of the menu
await page.keyboard.press('Escape');
const kb = await page.evaluate(() => {
  const btns = [...document.querySelectorAll('button')].filter(b => b.textContent.trim() === 'Export');
  if (!btns.length) return 'not found';
  btns[0].focus();
  return document.activeElement === btns[0] ? 'focusable' : 'not focusable';
});
log.push('export button keyboard focus: ' + kb);
// press Enter and see if menu opens
await page.evaluate(() => { const b=[...document.querySelectorAll('button')].find(b=>b.textContent.trim()==='Export'); b && b.focus(); });
await page.keyboard.press('Enter');
await page.waitForTimeout(300);
const menuAfterEnter = await page.getByText('Export CSV').isVisible().catch(() => false);
log.push(`export menu opens via keyboard Enter: ${menuAfterEnter}`);
await page.screenshot({ path: `${OUT}/export-menu-keyboard-dark-1920.png` });

console.log(log.join('\n'));
await browser.close();
