import { chromium } from '@playwright/test';
import path from 'path';
import fs from 'fs';

const pages = [
  { name: 'dashboard', path: '/' },
  { name: 'ports', path: '/ports' },
  { name: 'routes', path: '/routes' },
  { name: 'backends', path: '/backends' },
  { name: 'issues', path: '/issues' },
  { name: 'config-files', path: '/config-files' },
  { name: 'certificates', path: '/certificates' },
  { name: 'port-map', path: '/port-map' },
  { name: 'history', path: '/history' },
  { name: 'settings', path: '/settings' },
];

const targetDir = process.argv[2] ? path.resolve(process.cwd(), process.argv[2]) : path.resolve(process.cwd(), 'docs/dark-theme/after');
fs.mkdirSync(targetDir, { recursive: true });

async function run() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 },
  });

  const page = await context.newPage();

  // Helper to ensure data loaded
  const waitForPageReady = async (pName: string) => {
    if (pName === 'dashboard') {
      await page.waitForSelector('text=Documented Domains', { timeout: 10000 }).catch(() => {});
    } else if (pName === 'ports') {
      await page.waitForSelector('tbody tr', { timeout: 10000 }).catch(() => {});
    } else if (pName === 'routes') {
      await page.waitForSelector('tbody tr', { timeout: 10000 }).catch(() => {});
    } else if (pName === 'backends') {
      await page.waitForSelector('text=Server Clusters', { timeout: 10000 }).catch(() => {});
    } else if (pName === 'issues') {
      await page.waitForSelector('text=Issues & Integrity Checks', { timeout: 10000 }).catch(() => {});
    }
    await page.waitForTimeout(500);
  };

  // 1. Capture all 10 pages in dark mode
  for (const p of pages) {
    console.log(`Capturing ${p.name} (dark)...`);
    await page.goto(`http://localhost:5173${p.path}`, { waitUntil: 'networkidle' });
    await page.evaluate(() => {
      document.documentElement.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    });
    await waitForPageReady(p.name);
    await page.screenshot({
      path: path.join(targetDir, `${p.name}-dark.png`),
      fullPage: true,
    });
  }

  // 2. Capture all 10 pages in light mode
  for (const p of pages) {
    console.log(`Capturing ${p.name} (light)...`);
    await page.goto(`http://localhost:5173${p.path}`, { waitUntil: 'networkidle' });
    await page.evaluate(() => {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    });
    await waitForPageReady(p.name);
    await page.screenshot({
      path: path.join(targetDir, `${p.name}-light.png`),
      fullPage: true,
    });
  }

  // Set back to dark for interactive states
  await page.evaluate(() => {
    document.documentElement.classList.add('dark');
    localStorage.setItem('theme', 'dark');
  });

  // 3. Export dropdown open
  console.log('Capturing Export dropdown open...');
  await page.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
  await page.evaluate(() => document.documentElement.classList.add('dark'));
  await page.waitForTimeout(600);
  const exportBtn = page.getByRole('button', { name: 'Export', exact: true });
  if (await exportBtn.isVisible()) {
    await exportBtn.click();
    await page.waitForTimeout(400);
    await page.screenshot({
      path: path.join(targetDir, 'ports-export-dropdown-dark.png'),
    });
    await page.screenshot({
      path: path.join(targetDir, 'export-dropdown-dark.png'),
    });
  }

  // Light export dropdown
  await page.evaluate(() => document.documentElement.classList.remove('dark'));
  await page.waitForTimeout(400);
  await page.screenshot({
    path: path.join(targetDir, 'ports-export-dropdown-light.png'),
  });

  // Back to dark
  await page.evaluate(() => document.documentElement.classList.add('dark'));

  // 4. A drawer open
  console.log('Capturing drawer open...');
  await page.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
  await page.evaluate(() => document.documentElement.classList.add('dark'));
  await page.waitForTimeout(600);
  const firstRow = page.locator('tbody tr:first-child');
  if (await firstRow.isVisible()) {
    await firstRow.click();
    await page.waitForTimeout(1000);
    await page.screenshot({
      path: path.join(targetDir, 'drawer-open-dark.png'),
    });
  }

  // 5. A dialog open
  console.log('Capturing dialog open...');
  await page.goto('http://localhost:5173/settings', { waitUntil: 'networkidle' });
  await page.evaluate(() => document.documentElement.classList.add('dark'));
  await page.waitForTimeout(600);
  const customFieldsTab = page.getByRole('button', { name: 'Custom Fields' });
  if (await customFieldsTab.isVisible()) {
    await customFieldsTab.click();
    await page.waitForTimeout(400);
    const addFieldBtn = page.getByRole('button', { name: 'Add Custom Field' });
    if (await addFieldBtn.isVisible()) {
      await addFieldBtn.click();
      await page.waitForTimeout(800);
      await page.screenshot({
        path: path.join(targetDir, 'dialog-open-dark.png'),
      });
    }
  }

  // 6. Table with a selected row
  console.log('Capturing table selected row...');
  await page.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
  await page.evaluate(() => document.documentElement.classList.add('dark'));
  await page.waitForTimeout(600);
  const firstCheckbox = page.locator('tbody tr:first-child input[type="checkbox"]');
  if (await firstCheckbox.isVisible()) {
    await firstCheckbox.click();
    await page.waitForTimeout(400);
    await page.screenshot({
      path: path.join(targetDir, 'table-selected-row-dark.png'),
    });
  }

  // 7. A toast notification
  console.log('Capturing toast / alert...');
  await page.goto('http://localhost:5173/settings', { waitUntil: 'networkidle' });
  await page.evaluate(() => document.documentElement.classList.add('dark'));
  await page.waitForTimeout(600);
  const alertsTab = page.getByRole('button', { name: 'Alerts & Channels' });
  if (await alertsTab.isVisible()) {
    await alertsTab.click();
    await page.waitForTimeout(400);
    const sendTestBtn = page.getByRole('button', { name: 'Send Test' });
    if (await sendTestBtn.isVisible()) {
      await sendTestBtn.click();
      await page.waitForTimeout(800);
      await page.screenshot({
        path: path.join(targetDir, 'toast-dark.png'),
      });
    }
  }

  // 8. Dependency graph
  console.log('Capturing dependency graph...');
  await page.goto('http://localhost:5173/backends', { waitUntil: 'networkidle' });
  await page.evaluate(() => document.documentElement.classList.add('dark'));
  await page.waitForTimeout(600);
  const topologyTab = page.getByRole('button', { name: 'Dependency Graph' });
  if (await topologyTab.isVisible()) {
    await topologyTab.click();
    await page.waitForTimeout(800);
    await page.screenshot({
      path: path.join(targetDir, 'dependency-graph-dark.png'),
      fullPage: true,
    });
  }

  await browser.close();
  console.log(`Saved screenshots to ${targetDir}`);
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
