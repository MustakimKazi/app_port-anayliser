# Contributing to PortWatch

Thank you for contributing to **PortWatch**! This document provides guidelines for extending the architecture, adding new check types, creating custom fields, and adding new pages.

---

## 1. Architecture Overview

PortWatch follows a clean monorepo architecture:
- `/apps/api`: Node.js 20 + TypeScript + Fastify + Prisma ORM + PostgreSQL 16.
  - `src/modules/<entity>/`: Self-contained REST controllers, route definitions, and validations.
  - `src/scanner/`: Background network scanner services, TCP/HTTP/TLS socket probers, and automated issue rules.
  - `src/realtime/`: Server-Sent Events (SSE) broadcasting engine.
- `/apps/web`: React 18 + TypeScript + Vite + Tailwind CSS + TanStack Table + TanStack Query + Recharts.
  - `src/features/<entity>/`: Self-contained feature pages, tables, filters, and drawers.
  - `src/components/ui/`: Reusable design system primitives (Cards, Badges, Modals, Drawers, CodeBlocks).
- `/db`: Database initialization, migration scripts, and aggregated SQL views (`v_port_overview`).
- `/scripts`: Repeatable seed parser and Excel ingestion tools.

---

## 2. How to Add a New Custom Field

Admins can add new fields **directly through the UI** under **Settings > Custom Fields** without writing code:
1. Navigate to **Settings > Custom Fields**.
2. Click **Add Custom Field**.
3. Select the target entity: `Port`, `Route`, `Backend`, or `Server`.
4. Choose the data type: `text`, `number`, `select`, `boolean`, `date`, or `url`.
5. The field is immediately stored in PostgreSQL and appears in drawers, tables, and exports.

To programmatically add a built-in column:
1. Add the column to `apps/api/prisma/schema.prisma`.
2. Run `npx prisma db push --schema=apps/api/prisma/schema.prisma` to sync PostgreSQL.
3. Update `db/views.sql` if the column is part of the `v_port_overview` aggregation view.
4. Add the column key and header in `apps/web/src/types/index.ts` and the matching feature table.

---

## 3. How to Add a New Check Type

The scanner engine in `apps/api/src/scanner/` is fully modular:
1. **Create a checker class** in `apps/api/src/scanner/<type>-checker.ts`:
   ```typescript
   export class PingChecker {
     async check(host: string, timeoutMs: number = 3000): Promise<{ status: 'up' | 'down'; latencyMs: number }> {
       // Perform ICMP ping or system socket check
     }
   }
   export const pingChecker = new PingChecker();
   ```
2. **Register the probe in `apps/api/src/scanner/scanner-service.ts`**:
   - Call your checker within the `runScan()` orchestration loop.
   - Record results in `port_checks` with `checkType: '<type>'`.
   - Fire status transitions to `recordStatusEvent()` if status changes.
3. **Register auto-detection rules in `apps/api/src/scanner/issue-detector.ts`** if specific failure patterns should auto-create tickets.

---

## 4. How to Add a New Page / Feature

1. **Backend**:
   - Add `apps/api/src/modules/<new-entity>/<new-entity>.routes.ts`.
   - Mount the route in `apps/api/src/app.ts` under `/api/<new-entity>`.
2. **Frontend**:
   - Create `apps/web/src/features/<new-entity>/<NewEntity>Page.tsx`.
   - Add the navigation link with an icon in `apps/web/src/components/layout/Sidebar.tsx`.
   - Register the route in `apps/web/src/App.tsx`.
   - Register quick-jump shortcuts in `apps/web/src/components/ui/CommandPalette.tsx`.

---

## 5. Development Workflow & Testing

```bash
# Start development database
docker compose up -d db

# Run database migrations and seed
npm run prisma:push
npm run seed

# Run unit and integration tests
npm test

# Run Playwright E2E tests
npx playwright test

# Build production bundles
npm run build
```
