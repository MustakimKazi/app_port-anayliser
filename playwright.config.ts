import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30000,
  expect: {
    timeout: 5000
  },
  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
    headless: true
  },
  webServer: [
    {
      command: 'node apps/api/dist/server.js',
      port: 3100,
      reuseExistingServer: true,
      timeout: 15000
    },
    {
      command: 'npm run preview --workspace=@portwatch/web -- --port 5173',
      port: 5173,
      reuseExistingServer: true,
      timeout: 15000
    }
  ]
});
