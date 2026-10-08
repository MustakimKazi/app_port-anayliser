import { test, expect, Page } from '@playwright/test';

test.use({ baseURL: 'http://localhost:5174' });

async function login(page: Page) {
  await page.goto('/login', { waitUntil: 'networkidle' });
  await page.fill('input[type="text"], input[name="username"]', 'admin');
  await page.fill('input[type="password"]', 'HgkO916f3APE');
  await page.click('button[type="submit"]');
  await page.waitForTimeout(800);
}

test.describe('Phase 2: detail views & domain management', () => {
  test('route row opens detail drawer with nginx preview (no crash)', async ({ page }) => {
    const errors: string[] = [];
    page.on('pageerror', (e) => errors.push(e.message));

    await login(page);
    await page.goto('/routes', { waitUntil: 'networkidle' });
    await page.waitForTimeout(800);

    const row = page.locator('tbody tr').first();
    await row.click();
    await page.waitForTimeout(800);

    await expect(page.getByRole('dialog')).toBeVisible();
    await expect(page.locator('text=Nginx Configuration Preview')).toBeVisible();
    expect(errors).toEqual([]);
  });

  test('certificate row opens drawer with deep-probe fields', async ({ page }) => {
    const errors: string[] = [];
    page.on('pageerror', (e) => errors.push(e.message));

    await login(page);
    await page.goto('/certificates', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    // abg.leadows.com is externally reachable and has a deep-probe record
    const row = page.locator('[data-testid="cert-row"]').filter({ hasText: 'abg.leadows.com' }).first();
    await row.click();

    await expect(page.getByRole('dialog')).toBeVisible();
    await expect(page.locator('text=SHA-256 Fingerprint')).toBeVisible({ timeout: 15000 });
    await expect(page.locator('text=Subject Alternative Names')).toBeVisible();
    expect(errors).toEqual([]);
  });

  test('config file opens full viewer with partition sidebar', async ({ page }) => {
    const errors: string[] = [];
    page.on('pageerror', (e) => errors.push(e.message));

    await login(page);
    await page.goto('/config-files', { waitUntil: 'networkidle' });
    await page.waitForTimeout(800);

    // open the first config card that has stored content
    const card = page.locator('[data-testid="config-card"]').filter({ hasText: 'Config stored' }).first();
    await expect(card).toBeVisible();
    await card.click();
    await page.waitForTimeout(1200);

    await expect(page.locator('[data-testid="config-detail-page"]')).toBeVisible();
    await expect(page.locator('[data-testid="config-code"]')).toBeVisible();
    const partitions = await page.locator('[data-testid="partition-item"]').count();
    expect(partitions).toBeGreaterThan(0);

    // clicking a partition highlights its lines
    await page.locator('[data-testid="partition-item"]').first().click();
    await page.waitForTimeout(400);
    expect(errors).toEqual([]);
  });

  test('backend row opens drawer with impact analysis', async ({ page }) => {
    const errors: string[] = [];
    page.on('pageerror', (e) => errors.push(e.message));

    await login(page);
    await page.goto('/backends', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    await page.locator('[data-testid="backend-row"]').first().click();
    await page.waitForTimeout(1000);

    await expect(page.locator('[data-testid="backend-drawer"]')).toBeVisible();
    await expect(page.locator('[data-testid="backend-impact-routes"]')).toBeVisible();
    expect(errors).toEqual([]);
  });

  test('domain drawer shows ports/routes and opens route detail', async ({ page }) => {
    const errors: string[] = [];
    page.on('pageerror', (e) => errors.push(e.message));

    await login(page);
    await page.goto('/routes', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    await page.locator('[data-testid="domain-info-btn"]').first().click();
    await page.waitForTimeout(1000);

    await expect(page.locator('[data-testid="domain-drawer"]')).toBeVisible();
    await expect(page.locator('[data-testid="domain-routes"]')).toBeVisible();

    await page.locator('[data-testid="domain-route-item"]').first().click();
    await page.waitForTimeout(800);
    await expect(page.locator('text=Nginx Configuration Preview')).toBeVisible();
    expect(errors).toEqual([]);
  });

  test('add-domain wizard creates domain, delete dialog removes it with typed confirmation', async ({ page }) => {
    const errors: string[] = [];
    page.on('pageerror', (e) => errors.push(e.message));
    const scratch = 'e2e-phase2.example.com';

    await login(page);
    await page.goto('/routes', { waitUntil: 'networkidle' });
    await page.waitForTimeout(800);

    // guard: clean up leftovers from a previous failed run
    const leftover = page.locator('div.rounded-xl.border').filter({ hasText: scratch });
    if ((await leftover.count()) > 0) {
      await leftover.first().locator('[data-testid="domain-remove-btn"]').click();
      await page.locator('[data-testid="choose-delete"]').click();
      await page.locator('[data-testid="delete-confirm-input"]').fill(scratch);
      await page.locator('[data-testid="confirm-delete"]').click();
      await page.waitForTimeout(800);
    }

    // --- create via wizard ---
    await page.locator('[data-testid="add-domain-btn"]').click();
    await page.locator('[data-testid="wizard-domain-input"]').fill(scratch);
    await page.locator('[data-testid="wizard-domain-new"]').waitFor();
    await page.getByRole('button', { name: /Next: Routes/ }).click();

    const row = page.locator('[data-testid="wizard-row"]').first();
    await row.locator('input[aria-label="Port"]').fill('443');
    await row.locator('input[aria-label="Target"]').fill('http://10.0.0.77:4444');
    await page.getByRole('button', { name: /Next: Review/ }).click();
    await expect(page.locator('[data-testid="wizard-review"]')).toBeVisible();
    await page.locator('[data-testid="wizard-submit"]').click();

    await expect(page.locator('[data-testid="add-domain-wizard"]')).toHaveCount(0);
    await expect(page.locator('div.rounded-xl.border').filter({ hasText: scratch }).first()).toBeVisible();

    // --- open drawer ---
    const card = page.locator('div.rounded-xl.border').filter({ hasText: scratch }).first();
    await card.locator('[data-testid="domain-info-btn"]').click();
    await expect(page.locator('[data-testid="domain-drawer"]')).toBeVisible();
    await expect(page.locator('[data-testid="domain-ports"]')).toContainText(':443');
    await page.keyboard.press('Escape');
    await page.waitForTimeout(300);

    // --- delete with typed confirmation ---
    await card.locator('[data-testid="domain-remove-btn"]').click();
    await expect(page.locator('[data-testid="delete-domain-dialog"]')).toBeVisible();
    await page.locator('[data-testid="choose-delete"]').click();

    const confirmBtn = page.locator('[data-testid="confirm-delete"]');
    await expect(confirmBtn).toBeDisabled();
    await page.locator('[data-testid="delete-confirm-input"]').fill('wrong-name');
    await expect(confirmBtn).toBeDisabled();
    await page.locator('[data-testid="delete-confirm-input"]').fill(scratch);
    await expect(confirmBtn).toBeEnabled();
    await confirmBtn.click();

    await expect(page.locator('[data-testid="delete-domain-dialog"]')).toHaveCount(0);
    await expect(page.locator('div.rounded-xl.border').filter({ hasText: scratch })).toHaveCount(0);
    expect(errors).toEqual([]);
  });
});
