/**
 * Regression tests for the browser-side bugs:
 *  - BUG-005: no login page / silent admin fallback (must redirect to /login)
 *  - BUG-024: horizontal overflow at 390 / 768 / 1366 px
 *  - BUG-025: ports table pagination footer when >1 page of rows
 *  - BUG-026: critical axe violations (form labels) on /ports
 *
 * Run:  node qa-report/tests/web-ui.test.mjs
 * Requires: web app dev server on :5173 and API on :3100,
 * plus @playwright/test chromium (npx playwright install chromium).
 */
import { chromium } from '@playwright/test';

const WEB = process.env.WEB_URL || 'http://localhost:5173';
const API = process.env.API_URL || 'http://localhost:3100';
let failures = 0;

function check(name, cond, detail) {
  if (cond) console.log(`  PASS  ${name}`);
  else {
    failures++;
    console.log(`  FAIL  ${name}${detail ? ' — ' + detail : ''}`);
  }
}

async function hasHOverflow(page) {
  return page.evaluate(() => {
    const de = document.documentElement;
    return de.scrollWidth > de.clientWidth + 1;
  });
}

async function main() {
  console.log(`web UI tests against ${WEB}\n`);
  const browser = await chromium.launch();

  // ---- 1. Unauthenticated users land on the login page ----
  {
    const ctx = await browser.newContext();
    const page = await ctx.newPage();
    await page.goto(WEB + '/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1200);
    const onLogin =
      page.url().includes('/login') ||
      (await page.locator('input[type="password"]').count()) > 0;
    check('unauthenticated visit redirects to /login', onLogin, `url=${page.url()}`);
    await ctx.close();
  }

  // ---- 2. Overflow checks (with a session — after the auth patch every page
  //         redirects to /login unless we sign in first) ----
  const ctx = await browser.newContext({ viewport: { width: 390, height: 844 } });
  const page = await ctx.newPage();

  await page.goto(WEB + '/login', { waitUntil: 'networkidle' });
  if ((await page.locator('input[type="password"]').count()) > 0) {
    await page.fill('input[type="text"]', process.env.ADMIN_USER || 'admin');
    await page.fill('input[type="password"]', process.env.ADMIN_PASS || 'admin');
    await page.click('button[type="submit"]');
    await page.waitForTimeout(1500);
  }

  const pages = ['/', '/ports', '/routes', '/backends', '/issues', '/settings'];
  for (const width of [390, 768, 1366]) {
    await page.setViewportSize({ width, height: 900 });
    for (const path of pages) {
      await page.goto(WEB + path, { waitUntil: 'networkidle' });
      await page.waitForTimeout(700);
      const overflow = await hasHOverflow(page);
      check(`no horizontal overflow @ ${width}px ${path}`, !overflow,
        overflow ? 'document scrolls horizontally' : '');
    }
  }

  // ---- 3. /ports accessibility: labelled controls ----
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.goto(WEB + '/ports', { waitUntil: 'networkidle' });
  await page.waitForTimeout(900);
  const unlabelled = await page.evaluate(() => {
    const els = [...document.querySelectorAll('input, select')];
    return els.filter((el) => {
      if (el.type === 'hidden') return false;
      const hasLabel =
        el.getAttribute('aria-label') ||
        el.getAttribute('aria-labelledby') ||
        (el.id && document.querySelector(`label[for="${el.id}"]`)) ||
        el.closest('label');
      return !hasLabel;
    }).length;
  });
  check('every input/select on /ports has an accessible name', unlabelled === 0,
    `${unlabelled} unlabelled controls`);

  // ---- 4. Pagination footer visible when the data spans multiple pages (BUG-025) ----
  await page.goto(WEB + '/ports?limit=10&page=2', { waitUntil: 'networkidle' });
  await page.waitForTimeout(900);
  const footer = await page.getByText(/Page \d+ of \d+/).count();
  check('ports table shows a pagination footer when >1 page exists', footer > 0,
    'no "Page x of y" footer found');

  await ctx.close();
  await browser.close();

  console.log(failures === 0 ? '\nALL PASS' : `\n${failures} FAILURE(S)`);
  process.exit(failures === 0 ? 0 : 1);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
