# PortWatch QA — Regression / Acceptance Tests

These tests encode the "must pass after the fixes" behaviour for the bugs in
`../BUG_REPORT.md`. They **fail on the unpatched build** (evidence:
`../evidence/test-*-before-fix.txt`) and **all pass once `../patches/ALL.diff`
is applied** (evidence: `../evidence/test-*-after-fix.txt`,
`../evidence/verify-scan-after-fix.txt`).

## Files

| Test | Covers | Needs |
|---|---|---|
| `api-auth.test.mjs` | BUG-001/003/004/008/010/013/019 — fail-closed auth, `x-role` backdoor, viewer mutations, rate limit, stack leaks, CORS reflect, security headers | API on `:3100` (unauthenticated asserts; logs in for mutation checks) |
| `api-validation.test.mjs` | BUG-021/013 — `limit=Infinity`, `page=0`, bounded pagination, generic errors | API (auto-logs in) |
| `api-import-export.test.mjs` | BUG-002/006/007 — import cannot wipe routes, entity allowlist, BOM, filename, archived leak, relations, formula injection | API (auto-logs in); destructive part only with `IMPORT_TEST=1` **on a scratch DB** |
| `web-ui.test.mjs` | BUG-005/024/025/026 — login redirect, horizontal overflow @390/768/1366, pagination footer, control labels | Chromium (`npx playwright install chromium`), web `:5173` |
| `scripts/verify-scan.ts` | BUG-014/015/016/017 — scanner vs `ss`, stale bind/latency, latency-on-failure, `$variable` probing | DB access; run migration `db/migrations/003_scanner_status_backfill.sql` first (backfills historical rows) |

## Running

```bash
# API tests (unpatched build: expect FAILURES; patched: expect ALL PASS)
node qa-report/tests/api-auth.test.mjs http://localhost:3100
node qa-report/tests/api-validation.test.mjs http://localhost:3100
node qa-report/tests/api-import-export.test.mjs http://localhost:3100

# Destructive import test — ONLY against a disposable database
IMPORT_TEST=1 API_URL=http://localhost:3200 node qa-report/tests/api-import-export.test.mjs

# Browser tests (logs in with admin/admin by default; overrides: ADMIN_USER/ADMIN_PASS)
npx playwright install chromium
node qa-report/tests/web-ui.test.mjs

# Scanner-vs-ss comparison ("matches N of M ports") — after one scan cycle
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/portwatch npx tsx qa-report/scripts/verify-scan.ts
```

Environment variables: `API_URL`, `WEB_URL`, `ADMIN_USER`, `ADMIN_PASS`
(API tests log in with `admin`/`admin` by default — the documented dev
credentials — and send the session cookie on routes that require it),
`VIEWER_COOKIE` (enables the viewer read-only assertions in `api-auth.test.mjs`).

## Measured result matrix

| Test | Unpatched (captured) | After `ALL.diff` (captured) |
|---|---|---|
| `api-auth.test.mjs` | **8 FAIL** (unauth reads=200, header backdoor, no 429, 500+leak, evil CORS reflected, no headers) | **ALL PASS** |
| `api-validation.test.mjs` | **5 FAIL** (500s on `limit=Infinity`/`page=0`, unbounded limit, Prisma leak) | **ALL PASS** |
| `api-import-export.test.mjs` | **5 FAIL** (unknown entity 200, no BOM, date-only filename, archived rows in export, blank relations) | **ALL PASS** |
| `web-ui.test.mjs` | **17 FAIL** (no /login redirect, overflow @390/768 all pages, overflow @1366 /ports,/routes, 38 unlabelled controls, no pagination footer) | **ALL PASS** |
| `scripts/verify-scan.ts` | **FAIL** (28/28 state matches, but 19 down ports with bind, 26 with latency, 19,953 failed checks w/ latency, `$variable` probed → down) | **ALL PASS** (28/28; migration 003 applied; `$jellyfin` → unknown/null) |

Notes:
- The `web-ui.test.mjs` overflow/label checks are only meaningful **with a
  session** (post-patch every page redirects to `/login` otherwise) — the test
  signs in automatically using the dev credentials.
- The scanner rules require migration `db/migrations/003_scanner_status_backfill.sql`
  (included in `patches/API-004-*.diff`) because historical `port_checks` rows
  retain fabricated latencies that the running scanner never rewrites.
