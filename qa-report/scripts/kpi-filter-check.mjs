import { chromium } from '@playwright/test';
const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: 1920, height: 1080 } });
const page = await ctx.newPage();
const log = [];
page.on('pageerror', e => log.push('pageerror ' + e.message));

await page.goto('http://localhost:5173/', { waitUntil: 'networkidle' });
await page.waitForTimeout(800);

// capture KPI numbers
const kpiText = await page.locator('main').innerText();
const totalPorts = (kpiText.match(/TOTAL PORTS\s*\n?\s*(\d+)/) || [])[1];
const listening = (kpiText.match(/LISTENING \/ UP\s*\n?\s*(\d+)/) || [])[1];
const down = (kpiText.match(/DOWN \/ CLOSED\s*\n?\s*(\d+)/) || [])[1];
const openIssues = (kpiText.match(/OPEN ISSUES\s*\n?\s*(\d+)/) || [])[1];
log.push(`KPIs: total=${totalPorts} up=${listening} down=${down} issues=${openIssues}`);

// click "View All Ports"
await page.getByText('View All Ports').click().catch(() => log.push('View All Ports not clickable'));
await page.waitForTimeout(1200);
log.push(`after View All Ports -> url=${new URL(page.url()).pathname}${new URL(page.url()).search}`);
let rows = await page.locator('table tbody tr').count();
log.push(`ports rows shown=${rows}`);

// click down KPI? find clickable KPI elements
await page.goto('http://localhost:5173/', { waitUntil: 'networkidle' });
await page.waitForTimeout(600);
const clickableKpis = await page.locator('main [class*="cursor-pointer"], main a').count();
log.push(`clickable KPI/card elements on dashboard: ${clickableKpis}`);

// URL state: filter then reload
await page.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
await page.locator('input[placeholder*="Search"]').first().fill('443');
await page.waitForTimeout(1000);
const url1 = page.url();
log.push(`after filter url=${url1}`);
await page.reload({ waitUntil: 'networkidle' });
await page.waitForTimeout(800);
const val = await page.locator('input[placeholder*="Search"]').first().inputValue().catch(() => 'N/A');
log.push(`after reload search input value=${JSON.stringify(val)}`);

// invalid URL params
await page.goto('http://localhost:5173/ports?portMin=abc&portMax=zzz&status=notastatus', { waitUntil: 'networkidle' }).catch(() => log.push('nav with invalid params failed'));
await page.waitForTimeout(900);
const bodyText = await page.locator('main').innerText().catch(() => '');
log.push(`invalid params page: ${JSON.stringify(bodyText.slice(0, 200).replace(/\n+/g, ' | '))}`);
await page.screenshot({ path: 'qa-report/evidence/ports-invalid-params-light-1920.png' });

// history page uptime text
await page.goto('http://localhost:5173/history', { waitUntil: 'networkidle' });
await page.waitForTimeout(700);
const hist = await page.locator('main').innerText();
log.push(`history text: ${JSON.stringify(hist.slice(0, 400).replace(/\n+/g, ' | '))}`);

console.log(log.join('\n'));
await browser.close();
