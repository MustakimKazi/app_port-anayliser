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

  test('6. Prompt 6 Lifecycle Flow: add a port with a route -> set maintenance -> archive -> undo -> archive -> open trash -> restore', async ({ page }) => {
    // Log console errors/warnings
    page.on('console', (msg) => {
      if (msg.type() === 'error' || msg.type() === 'warning') {
        console.log(`[BROWSER ${msg.type().toUpperCase()}]:`, msg.text());
      }
    });

    // Generate unique port for each test run to avoid collision
    const testPort = 19000 + Math.floor(Math.random() * 5000);
    const backendPort = String(testPort + 1);

    // Automatically accept any dialogs (e.g. prompt for maintenance reason)
    page.on('dialog', async (dialog) => {
      await dialog.accept('Routine scheduled maintenance');
    });

    await page.goto('/ports');
    await expect(page.locator('h1')).toContainText('Ports');

    // Click "Add Port" button
    const addPortBtn = page.locator('button:has-text("Add Port")').first();
    await addPortBtn.click();
    await expect(page.locator('text=Add Port to PortWatch')).toBeVisible();

    // Step 1: Basics
    await page.locator('input[placeholder="e.g. 8080"]').fill(String(testPort));
    await page.locator('input[placeholder*="Customer Portal"]').fill(`E2E Test Port ${testPort}`);
    await page.locator('button:has-text("Next")').click();

    // Step 2: Network
    await expect(page.locator('text=Expected Bind Address')).toBeVisible();
    await page.locator('button:has-text("Next")').click();

    // Step 3: Attach Route
    await expect(page.locator('text=Create and Link Initial Route')).toBeVisible();
    await page.locator('#attachRouteCheck').check();
    await page.locator('input[placeholder="api.example.com"]').fill(`lifecycle-${testPort}.local`);
    await page.locator('input[placeholder="8080"]').fill(backendPort);
    await page.locator('button:has-text("Next")').click();

    // Step 4: Features
    await expect(page.locator('text=Choose Feature Preset')).toBeVisible();
    await page.locator('button:has-text("Next")').click();

    // Step 5: Review & Save
    await expect(page.locator('button:has-text("Save Port")')).toBeVisible();
    await page.locator('button:has-text("Save Port")').click();

    // Wait for Add Port dialog to close
    await expect(page.locator('text=Add Port to PortWatch')).not.toBeVisible();

    // Verify port appears in table
    const portRow = page.locator(`tr:has-text(":${testPort}")`).first();
    await expect(portRow).toBeVisible();

    // Open drawer
    await portRow.click();
    await expect(page.locator(`h2:has-text("Port :${testPort}")`)).toBeVisible();

    // Switch to Lifecycle tab
    await page.locator('button:has-text("Lifecycle")').click();
    await expect(page.locator('text=Current Lifecycle')).toBeVisible();

    // Click "Set Maintenance"
    await page.locator('button:has-text("Set Maintenance")').click();
    await expect(page.locator('span:has-text("MAINTENANCE")').first()).toBeVisible();

    // Close drawer
    await page.keyboard.press('Escape');
    await expect(page.locator(`h2:has-text("Port :${testPort}")`)).not.toBeVisible();

    // Archive port via row action
    const archiveBtn = portRow.locator('button[title*="Archive"]').first();
    await archiveBtn.click();

    // RemovePortDialog should appear with impact preview
    await expect(page.locator(`text=Remove Port :${testPort}`)).toBeVisible();
    await page.locator('button:has-text("Archive Port")').click();
    await expect(page.locator(`text=Remove Port :${testPort}`)).not.toBeVisible();

    // Undo toast should appear
    const undoToast = page.locator(`text=Port :${testPort} archived.`);
    await expect(undoToast).toBeVisible();

    // Click Undo
    const undoBtn = page.locator('button:has-text("Undo")');
    await undoBtn.click();

    // Verify port restored in table
    await expect(page.locator(`tr:has-text(":${testPort}")`).first()).toBeVisible();

    // Archive again
    const archiveBtnAgain = page.locator(`tr:has-text(":${testPort}")`).first().locator('button[title*="Archive"]').first();
    await archiveBtnAgain.click();
    await expect(page.locator(`text=Remove Port :${testPort}`)).toBeVisible();
    await page.locator('button:has-text("Archive Port")').click();
    await expect(page.locator(`text=Remove Port :${testPort}`)).not.toBeVisible();
    await expect(page.locator(`tr:has-text(":${testPort}")`)).not.toBeVisible();

    // Open Trash
    await page.locator('button:has-text("Trash")').first().click();
    await expect(page.locator('text=Archived Items & Trash')).toBeVisible();

    // Find port in trash and click Restore Port
    const trashPortRow = page.locator('div', { hasText: `Port :${testPort}` }).filter({ has: page.locator('button:has-text("Restore Port")') }).first();
    const restoreBtn = trashPortRow.locator('button:has-text("Restore Port")');
    await restoreBtn.click();

    // Close trash modal
    await page.locator('button[aria-label="Close dialog"]').click();
    await expect(page.locator('text=Archived Items & Trash')).not.toBeVisible();

    // Verify port is back in table
    await expect(page.locator(`tr:has-text(":${testPort}")`).first()).toBeVisible();
  });
});
