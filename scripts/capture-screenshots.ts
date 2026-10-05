import { chromium } from '@playwright/test';
import path from 'path';

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

const targetDirName = process.argv[2] || 'before';
const outputDir = path.resolve(process.cwd(), 'docs/color-check', targetDirName);

async function run() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 },
  });

  const page = await context.newPage();

  for (const p of pages) {
    console.log(`Capturing ${p.name}...`);
    await page.goto(`http://localhost:5173${p.path}`, { waitUntil: 'networkidle' });
    // wait a moment for any animations or queries
    await page.waitForTimeout(1000);

    // 1. Dark theme (default or ensure dark)
    await page.evaluate(() => {
      document.documentElement.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    });
    await page.waitForTimeout(300);
    await page.screenshot({
      path: path.join(outputDir, `${p.name}-dark.png`),
      fullPage: true,
    });

    // 2. Light theme
    await page.evaluate(() => {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    });
    // If there's a theme toggle button, we can also click it if needed or trigger event
    await page.waitForTimeout(300);
    await page.screenshot({
      path: path.join(outputDir, `${p.name}-light.png`),
      fullPage: true,
    });
  }

  // Also capture Export dropdown open on /ports
  await page.goto('http://localhost:5173/ports', { waitUntil: 'networkidle' });
  await page.waitForTimeout(500);
  const exportBtn = page.getByRole('button', { name: 'Export', exact: true });
  if (await exportBtn.isVisible()) {
    // Dark mode export
    await page.evaluate(() => document.documentElement.classList.add('dark'));
    await exportBtn.hover();
    await page.waitForTimeout(300);
    await page.screenshot({
      path: path.join(outputDir, `ports-export-dropdown-dark.png`),
    });
    // Light mode export
    await page.evaluate(() => document.documentElement.classList.remove('dark'));
    await exportBtn.hover();
    await page.waitForTimeout(300);
    await page.screenshot({
      path: path.join(outputDir, `ports-export-dropdown-light.png`),
    });
  }

  await browser.close();
  console.log(`Saved screenshots to ${outputDir}`);
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
