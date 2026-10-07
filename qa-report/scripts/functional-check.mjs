import { chromium } from '@playwright/test';
import fs from 'fs';
const OUT = 'qa-report/evidence';
const browser = await chromium.launch();
const findings = [];
const ctx = await browser.newContext({ viewport: { width: 1920, height: 1080 }, acceptDownloads: true });
const page = await ctx.newPage();
page.on('pageerror', e => findings.push('pageerror: ' + e.message));

// --- 1. theme toggle ---
await page.goto('http://localhost:5173/', { waitUntil: 'networkidle' });
const before = await page.evaluate(() => document.documentElement.classList.contains('dark'));
await page.getByRole('button', { name: /Toggle theme/i }).click().catch(async () => {
  await page.locator('button[aria-label="Toggle theme"]').click();
});
await page.waitForTimeout(400);
const after = await page.evaluate(() => document.documentElement.classList.contains('dark'));
findings.push(`theme toggle: dark ${before} -> ${after} (${before !== after ? 'OK' : 'BROKEN'})`);
const systemOption = await page.getByText(/system/i).count();
findings.push(`system theme option occurrences on page: ${systemOption}`);
await page.screenshot({ path: `${OUT}/theme-toggle-after-light-1920.png` });

// --- 2. ports export with filter ---
await page.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
await page.waitForTimeout(500);
// filter by search q
await page.locator('input[placeholder*="Search"], input[type="search"]').first().fill('443');
await page.waitForTimeout(1000);
const visibleRows = await page.locator('table tbody tr').count();
findings.push(`ports filtered rows for '443': ${visibleRows}`);
// open export menu (hover)
const exportBtn = page.getByRole('button', { name: /Export/i }).first();
await exportBtn.hover().catch(() => {});
await page.waitForTimeout(300);
const dl = page.waitForEvent('download', { timeout: 8000 }).catch(() => null);
await page.getByText('CSV', { exact: true }).first().click().catch(() => findings.push('export menu: CSV item not clickable'));
const download = await dl;
if (download) {
  const p = `${OUT}/export-ports-filtered-443.csv`;
  await download.saveAs(p);
  const content = fs.readFileSync(p, 'utf8');
  const rows = content.trim().split('\n').length - 1;
  findings.push(`export filename: ${download.suggestedFilename()}`);
  findings.push(`export CSV rows: ${rows} vs visible rows: ${visibleRows}`);
  findings.push(`CSV starts with BOM: ${content.charCodeAt(0) === 0xfeff}`);
} else {
  findings.push('export: no download started');
}
await page.screenshot({ path: `${OUT}/ports-export-menu-dark-1920.png` });

// --- 3. add port dialog validation ---
await page.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
const addBtn = page.getByRole('button', { name: /Add Port/i }).first();
if (await addBtn.count()) {
  await addBtn.click();
  await page.waitForTimeout(500);
  await page.screenshot({ path: `${OUT}/add-port-dialog-dark-1920.png` });
  // try invalid port 70000
  const numInput = page.locator('input[type="number"], input[inputmode="numeric"]').first();
  if (await numInput.count()) {
    await numInput.fill('70000');
    await page.waitForTimeout(300);
    const err = await page.getByText(/65535|invalid|between/i).count();
    findings.push(`add-port validation for 70000: ${err > 0 ? 'shown' : 'NOT SHOWN'}`);
    await page.screenshot({ path: `${OUT}/add-port-validation-70000-dark-1920.png` });
  } else findings.push('add-port: no numeric input found');
  await page.keyboard.press('Escape');
} else findings.push('add-port: Add Port button not found');

// --- 4. viewer role gating (mock /auth/me) ---
const ctx2 = await browser.newContext({ viewport: { width: 1920, height: 1080 } });
const p2 = await ctx2.newPage();
await p2.route('**/api/auth/me', route => route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ id: 'v', username: 'viewer', role: 'viewer' }) }));
await p2.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
await p2.waitForTimeout(800);
const addVisible = await p2.getByRole('button', { name: /Add Port/i }).count();
findings.push(`viewer sees Add Port button: ${addVisible > 0 ? 'YES (gate broken)' : 'no (hidden OK)'}`);
const headerUser = await p2.locator('header').innerText().catch(() => '');
findings.push(`header identity text (viewer session): ${JSON.stringify(headerUser.slice(0, 120))}`);
await p2.screenshot({ path: `${OUT}/viewer-ports-light-1920.png` });
await ctx2.close();

// --- 5. dashboard KPIs ---
await page.goto('http://localhost:5173/', { waitUntil: 'networkidle' });
await page.waitForTimeout(600);
const kpis = await page.locator('main').innerText();
findings.push('dashboard KPI text: ' + JSON.stringify(kpis.slice(0, 500).replace(/\n+/g, ' | ')));
await page.screenshot({ path: `${OUT}/dashboard-dark-1920-full.png`, fullPage: true });

console.log(findings.join('\n'));
await browser.close();
