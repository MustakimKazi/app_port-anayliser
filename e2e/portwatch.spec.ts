import { test, expect } from '@playwright/test';

test.describe('PortWatch End-to-End Suite', () => {
  test('1. Dashboard loads KPIs and server metadata', async ({ page }) => {
    await page.goto('/');

    // Check title and server badge
    await expect(page).toHaveTitle(/PortWatch/);
    await expect(page.locator('text=leadowserver').first()).toBeVisible();

    // Check KPI metric cards are rendered
    await expect(page.locator('text=Total Ports')).toBeVisible();
    await expect(page.locator('text=Listening / UP')).toBeVisible();
    await expect(page.locator('text=Down / Closed')).toBeVisible();
    await expect(page.locator('text=Open Issues')).toBeVisible();
  });

  test('2. Filter ports table and verify URL search parameter sync', async ({ page }) => {
    await page.goto('/ports');

    // Verify Ports page loaded
    await expect(page.locator('h1')).toContainText('Ports');

    // Filter by layer = stream (select 0 is saved views, select 1 is status, select 2 is layer)
    const layerSelect = page.locator('select').nth(2);
    await layerSelect.selectOption('stream');

    // URL should reflect layer=stream
    await expect(page).toHaveURL(/layer=stream/);

    // Filtered rows should display stream ports (7001, 60007 etc.)
    await expect(page.locator('text=:7001').first()).toBeVisible();

    // Search for 7002
    const searchInput = page.locator('input[placeholder*="Search port"]');
    await searchInput.fill('7002');
    await expect(page).toHaveURL(/q=7002/);
    await expect(page.locator('text=:7002').first()).toBeVisible();
  });

  test('3. Clicking a port row opens the side drawer with details & uptime bar', async ({ page }) => {
    await page.goto('/ports');

    // Click on port 443 row
    const port443 = page.locator('tr:has-text(":443")').first();
    await port443.click();

    // Drawer should open with Port :443 title
    await expect(page.locator('h2:has-text("Port :443")')).toBeVisible();
    await expect(page.locator('text=24-Hour Uptime Bar')).toBeVisible();

    // Switch to Routes tab inside drawer
    await page.locator('button:has-text("Routes")').click();
    await expect(page.locator('text=domain routes configured on this port')).toBeVisible();

    // Close drawer via Escape or close button
    await page.keyboard.press('Escape');
    await expect(page.locator('h2:has-text("Port :443")')).not.toBeVisible();
  });

  test('4. Issues Kanban loads and displays copy-to-clipboard code blocks', async ({ page }) => {
    await page.goto('/issues');

    // Kanban column headers should be visible
    await expect(page.locator('span.uppercase:has-text("Open")')).toBeVisible();
    await expect(page.locator('span.uppercase:has-text("Acknowledged")')).toBeVisible();
    await expect(page.locator('span.uppercase:has-text("Resolved")')).toBeVisible();

    // High priority issues like port 8080 should be present
    await expect(page.locator('text=Port 8080 used twice').first()).toBeVisible();
    await expect(page.locator('text=sudo ss -tlnp | grep :8080').first()).toBeVisible();
  });

  test('5. Free Port Finder tool operates correctly', async ({ page }) => {
    await page.goto('/port-map');

    // Click "Find Free Ports" button
    const findButton = page.locator('button:has-text("Find Free Ports")');
    await findButton.click();

    // Results container should show available ports
    await expect(page.locator('text=Available Next Ports:')).toBeVisible();
  });
});
