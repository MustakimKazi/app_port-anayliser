import { chromium } from '@playwright/test';
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
const consoleMsgs = [];
const failed = [];
page.on('console', m => { if (['error','warning'].includes(m.type())) consoleMsgs.push(`[${m.type()}] ${m.text()}`); });
page.on('response', r => { if (r.status() >= 400) failed.push(`${r.status()} ${r.request().method()} ${r.url()}`); });
page.on('pageerror', e => consoleMsgs.push('[pageerror] ' + e.message));
const pages = ['/', '/ports', '/routes', '/backends', '/issues', '/config-files', '/certificates', '/port-map', '/history', '/settings'];
for (const p of pages) {
  await page.goto('http://localhost:5173' + p, { waitUntil: 'networkidle', timeout: 20000 }).catch(e => consoleMsgs.push('[nav] ' + p + ' ' + e.message));
  await page.waitForTimeout(800);
}
console.log('=== CONSOLE ===');
console.log(consoleMsgs.join('\n') || '(none)');
console.log('=== FAILED RESPONSES ===');
console.log([...new Set(failed)].join('\n') || '(none)');
await browser.close();
