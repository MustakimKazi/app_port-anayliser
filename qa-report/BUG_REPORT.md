# PortWatch — QA / Code Review / Security Bug Report

**Project:** PortWatch (apps/api Fastify+Prisma, apps/web React+Vite)
**Reviewed:** working tree of `/home/leadows/Downloads/app_port-anayliser` (uncommitted state as provided)
**Date:** 2026-10-07
**QA environment:** dashboard `http://localhost:5173`, API `http://localhost:3100`, PostgreSQL `localhost:5432/portwatch` (scratch DB `portwatch_qa` for destructive tests), Chromium/Firefox (WebKit install blocked — see §7).
**Method:** code review of API + web, live API probing, browser test runs (screenshots, axe, overflow checks), scanner-vs-`ss` verification, Excel-vs-DB comparison, standalone regression tests, unified-diff patches verified with `git apply --check` (all against a pristine copy of the provided tree).

**Patch convention:** every patch in `patches/` applies cleanly to the tree as provided
(`git apply --check` passes for each file and for `patches/ALL.diff`). Patches were additionally
type-checked (`tsc --noEmit` clean for API and web) and `vite build` succeeds with all patches
applied. **End-to-end verification performed:** with `ALL.diff` applied and the dev stack running,
all four regression suites and `scripts/verify-scan.ts` were executed — every check passes
(`evidence/test-*-after-fix.txt`, `evidence/verify-scan-after-fix.txt`), while the same suites
fail on the unpatched build (`evidence/test-*-before-fix.txt`, `evidence/verify-scan-output.txt`).
The working tree was restored to its original state afterwards.

---

## 1. Verdict

**NOT READY for production or unattended deployment.** The application has a **fail-open
authentication model** (every API route is reachable anonymously, with an `x-role` header
backdoor that grants admin), a **data-destruction bug in spreadsheet import** (wipes the
entire route table on malformed files), and a **shipped default JWT secret** with **no token
expiry**. Scanner status data — the product's core value — reports fabricated latencies and
stale bindings. The UI has no login page, silently fakes an admin session, overflows
horizontally on phone/laptop viewports, and its "24-hour uptime strip" renders as one
stacked column. A consolidated fix exists: **`patches/ALL.diff`** (11 patches, 32 files,
1783 lines), verified against the provided tree; regression tests that **fail before** the
patches and **all pass after** them are in `tests/` (measured: 8/5/5/17 failures before → 0 after).

**Severity counts:** Critical **3** (BUG-001…003), High **16** (BUG-004…017, 054, 063), Medium **30**
(BUG-019…043, 052, 055, 056, 059, 064), Low **14** (BUG-044…051, 053, 057, 058, 060…062),
Improvement **3** — **66 total** (63 bugs + 3 improvements). Note: **BUG-018 is unused**
(IDs are stable references).
**Confirmed: 62 bugs + 3 improvements; Suspected: 1** (BUG-049).
**Patched bugs: 27** across 11 patch files; **36 bugs documented without a standalone patch
file** (fix approach inline, or fixed directly in Phase 2 code). New bugs **055–064** come
from the post-patch full-site UI sweep and the Phase 2 detail-view build (`evidence/ui-sweep/`,
`evidence/phase2/`, §6).

### Top 5 risks (fix first)

1. **Full anonymous takeover of the API** — fail-open auth + `x-role: admin` backdoor + default
   credentials + no rate limit (BUG-001, BUG-004, BUG-003, BUG-008).
2. **Silent data loss** — importing a malformed/empty spreadsheet deletes every route
   (BUG-002), demonstrated 106 → 0 rows on the scratch DB.
3. **Tracked secrets + static signing key** — committed DB dump with password hashes, default
   JWT secret in git, tokens never expire (BUG-009, BUG-003).
4. **Scanner status is unreliable** — fabricated latency on failed probes (19,953 rows),
   one-shot down flips, stale binds shown for dead ports, `$variable` backends probed as real
   hosts (BUG-014…BUG-017). Decisions and alerts built on this data are wrong.
5. **Export produces wrong data** — ignores UI filters, includes archived rows, empty relation
   columns, formula-injection risk (BUG-006, BUG-007).

---

## 2. Critical

### BUG-001 — Authentication is fail-open; `x-role` header backdoor grants admin
- **Severity:** Critical | **Status:** Confirmed
- **Root cause:** `apps/api/src/app.ts:66-78` — the auth hook fails open: any request without a
  cookie is assigned `role: 'admin'` (line 75 via `headerRole || 'admin'`), and the `x-role`
  request header is trusted directly (line 71). No route is actually protected; `/api/docs`
  and `/health` checks aside, all reads AND writes are anonymous (verified pre-patch: GET
  `/api/ports` → 200, `x-role: viewer` → 200, forged cookie → 200, GET `/api/settings` → 200).
- **Fix:** fail-closed `jwtVerify` → 401 on missing/invalid session; ignore `x-role` entirely;
  admin guard for all non-GET mutations plus `/api/settings` and `/api/backup*`; public
  allowlist limited to `/api/auth/login`, `/api/health`, `/api/docs` (live: `/api/health` → 200, `/health` → 404).
- **Patch:** `patches/API-001-app-hardening.diff` — **Patch verified** (`git apply --check` OK).
- **Regression test:** `tests/api-auth.test.mjs` (fails pre-patch: 8 FAIL; passes post-patch).
- **Effort:** S | **Risk:** low (test seam is the `Authorization`/cookie contract; smoke-test
  web login flow after applying).

### BUG-002 — Spreadsheet import destroys the entire route table on malformed files
- **Severity:** Critical | **Status:** Confirmed
- **Root cause:** `apps/api/src/modules/import-export/import-excel.ts:437` —
  `await prisma.route.deleteMany({})` executes **before** the workbook is parsed; any upload
  that parses to zero usable rows still wipes all routes. Additionally the import route is
  reachable anonymously (BUG-001), and a 0-row import returns `Success! Imported 0 routes`
  (`SettingsPage.tsx:164` shows the server-provided counts).
- **Reproduction (performed on scratch DB):** `IMPORT_TEST=1` upload of a garbage workbook →
  routes table 106 → 0, UI reported success.
- **Fix:** parse first; throw `EMPTY_WORKBOOK` guard for 0 rows; scope deletes to
  `deleteMany({ where: { rowNum: { in: [...] } } })` of parsed rows only; phase-based error
  responses (400 for parse problems vs 500 for storage failures) without leaking internals.
- **Patch:** `patches/API-002-import-guard.diff` — **Patch verified**.
- **Regression test:** `tests/api-import-export.test.mjs` (destructive part runs only with
  `IMPORT_TEST=1` against a scratch DB; asserts routes preserved on garbage upload).
- **Effort:** S | **Risk:** low.

### BUG-003 — Shipped default JWT secret, tokens never expire, default credentials
- **Severity:** Critical | **Status:** Confirmed
- **Root cause:**
  - `apps/api/src/config/env.ts:20` — `jwtSecret: process.env.JWT_SECRET || 'super-secret-jwt-key-portwatch-2026-very-secure'`
    (default is in git and in `.env.example`); production never requires a real secret.
  - `apps/api/src/modules/auth/auth.routes.ts:32` — `jwt.sign(...)` without `expiresIn`; cookie
    `maxAge: 86400 * 7` (line 38) is the only limit and is client-revocable, not server-enforced.
    Session logout just clears the cookie; tokens stay valid until forever.
  - `auth.routes.ts:36` — `secure: false` (acceptable only on internal HTTP; documented).
  - Default admin credentials accepted in every environment (no forced password change).
- **Fix:** random 64-hex secret when `NODE_ENV !== 'production'`; production throws at boot if
  `JWT_SECRET` unset; `expiresIn: '8h'` + cookie `maxAge` 8h; compose file requires
  `${JWT_SECRET:?…}`; `.env.example` replaced with an empty placeholder.
- **Patch:** `patches/API-003-auth-credential-hardening.diff` — **Patch verified**
  (env.ts, auth.routes.ts, docker-compose.yml, .env.example).
- **Regression test:** `tests/api-auth.test.mjs` (login contract) + manual: boot without
  `JWT_SECRET` in production mode → must refuse to start.
- **Effort:** S | **Risk:** medium — rotating the secret invalidates existing sessions
  (announce a re-login).

---

## 3. High

### BUG-004 — Viewer role can perform admin mutations
- **Status:** Confirmed | **Root cause:** `apps/api/src/app.ts` registers all routes with no
  role check; the hook only *records* the role (baseline line 75). Verified with a valid
  viewer session: `POST /api/scan/run` → 200, `PATCH /api/settings` → 200,
  `POST /api/issues` → 201, `DELETE /api/saved-views/…` → 500 (route exists, handler error).
- **Fix:** admin guard on every non-GET route + settings/backup reads (viewer/read-only for GET).
- **Patch:** `patches/API-001-app-hardening.diff` — **Patch verified**.
- **Test:** `tests/api-auth.test.mjs` (enable via `VIEWER_COOKIE=…`) | **Effort:** S | **Risk:** low.

### BUG-005 — No login/logout UI; web silently fakes an admin session
- **Status:** Confirmed | **Root cause:** no `/login` route existed; `Header.tsx:16` —
  `'/auth/me').catch(() => ({ role: 'admin', username: 'admin' }))`, and the same
  fail-open fallback exists in 7 files (`IssuesPage.tsx:28`, `SettingsPage.tsx:28`,
  `BackendsPage.tsx:28`, `PortsPage.tsx:91`, `RoutesPage.tsx:35`, `CommandPalette.tsx:40`,
  `Header.tsx:16`); header identity was hard-coded text `admin` (`Header.tsx:143`).
  Every `/auth/me` call returned 401 while the UI displayed admin (pre-patch evidence).
- **Fix:** real `LoginPage` + `/login` route, auth guard redirect, real username from
  `/auth/me`, logout button, fail-closed `{ role: 'viewer', username: 'guest' }` fallbacks.
- **Patches:** `patches/WEB-002-app-shell-errors-login.diff` (new `LoginPage.tsx`,
  `ErrorBoundary.tsx`, `/login` route) + `patches/WEB-003-session-responsive-theme.diff`
  (guard, header, fallbacks) — **both Patch verified**.
- **Test:** `tests/web-ui.test.mjs` ("unauthenticated visit redirects to /login") |
  **Effort:** M | **Risk:** low.

### BUG-006 — Export returns the wrong data (filters ignored, archived rows, blank relations, no BOM, fixed filename, unknown entity 200)
- **Status:** Confirmed | **Root cause:**
  - `PortsPage.tsx:169-171` — `window.open('/api/export?entity=ports&format=…')` discards the
    active URL/search filters; export menu on other pages is missing entirely.
  - `apps/api/src/modules/import-export/import-export.routes.ts:41+` — no
    `archived/q/status/lifecycle` filter handling; relation columns serialized as empty
    objects; `entity` taken as-is (unknown entity → 200 with empty CSV); no UTF-8 BOM;
    `portwatch-ports-2026-10-07.csv` (date only).
  - Evidence: `evidence/export-ports-q443.csv` (1 matching row → 34 rows incl. archived),
    `test-import-export-before-fix.txt` (5 FAIL).
- **Fix:** server-side filters/archived handling, flattened relation headers, entity
  allowlist → 400, UTF-8 BOM, `portwatch-<entity>-YYYY-MM-DD-HHMM.csv`; frontend passes URL
  query to the export URL.
- **Patches:** `patches/API-007-export-correctness.diff` + `WEB-001` (handleExport) — **both Patch verified**.
- **Test:** `tests/api-import-export.test.mjs` | **Effort:** M | **Risk:** low.

### BUG-007 — CSV formula injection in exports
- **Status:** Confirmed | **Root cause:** export writes raw cell values; a title like
  `=HYPERLINK("http://evil","x")` is executed by Excel/LibreOffice on open.
  Evidence: `evidence/export-issues-csv-injection.csv`, `export-issues-injection.xlsx`.
- **Fix:** prefix cells starting with `= + - @ \t \r` with `'`.
- **Patch:** `patches/API-007-export-correctness.diff` — **Patch verified**.
- **Test:** `tests/api-import-export.test.mjs` ("no unescaped formula cells in issues CSV";
  to exercise fully, create an issue whose title starts with `=` first) | **Effort:** S.

### BUG-008 — No login rate limiting; synchronous bcrypt blocks the event loop
- **Status:** Confirmed | **Root cause:** `auth.routes.ts` login handler — no throttle
  (12 rapid failed logins all returned 401 with no 429 — `test-api-auth-before-fix.txt`);
  bcrypt compare is synchronous on the request path (CPU DoS with concurrent logins).
- **Fix:** in-memory sliding-window limit (10 attempts / 15 min per key → 429) + async
  `bcrypt.compare` + generic error text (no user enumeration).
- **Patch:** `patches/API-003-auth-credential-hardening.diff` — **Patch verified**.
- **Test:** `tests/api-auth.test.mjs` ("login rate limit returns 429 within 12 attempts") |
  **Effort:** S | **Risk:** low (in-memory only; note: resets on restart, per-instance).

### BUG-009 — Secret material tracked in git (DB dump with password hashes, example secret)
- **Status:** Confirmed | **Root cause:** `db/backups/backup_before_prompt2.sql` is tracked and
  contains password hashes + session-relevant data; `.env.example` contains the literal default
  JWT secret (see BUG-003).
- **Fix:** **no patch** (history rewrite is a repo decision): `git rm --cached` the dump,
  rotate all credentials that appear in it, purge from history
  (`git filter-repo --path db/backups/backup_before_prompt2.sql --invert-paths`), add
  `db/backups/` to `.gitignore`.
- **Test:** `git log --all -- db/backups/backup_before_prompt2.sql` empty after remediation |
  **Effort:** S (action) / M (history rewrite) | **Risk:** medium (force-push coordination).

### BUG-010 — CORS reflects any origin with credentials; SSE endpoint sent `Access-Control-Allow-Origin: *`
- **Status:** Confirmed | **Root cause:** `app.ts:44` — `origin: true` reflects the request
  origin for any domain (verified pre-patch: `Origin: https://evil.example` echoed back);
  `scan.routes.ts:55` set `Access-Control-Allow-Origin: *` on the SSE stream.
- **Fix:** origin allowlist from `CORS_ORIGINS` env (default `http://localhost:5173,
  http://localhost:4173`), non-listened origins get no CORS headers; `*` removed from SSE.
- **Patches:** `patches/API-001-app-hardening.diff` + `patches/API-006-scan-endpoints.diff` — **both Patch verified**.
- **Test:** `tests/api-auth.test.mjs` (add `Origin: https://evil.example` preflight assert:
  no reflected `ACAO`) | **Effort:** S | **Risk:** low — **deployment note:** must set
  `CORS_ORIGINS` to the real dashboard origin or the web app breaks.

### BUG-011 — Unhandled rejection from `POST /api/scan/run` can crash the API
- **Status:** Confirmed (code path; not force-reproduced) | **Root cause:**
  `apps/api/src/modules/scan/scan.routes.ts:13` — `const resultPromise = opts.scanner.runScan()`
  with no `.catch`; any rejection (DB down, listener failure under BUG-012) becomes an
  unhandled rejection → Node ≥15 exits the process (availability loss).
- **Fix:** `.catch` + per-scan error state surfaced to clients.
- **Patch:** `patches/API-006-scan-endpoints.diff` — **Patch verified**.
- **Test:** manual/chaos — stop PostgreSQL mid-scan, POST `/api/scan/run`, process must stay
  alive and return an error; smoke `scripts/scan-now-check.mjs` (API still up after scan) |
  **Effort:** S.

### BUG-012 — `ss`/`netstat` failure → empty listener map → mass false "down" + auto-resolve storm
- **Status:** Confirmed (code path) | **Root cause:** `apps/api/src/scanner/host-listener.ts:42-43`
  — on `ss`+`netstat` failure it warns and returns partial/empty results; `scanner-service.ts`
  then treats *every* expected port as not listening → one cycle flips ports down and
  auto-resolves their issues; combined with BUG-011 this is also a crash path.
- **Fix:** throw on listener-source failure; scan aborts with a recorded error instead of
  writing mass false state (API-004).
- **Patch:** `patches/API-004-scanner-status-accuracy.diff` — **Patch verified**.
- **Test:** manual — `PATH` without `ss`/`netstat` (or `ss` returning nonzero) → scan must
  abort without status changes; verify DB statuses unchanged | **Effort:** M.

### BUG-013 — Internal errors leaked to clients (Prisma/Zod messages and dumps)
- **Status:** Confirmed | **Root cause:** no `setErrorHandler` in `app.ts` (baseline);
  `POST /api/issues` with a bad body → HTTP 500 carrying Prisma validation internals
  (`test-api-validation-before-fix.txt`: `got 500, leak=true`); list endpoints return raw
  `ZodError` JSON dumps on `?page=abc` style inputs.
- **Fix:** central error handler → generic 500 JSON; all validation failures → 400 with
  `{ error: "Invalid request parameters" }` (5 route files).
- **Patches:** `patches/API-001-app-hardening.diff` (handler) + `patches/API-005-request-validation.diff` — **both Patch verified**.
- **Test:** `tests/api-validation.test.mjs` | **Effort:** S.

### BUG-014 — Latency is recorded for failed probes (fabricated metrics)
- **Status:** Confirmed | **Root cause:** `apps/api/src/scanner/tcp-checker.ts:29,41` —
  `latencyMs = Math.round(performance.now() - startTime)` is stored regardless of connect
  outcome. Evidence `evidence/verify-scan-output.txt`: **19,953 / 19,953 failed checks carry
  non-null `latencyMs`**; up-port latency also includes DNS time (measured `ss` state vs DB).
- **Fix:** `latencyMs: null` whenever the probe fails/times out.
- **Patch:** `patches/API-004-scanner-status-accuracy.diff` — **Patch verified**. Includes
  `db/migrations/003_scanner_status_backfill.sql` (backfills the 27,265 historical failed rows
  that retained fabricated latency — applied to the QA DB during verification).
- **Test:** `scripts/verify-scan.ts` (assert failed checks have null latency) |
  **Effort:** S.

### BUG-015 — Single probe failure flips a port `up → down` (no debounce)
- **Status:** Confirmed (code; no consecutive-failure state exists) | **Root cause:**
  `schema.prisma:66` `Port.status` is a plain string; `scanner-service.ts` writes the last
  probe's result directly — one dropped packet = "down", one success = "up" (flapping in
  `history` and issue auto-resolve, see BUG-032).
- **Fix:** in-memory `failuresBeforeDown = 2` (down only after 2 consecutive failures;
  recovery stays immediate) + expose the state in `known-latency` SSE events.
- **Patch:** `patches/API-004-scanner-status-accuracy.diff` — **Patch verified**.
- **Test:** manual — mock-scanner mode: one failing cycle must NOT flip status; two must |
  **Effort:** S.

### BUG-016 — Stale bind/process/latency shown for dead ports (and in the UI)
- **Status:** Confirmed | **Root cause:** `scanner-service.ts:172-175` — on a down probe the
  previous `listenAddress`/process/pid are re-persisted (`listenAddress: hostInfo ?
  hostInfo.bindAddress : p.listenAddress`). Evidence: **19 ports currently `down` still carry
  a `listenAddress`**, 26 carry `latencyMs`; UI "bind" column displayed that stale value
  (`PortsPage.tsx:785-791` rendered the raw field as if live).
- **Fix:** clear bind/process/pid/latency when a probe fails; UI bind column shows the real
  `listenAddress` when up, "not listening" when down.
- **Patches:** `patches/API-004-scanner-status-accuracy.diff` + `patches/WEB-001-ports-page.diff` — **both Patch verified**.
- **Test:** `scripts/verify-scan.ts` (assert: no down port has bind/latency after one scan) |
  **Effort:** S.

### BUG-017 — `$variable` / unresolved backend hosts are probed as real hosts → `down`
- **Status:** Confirmed | **Root cause:** `scanner-service.ts:210-235` — backend hosts are
  resolved and TCP-probed without checking for the `$` prefix or DNS failure. Evidence:
  backend `$jellyfin (variable)` probed, status `down`, `latencyMs: 1` (must be `unknown`).
- **Fix:** hosts starting with `$` or failing DNS (`ENOTFOUND`/`EAI_AGAIN`) → `status:
  'unknown'`, no probe, no latency.
- **Patch:** `patches/API-004-scanner-status-accuracy.diff` — **Patch verified**.
- **Test:** `scripts/verify-scan.ts` (assert `$…` hosts not probed/marked down) |
  **Effort:** S.

### BUG-054 — Documented setup never applies `db/views.sql` → `v_port_overview` missing on fresh installs → primary ports endpoints 500
- **Status:** Confirmed | **Root cause:** the README quick-start runs only `prisma db push` +
  `npm run seed`; `db push` creates the 20 Prisma tables but cannot create the raw-SQL
  materialized view `v_port_overview` (`db/views.sql`, referenced only in README's tech table).
  **Reproduced:** a fresh `portwatch_test` DB created exactly that way serves
  `GET /api/ports?layer=http&protocol=HTTP` → **HTTP 500** `relation "v_port_overview" does
  not exist` (`42P01`, `ports.routes.ts:210`), breaking the primary Ports page, export,
  lifecycle queries and `npm test` (4/20 fail — `evidence/npm-test-fresh-db.txt`). Together
  with BUG-038 (migration-002 indexes also never applied) the documented install applies
  **none** of the repo's raw SQL artifacts.
- **Fix:** one setup step applying `db/views.sql` + `db/migrations/*.sql` (documented in
  README and wired into `postinstall`/a `setup` script).
- **Patch:** none (docs/setup-flow decision, same as BUG-038).
- **Test:** fresh DB via documented steps → `GET /api/ports` → 200 (view exists);
  `npm test` green on an isolated DB after seeding.
- **Effort:** S | **Risk:** low.

### BUG-063 — Route detail drawer crash: `Cannot read properties of undefined (reading 'action')` — every route row click on Domains & Routes threw a render-time TypeError
- **Status:** Confirmed | **Root cause:** `RoutesPage.tsx` drawer read `routeDetail.route.action`
  (and `routeDetail.route.*` throughout the JSX) while `GET /api/routes/:id` returns the **bare**
  route object — the shape mismatch only surfaced once the drawer was actually clicked; there
  were no loading/error states, so a pending or failed fetch rendered `undefined` directly.
- **Fix:** adapt the drawer to the bare shape (`routeDetail.action`, …), add `retry: 1`, a
  skeleton loading state and an error card with Retry; nginx preview generated client-side via
  `lib/nginx.ts` `buildNginxSnippet(routeDetail)` instead of relying on a server-rendered field.
- **Patch:** none — fixed directly in Phase 2 code (no standalone patch file; `patches/` stays
  consistent with the provided tree).
- **Test:** Playwright `e2e/phase2.spec.ts` — "route row opens detail drawer with nginx preview
  (no crash)" asserts dialog + preview visible and **0 pageerrors** (`evidence/phase2/playwright-phase2.txt`).
- **Effort:** S.

---

## 4. Medium

| ID | Title | Conf./Sus. | Root cause (file:line) | Patch | Test |
|---|---|---|---|---|---|
| BUG-019 | No security headers (CSP, HSTS, X-Frame-Options, nosniff, referrer policy) | Confirmed | `app.ts` (none registered; helmet absent from deps) | API-001 ✔ | `tests/api-auth.test.mjs` (nosniff assert) |
| BUG-020 | `npm audit`: 23 vulnerabilities (3 critical, 10 high, 10 moderate) | Confirmed | `package-lock.json` (esbuild/vite/next-era transitive deps) | none — remediation: `npm audit fix --force` on a branch, re-run build | `npm audit` after upgrade |
| BUG-021 | `?limit=Infinity` / `?page=0` → HTTP 500; `limit` unbounded (DoS via `limit=999999`) | Confirmed | `ports.routes.ts:40-41`, `routes.routes.ts:29-30` — `z.coerce.number()` with no bounds/integer | API-005 ✔ | `tests/api-validation.test.mjs` |
| BUG-022 | Silent mutation failures — 25 `useMutation` calls with no `onError` | Confirmed | App-wide (grep: mutations without `onError`) | WEB-002 ✔ (global `MutationCache.onError` → toast) | manual: stop API, mutate, expect toast |
| BUG-023 | No React error boundary; Dashboard shows an infinite skeleton on API error | Confirmed | `App.tsx` (`<Routes>` unguarded); `DashboardPage.tsx` no `isError` | WEB-002 ✔ | manual: bad `DATABASE_URL` → error card + Retry |
| BUG-024 | Horizontal overflow: all pages @390/768px, /ports + /routes @1366px | Confirmed | `Layout.tsx:73` fixed `pl-64` (256px always reserved) + `.flex-1` content without `min-w-0` (min-content floor from header `w-72` quick-jump chip, SSE chip, wide buttons and tables stretched the page) | WEB-003 ✔ (`pl-0 lg:pl-64`, `min-w-0`, responsive header: quick-jump/SSE hidden below `lg`, button labels collapse to icons) | `tests/web-ui.test.mjs` (17 FAIL pre-fix / ALL PASS post-fix) |
| BUG-025 | Ports table has no pagination — spec requires a 50-row paginated table; rows below viewport unreachable | Confirmed | `PortsPage.tsx` renders `filteredPorts` with no slice; footer absent | WEB-001 ✔ | `tests/web-ui.test.mjs` (pagination footer assert) |
| BUG-026 | 38 unlabelled controls (axe critical `label`/`select-name`) incl. search, selects, port-range inputs — **partially fixed**: WEB-001 cleared /ports (0 remaining there), but **13 instances remain elsewhere**: /routes 4 selects, /issues 3 selects, /port-map 2 selects, /settings 4 number inputs | Confirmed | `PortsPage.tsx` (fixed by WEB-001) + `RoutesPage`/`IssuesPage`/`PortMapPage`/ `SettingsPage` selects/inputs still without `aria-label`/`<label>` | WEB-001 ✔ (Ports only) | `tests/web-ui.test.mjs` + `evidence/ui-sweep/axe-results-patched.json` (`select-name` ×9 nodes, `label` ×4 nodes) |
| BUG-027 | Contrast failures in **both themes** (axe `color-contrast`): Issues badges **4.26:1 light / 4.29:1 dark ×129 nodes in each theme**; light also config-files 49, backends 26, ports 23, routes 3, certificates 2 nodes (originally measured 4.27:1 on `ok`/`slow` badges) | Confirmed | alpha-overlay badges (`bg-primary/20 text-primary`, `bg-status-slow/20 …`) vs `index.css` tokens in both palettes | none — remediation: solid badge colors ≥4.5:1 per theme (or darken the 20%-alpha underlay) | `evidence/ui-sweep/axe-results-patched.json`; ratios captured via axe (`fg #939BF4 / bg #3C3958` = 4.29 dark; `#2F5D50 / #C8C3B8` = 4.26 light) |
| BUG-028 | `grid-cols-24` is not a Tailwind class → "24-hour uptime strip" renders as one stacked column | Confirmed | `PortsPage.tsx:915`; absent from built CSS; computed `589px`, 24 children at 28px each in one column | WEB-001 ✔ (arbitrary `grid-cols-[repeat(24,minmax(0,1fr))]`) | `scripts/gridcheck3.mjs` / screenshot `evidence/port-drawer-uptime-strip.png` |
| BUG-029 | Every filter keystroke pushes a browser-history entry (Back button unusable) | Confirmed | `PortsPage.tsx:161` `setSearchParams(next)` without `{ replace: true }` | WEB-001 ✔ | manual: type in search, press Back |
| BUG-030 | Scanner ignores Settings — scan interval/timeout/concurrency read from env only; UI Settings write DB values nobody reads | Confirmed | `env.ts:25` (`SCAN_INTERVAL_SEC`), `scanner-service.ts:20,29` uses `config.*`; `SettingsPage.tsx:309` writes `scanIntervalSec` → DB via `alerts.routes.ts:94` | none — remediation: load settings at scan start, env as default only | manual: change interval in UI, observe no effect (pre-fix) |
| BUG-031 | Alert Rules (threshold/duration/cooldown/enabled) are never consulted — detector hardcodes everything | Confirmed | `issue-detector.ts` (no settings reads; rules saved by `alerts.routes.ts:94-106` unused) | none — remediation: pass rule config into `IssueDetector.evaluate()` | manual: add a rule, verify it has no effect (pre-fix) |
| BUG-032 | Acknowledged/ignored auto-issues are re-opened on every scan | Confirmed | `issue-detector.ts:31-36` (upsert `update: { status: 'open' }`) + `:289-305` auto-resolve set includes `acknowledged` | none — remediation: never downgrade `acknowledged`/`ignored` → `open` on re-detect | manual: ack an auto issue, run scan |
| BUG-033 | Custom Fields are write-only — created in Settings, never rendered or editable anywhere | Confirmed | `SettingsPage.tsx:560` CRUD exists; no usage in ports/issues/backends views | none — remediation: render + column chooser | manual walkthrough |
| BUG-034 | Saved Views API exists with no UI | Confirmed | `apps/api/src/modules/saved-views/` (routes); no web consumer | none — remediation: UI in table headers | code review |
| BUG-035 | Spec pages missing: Verify-scan page, Users management, Appearance/Theme settings section, export menus outside Ports | Confirmed | no routes/components found (`grep -r "verify-scan" apps/web` → none); Settings tabs = scanner/alerts/features/custom-fields/import-export/audit | none — feature work | coverage matrix (§6) |
| BUG-036 | Theme: no System option (pre-fix); dark palette is slate/indigo, spec asks burgundy | Confirmed | `index.html:14` persisted `dark` only, no `matchMedia`; `index.css` palette | System option → WEB-003 ✔; palette restyle → design decision, remediation | `tests/web-ui` + manual theme cycle |
| BUG-037 | Test suites run against the **live** database — `npm test` left 14 test ports (31500-31505, 31700, e2e leftovers) in production data; 1 e2e test fails, 1 unit test times out; tests are also **data-dependent** (assert ≥18 ports / ≥25 domains / topology edges) so they pass only against production-sized data | Confirmed | `vitest`/`e2e` configs have no DB env isolation; leftovers observed in live DB (cleaned up 2026-10-07 — `evidence/data-counts.txt` — next run re-pollutes); isolated fresh-DB run: 16/20 (overview/topology/lifecycle fail on data volume; `/api/ports` 500 → BUG-054) | none — remediation: force `DATABASE_URL=…portwatch_test` in test setup + seed test data, document in README | `npm test` on fresh CI DB → 0 writes to live DB and green without pre-existing data (`evidence/npm-test-fresh-db.txt`) |
| BUG-038 | Documented setup (`prisma db push`) never applies `db/migrations/002_lifecycle_features.sql` → fresh installs lack `uq_ports_active_port` etc. → duplicate active ports allowed; un-archive has no conflict check (the same gap also skips `db/views.sql` — see BUG-054) | Confirmed | README/package.json reference no migration step; **reproduced on a fresh DB via the documented steps** — `prisma db push` created 20 tables but none of the migration-002 indexes; duplicate active-port insert accepted there while rejected on live DB (`evidence/readme-setup-verification.txt`) | none — remediation: add `prisma migrate deploy`/SQL apply step to README + `postinstall` | fresh DB (documented setup): duplicate active-port insert **accepted**; live DB (migration 002): rejected `uq_ports_active_port` (`evidence/readme-setup-verification.txt`) |
| BUG-039 | API container runs as root | Confirmed | `apps/api/Dockerfile` (no `USER`) | API-009 ✔ | `docker inspect … .Config.User` → `portwatch` |
| BUG-040 | `GET /api/settings` returns live secrets (Telegram bot token, SMTP password, webhook URLs) in the response body | Confirmed | `settings` module serializes raw config | none — remediation: write-only fields (return `***` + `hasValue`), separate PUT semantics | manual: settings GET → masked |
| BUG-041 | Trash restore is lossy — ports restore without their routes; backends/servers have no restore path | Confirmed | ports restore handler restores row only; no re-attach of archived routes | none — remediation: restore graph or explicit partial-restore warning | manual: archive port w/ route → restore → route missing |
| BUG-042 | `listenAddress` is client-writable on `POST /api/ports` (bind spoofing) | Confirmed | `ports.routes.ts` POST accepts `listenAddress` from body | none — remediation: strip/ignore on create, derive from scanner | manual: POST with fake bind → rejected |
| BUG-043 | TLS certificate scan silently covers only the first 20 HTTPS routes; probe errors swallowed | Confirmed | `scanner-service.ts:271` `httpsRoutes.slice(0, 20)`, `:277` empty `catch` | none — remediation: scan all (bounded concurrency), record probe errors as issues | manual: >20 HTTPS routes → all checked |
| BUG-052 | Alert notification **dispatch layer does not exist**: every firing writes an `AlertLog` row with `status: 'simulated'` and nothing is ever sent — webhook/Telegram/SMTP settings are write-only (no code reads them); alert logs are never rendered in the UI; yet `/alerts/test` returns “dispatched successfully” and the Settings page offers a “sample dispatch … across configured channels” (Generic Webhook / Telegram Bot options) | Confirmed | `scanner-service.ts:450` (`status: 'simulated'`), `alerts.routes.ts:54-69` (test endpoint always `simulated`); `slackDiscordWebhook`/`genericWebhook`/`telegramConfig`/`smtpConfig` written by `alerts.routes.ts:117-127`, never read anywhere (`grep -rn "slackDiscordWebhook\|telegramConfig" apps/api/src` → write sites only); no `fetch`/`http.request`/`nodemailer` in `apps/api/src`; web reads only `/alerts/rules` + `/alerts/test` (no `/alerts/logs`) | none — remediation: implement dispatcher per channel (secret storage per BUG-040/020) and honest “simulated” labelling until then | manual: POST `/alerts/test` with `channel: webhook` → 200 “dispatched successfully”, `AlertLog.status='simulated'`, no outbound request |
| BUG-055 | Command Palette results can only be activated by **mouse click**: `Enter` never opens a result and `ArrowDown` does not move focus/selection (focus stays in the text input) — keyboard-only users cannot navigate with the app's primary keyboard launcher | Confirmed | `CommandPalette.tsx` has no selected-index state or `onKeyDown` handling beyond `Escape`; results are plain `div`s without `role="option"`/`aria-activedescendant` | none — remediation: active-index state + arrow highlight + Enter → navigate + `role="listbox"/"option"` | Playwright: Ctrl+K → type `cert` → Enter stays on `/` (also after ArrowDown; 3 attempts), while clicking the same result → `/certificates` (`evidence/ui-sweep/interactive-findings.json`, `palette-search.png`) |
| BUG-056 | Add Port 5-step wizard has **no client-side validation until the final save**: out-of-range port `99999` passes step 1 “Next” and every subsequent step; only `POST /api/ports` rejects it (400) at “Save & Add Another” — the whole wizard input is wasted and the only feedback is a global toast while the modal stays on Review | Confirmed | `AddPortDialog.tsx` performs no range/format checks on step navigation; error surfaces solely through API 400 → `MutationCache` toast | none — remediation: per-step validation mirroring the API rule (1–65535), inline field error, block Next on invalid | Playwright: fill 99999 → 5× Next → Save → toast “Port number must be between 1 and 65535”, `POST /api/ports` 400, modal still open (`evidence/ui-sweep/wizard-400-feedback.png`, `wizard-99999.png`) |
| BUG-059 | Scrollable content panels are not keyboard-focusable — axe `scrollable-region-focusable` (**serious**) on Dashboard (ports-by-layer list), Backends (4 side panels), History timeline: keyboard users cannot scroll these regions | Confirmed | scroll containers (`overflow-y-auto max-h-*`) lack `tabindex="0"`/`role="region"`; pre-existing (present in baseline `axe-results.json`, never recorded until now) | none — remediation: `tabIndex={0}` + labelled `role="region"` on each scrollable panel | `evidence/ui-sweep/axe-results-patched.json` → `scrollable-region-focusable` on 3 pages × both themes |
| BUG-064 | No click-through detail views — Certificates, Config Files and Backends rows/cards open nothing, and Domains has no management at all: no cert expiry detail, no way to view/edit stored nginx config, no backend impact analysis, no per-domain add/delete with confirmation | Confirmed | Phase-2 gaps: `CertificatesPage`/`ConfigFilesPage`/`BackendsPage` tables had no row→drawer wiring; `config_files` had no `content` column or detail endpoint (`config-files.routes.ts` list only); no domain endpoints existed (`modules/domains/` absent); `RoutesPage` domain headers only collapsed — no detail, add-wizard or delete flow | none — fixed directly in Phase 2 code: deep-probe cert drawer (`GET /certificates/:domain`), `004_config_file_content.sql` + full-page nginx viewer with partition sidebar + paste modal, backend impact drawer, new `domains.routes.ts` (list/detail/impact/archive/restore/delete), domain drawer + Add Domain wizard + archive-vs-delete dialog with typed confirmation | `apps/api/tests/phase2.test.ts` (22 tests) + `e2e/phase2.spec.ts` (6 flows) all green (`evidence/phase2/vitest-phase2.txt`, `evidence/phase2/playwright-phase2.txt`) |

---

## 5. Low & Improvements

| ID | Title | Conf./Sus. | Root cause | Patch | Test |
|---|---|---|---|---|---|
| BUG-044 | Manual "Check now" ignores lifecycle gates (updates archived/planned ports) | Confirmed | `scan.routes.ts`/`tcp-checker` target path: no lifecycle guard (issue-detector has one at `issue-detector.ts:20`) | none — reuse lifecycle guard | manual: check archived port → no status change |
| BUG-045 | Command Palette advertises `G ,` shortcut that does nothing | Confirmed | `CommandPalette.tsx` hint text; no key handler | none — implement or remove hint | manual: press `G` `,` |
| BUG-046 | `check:contrast` script validates a stale hard-coded palette (false confidence) | Confirmed | `scripts/color-check` vs actual `index.css` tokens | none — read live CSS vars | `npm run check:contrast` matches axe |
| BUG-047 | README inaccuracies: `agent`/`docker` scanner modes claimed but unimplemented (`SCANNER_MODE=agent|docker` no-op — only `mock` is handled), check scripts (`check:contrast`, `check:no-literals`) not wired into any CI/build (no `.github/` exists), no linter configured at all | Confirmed | `README.md:85-88`; `env.ts:24` types `agent`/`docker` but `host-listener.ts:23` only branches on `mock`; no lint script/eslint config in any `package.json` | none — docs update | doc review + `evidence/project-checks.txt` |
| BUG-048 | Cookie `secure: false` + Swagger UI always exposed | Confirmed | `auth.routes.ts:36`; `app.ts:81-94` unconditionally registers `/api/docs` | none — `secure` from env, gate Swagger behind `ENABLE_DOCS` in prod | manual: prod boot → `/api/docs` 404 |
| BUG-049 | Public-exposure issues inferred from `0.0.0.0` bind alone (no firewall check) — may over-trigger behind NAT/firewalls | Suspected | `issue-detector.ts:215` | none — scope rule or label "informational" | manual: review rule wording |
| BUG-050 | `GET /api/feature-presets` creates missing built-in rows on read (write-on-read; racy under concurrency) | Confirmed | `features.routes.ts:77-91` | none — seed via migration | concurrent GETs → no dup errors |
| BUG-051 | Spreadsheet import is not atomic: ~400 sequential single-row writes with **zero transactions** — crash/timeout mid-import leaves a partially imported workbook | Confirmed | `import-excel.ts:286-596` `importParsedData()` (0 × `$transaction`; server/config/backend/port/route/issue/user/setting upserts run bare); caller `import-export.routes.ts:18` invokes it directly; `route.deleteMany` at `:437` widens the partial-state window | none — remediation: wrap body in `prisma.$transaction(tx => …)` (helpers already take a client param) + batch `createMany` | `IMPORT_TEST=1` with induced mid-import failure → rollback, DB unchanged |
| BUG-053 | Viewer UI gating is inconsistent: global Header **Scan Now** button and Settings scanner-tab **Save Scanner Settings** (plus custom-field add/delete, preset create) are visible and clickable for viewers — only Header “Add Port”, Ports/Routes/Backends/Issues row actions, features-toggle and preset-delete are `!isViewer`-gated | Confirmed | `Header.tsx:19` computes `isViewer` but `:117` renders Scan Now ungated (`handleScanNow` → POST `/scan`); `SettingsPage.tsx:31` has `isViewer` used only at `:469` (features toggle) and `:524` (preset delete) — scanner save `:305`, custom-field/preset mutations `:49-161` ungated; viewer probe (`evidence/ui-console-errors.txt`) shows “Scan Now” + “Save Scanner Settings” rendered for viewer session; pages certificates/history/dashboard/port-map/config-files have 0 `isViewer` checks (no mutations there) | none — wrap remaining mutation controls in `{!isViewer && …}` / `disabled` | viewer login → buttons hidden or disabled; click → no request or 403 toast |
| BUG-057 | Settings **“Save Scanner Settings” gives no success feedback**: `PATCH /api/settings` → 200 but no toast, no inline “Saved” state — user cannot tell whether the change persisted (failures do toast, successes are silent) | Confirmed | `SettingsPage.tsx` scanner save relies on the global `MutationCache.onError` only; no `onSuccess` UI | none — remediation: `onSuccess` toast or transient “Saved ✓” label | Playwright: change value → save → `200 PATCH /api/settings` observed, 0 toasts, no “saved” text (`evidence/ui-sweep/settings-save2.png`) |
| BUG-058 | Fixed-position overlays lack dialog semantics: Add Port wizard (`div.fixed.inset-0`) and port detail drawer (`aside`) have **no `role="dialog"`/`aria-modal`/accessible name, no focus trap**; ESC closes the drawer but **not** the wizard (wizard only via labelled X) — screen readers never announce either as a dialog (axe has no rule for this, so it survived the a11y pass) | Confirmed | `AddPortDialog.tsx` / PortsPage drawer render plain `div`/`aside` overlays | none — remediation: `role="dialog" aria-modal="true" aria-labelledby`, focus trap, ESC closes wizard too | DOM dump while wizard open: `querySelectorAll('[role=dialog]') → 0` (`evidence/ui-sweep/after-add-port-click.png`, `port-drawer.png`) |
| BUG-060 | Heading hierarchy skips levels — axe `heading-order` on Dashboard, Backends, History, Settings: `<h3>` used as the first heading with no preceding `<h2>` (Settings instance added by the settings-tab UI) | Confirmed | page sections start at `h3` styling; pre-existing on /, /backends, /history (baseline `axe-results.json`), unrecorded until now | none — remediation: real `h2` page titles or demote section headings | `evidence/ui-sweep/axe-results-patched.json` → `heading-order` ×8 page/theme rows |
| BUG-061 | Dashboard “Ports by Layer & Protocol” pie chart is inaccessible — axe `svg-img-alt` (serious): recharts `<path>` sectors carry a `name` attribute but no accessible name (`aria-label`/`<title>`), so screen readers get nothing from the chart | Confirmed | recharts sector rendering without title/aria; pre-existing (baseline `axe-results.json`), unrecorded until now | none — remediation: chart-level `role="img"` + summary `aria-label`, per-sector `<title>`, data-table fallback | `evidence/ui-sweep/axe-results-patched.json` → `svg-img-alt` nodes:3 both themes |
| BUG-062 | Login page content sits outside landmarks — axe `landmark-one-main` + `region` (4 nodes): no `<main>` around the form, brand/version sidebar unscoped (introduced with the WEB-002 login page) | Confirmed | `LoginPage.tsx` wrapper has no `<main>`/`<header>` structure | none — remediation: wrap form in `<main>`, chrome in `<header>`/`<nav>` | `evidence/ui-sweep/axe-results-patched.json` → `/login` both themes |
| IMP-001 | Bundle is a single 1.4 MB chunk (`vite build` warns >500 kB) — slow first paint | Confirmed | no route-level code splitting in `App.tsx` | none — `React.lazy` per route | build output <500 kB/chunk |
| IMP-002 | Export menu only appears on hover (discoverability), export exists only on Ports page | Confirmed | `PortsPage.tsx` hover-grouped menu; other pages lack it (see BUG-035) | none — persistent menu button | manual/UX review |
| IMP-003 | Scanner re-upserts every matching auto-issue on **every** scan cycle — 9 sequential rule loops, no batching; `@updatedAt` churned every 30s even when nothing changed | Confirmed | `issue-detector.ts:25-265` (9 `await prisma.issue.upsert` inside `for` loops) called each cycle from `scanner-service.ts:286`; no `$transaction`/`createMany` | none — batch upserts; skip rows whose `observed` text is unchanged | query count per scan via Prisma query log |

**Bugs with no patch (36):** BUG-009, 020, 027, 030, 031, 032, 033, 034, 035, 037, 038, 040,
041, 042, 043, 044, 045, 046, 047, 048, 049, 050, 051, 052, 053, 054, 055, 056, 057, 058, 059,
060, 061, 062, 063, 064 — each row states the fix approach; most need product/ownership
decisions or dependency work beyond a safe minimal patch (055–062 are UI-only fixes found in the
post-patch sweep, recorded without patches so `patches/` stays consistent with the provided
tree; **063–064 are fixed directly in Phase 2 code** and covered by regression tests instead of
a standalone diff). **Patched: 27 bugs** (of 63) across `API-001…API-009`, `WEB-001…WEB-003`;
IMP-001/002/003 also unpatched (see §5).

---

## 6. Coverage matrix

Pages (functional smoke + screenshots at 1920/1366/768/390, dark+light, Chromium+Firefox) — status as found:

| Page | Data/load | Responsive | A11y (axe) | Notes |
|---|---|---|---|---|
| Dashboard | Partial — renders, but error state = infinite skeleton (BUG-023) | Fail @390/768 (BUG-024) | Fail (contrast) | KPI cards OK (`kpi-filter-check.mjs`) |
| Ports | Pass (33 rows) | Fail @390/768/**1366** | Fail (38 labels, contrast) | pagination missing (025), uptime strip broken (028), export filters ignored (006) |
| Routes | Pass | Fail @390/768/1366 | Fail (contrast) | export relation columns blank (006) |
| Backends | Pass | Fail @390/768 (1366 OK) | Fail (contrast) | `$variable` host shows down (017) |
| Issues | Pass | Fail @390/768 (1366 OK) | Fail (contrast) | XSS payload rendered inert ✓ (`xss-issues-dark-1920.png`) |
| Config Files | Pass | Fail @390/768 | Fail (contrast) | — |
| Certificates | Pass | Fail @390/768 | Fail (contrast) | coverage capped at 20 routes (043) |
| Port Map | Pass | Fail @390/768 | Fail (contrast) | — |
| History | Pass | Fail @390/768 | Fail (contrast) | — |
| Settings | Pass (6 tabs) | Fail @390/768 | Fail (contrast) | scanner/alerts config ineffective (030/031); secrets in GET (040) |

Cross-cutting (**state as found, pre-patch** — post-patch results in §9 Re-test checklist and `tests/README.md`):

| Requirement | Status | Evidence / bug |
|---|---|---|
| Login/logout, real identity | **Fail** | BUG-005; `test-web-ui-before-fix.txt` |
| Fail-closed API auth | **Fail** | BUG-001/004; `test-api-auth-before-fix.txt` |
| Role separation (viewer read-only) | **Fail** | BUG-004 (API, patched); UI gating gaps — BUG-053 |
| Rate limiting | **Fail** | BUG-008 |
| Export rules (filters, BOM, injection, filename) | **Fail** | BUG-006/007; `test-import-export-before-fix.txt` |
| Import safety | **Fail** | BUG-002 (destructive, confirmed) |
| Scanner status accuracy (states up/down/slow/unknown) | **Fail** | BUG-014…018; `verify-scan-output.txt` (28/28 state matches vs `ss`, but bind/latency/$-host failures) |
| Lifecycle rules (planned/reserved/maintenance/archived skipped) | **Pass** | `issue-detector.ts:20` skips; archive/undo verified (`after-archive-undo-*.png`) |
| Alerts | **Fail** | BUG-031 (rules unused); dispatch layer absent — BUG-052 |
| Theme dark/light/system + spec palette | Partial | BUG-036; `theme-toggle-after-light-1920.png` |
| Responsive 390/768/1366/1920 | **Fail** | BUG-024 (14 overflow failures: 6 @390, 6 @768, 2 @1366 — `test-web-ui-before-fix.txt`); **post-patch: ALL PASS** |
| Accessibility | **Fail** | BUG-026 (partly fixed — /ports clean), BUG-027 (both themes), BUG-059/060/061/062 — `evidence/ui-sweep/axe-results-patched.json` |
| Full-site UI sweep (post-patch) | **Partial** | 12 routes × 3 viewports: 0 console errors, 0 page errors, 0 horizontal overflow, 0 failed API calls, no stuck loaders (`evidence/ui-sweep/sweep-findings.json`) — but 8 new bugs: BUG-055 palette Enter, 056 wizard validation, 057 silent save, 058 dialog semantics, 059–062 axe residuals |
| KPI correctness | **Pass** | `kpi-filter-check.mjs` |
| Excel ↔ DB parity | **Pass** (row-by-row) | `evidence/compare-excel-vs-db.txt` — all 106 routes, 34 backends, 48 configs, 12 imported issues match Excel; the 2 count mismatches (ports 19→23, issues 12→21) are scratch-DB test pollution: 4 duplicate/unarchive test ports + 9 scanner auto-issues from test scans |
| Saved views | Partial | API only (BUG-034) |
| Verify-scan page / Users / Appearance | **Absent** | BUG-035 |
| Build / typecheck | **Pass** | `tsc` clean; `vite build` OK (chunk warning → IMP-001) |
| Test suites | **Fail** | BUG-037 (`npm test`: e2e 1 failed, unit timeout, live-DB pollution); isolated fresh-DB run 16/20 — data-dependent asserts + BUG-054 (`evidence/npm-test-fresh-db.txt`) |
| Docker | **Review-only** | BUG-039 (root); compose run blocked (§7) |
| Security headers / CORS / secrets | **Fail** | BUG-009/010/019 |

---

## 7. What could not be tested (blocked)

- **WebKit** — `npx playwright install webkit` blocked by missing system dependencies; UI
  verified on Chromium + Firefox only.
- **Docker full stack** — ports 5432/3100 occupied by the running dev stack; Dockerfiles
  reviewed statically (web nginx image still runs as root master — noted, API patched).
- **Real target host (leadowserver)** — this QA ran on the developer machine; `192.168.1.221`
  / `.222` are unreachable from here, so target-server features (`Target Server` switch,
  agent mode) and real-host scanner data could not be validated (agent mode is also
  unimplemented — BUG-047).
- **Notification channels** — no real credentials were available, but code inspection
  supersedes that: dispatch is *unimplemented*, not untested — every channel write is
  `status: 'simulated'` and no outbound sender exists (BUG-052; rule *wiring* is BUG-031).
- **>50-port table pagination performance** — current data has 24 ports (19 active + 5 archived;
test rows created during this QA were cleaned up — see `evidence/data-counts.txt`); code-confirmed only
  (fix shipped in WEB-001 anyway).
- **Unprivileged `ss`** — no sudo, so `ss -tlnpH` lacked process info for some sockets;
  `ss` state comparison (the core of `verify-scan`) was unaffected.
- **Dependency upgrade verification** — BUG-020 remediation not executed (would require a
  full re-test cycle).

---

## 8. Fix plan

| Phase | Content | Patches | Effort |
|---|---|---|---|
| **P0 — stop the bleeding** | Auth fail-open + admin guard (001/004), import wipe (002), secrets + expiry + rate limit (003/008), error handling/leaks (013/021), CORS (010), secret rotation + git purge (009) | API-001, API-002, API-003, API-005 | 1–2 days |
| **P1 — data trust** | Scanner accuracy 014–018, scan crash 011, listener failure 012, export correctness 006/007, SSE 010, non-root 039 | API-004, API-006, API-007, API-009 | 1–2 days |
| **P2 — usable UI** | Login/session 005, errors/toasts 022/023, responsive 024, pagination 025, labels 026, uptime strip 028, history 029, theme System 036 | WEB-001, WEB-002, WEB-003 | 2 days |
| **P3 — product gaps** | Scanner settings wiring 030, alert rules 031, ack durability 032, custom fields 033, saved views 034, spec pages 035, migrations/views setup 038+054, tests isolation 037, contrast 027, deps 020 | none yet (design first) | 1–2 weeks |
| **P4 — polish** | Docs 047, Swagger/cookie 048, low items, bundle split IMP-001 | — | 2–3 days |

Apply with:
```bash
git apply --check qa-report/patches/ALL.diff   # must pass on the tree as provided
git apply qa-report/patches/ALL.diff            # apply everything (or individual patches in order)
```

---

## 9. Re-test checklist (after patches)

1. `git apply --check qa-report/patches/ALL.diff` → OK; `npx tsc --noEmit` (api + web); `npm run build --workspace apps/web`.
2. `node qa-report/tests/api-auth.test.mjs` → all PASS (no `VIEWER_COOKIE` required).
3. `node qa-report/tests/api-validation.test.mjs` → all PASS.
4. `node qa-report/tests/api-import-export.test.mjs` → all PASS; then
   `IMPORT_TEST=1` against a scratch DB → garbage upload preserves routes.
5. `node qa-report/tests/web-ui.test.mjs` → all PASS (login redirect, overflow, labels).
6. Apply `db/migrations/003_scanner_status_backfill.sql`, wait one scan cycle, then
   `npx tsx qa-report/scripts/verify-scan.ts` → 28/28 match + all rules `ok`.
7. Manual: login page → admin login → logout; viewer cookie cannot mutate; origin not reflected; `curl -I` shows security headers; export URL carries current filters; uptime strip renders 24 cells in one row; acknowledge an auto issue → survives a scan (after P3).
8. Fresh DB via documented setup → `db/views.sql` + `db/migrations/*.sql` applied →
   `GET /api/ports` → 200 with `v_port_overview` present (BUG-054) and duplicate-port
   insert rejected (BUG-038); `DATABASE_URL=…portwatch_test npm test` green without
   touching the live DB (BUG-037).

---

## 10. Artifact index

- `patches/` — 11 individual patches + `ALL.diff` (32 files, 1783 lines); all pass `git apply --check`;
  sequential application of all 11 verified in a sandbox repo; `tsc` + `vite build` clean with them applied.
- `tests/` — 4 standalone regression suites + `README.md` (expected FAIL-before / PASS-after matrix).
- `scripts/` — `compare-excel-vs-db.ts`, `verify-scan.ts`, `ui-console-sweep.mjs`,
  `gen-bugs-csv.py` (CSV-from-report generator + consistency assertions),
  `ui-full-sweep.mjs` (routes × viewports console/overflow sweep), `axe-sweep.mjs`
  (all pages × themes), `ui-interactive.mjs` (filters, modals, palette, roles, API-fail),
  axe/overflow/functional/export/XSS/KPI/undo/grid checks.
- `evidence/` — 199 files (67 in `ui-sweep/`): screenshots (all pages × themes × viewports ×
  browsers), `axe-results.json`, `ui-sweep/axe-results-patched.json`,
  `ui-sweep/sweep-findings.json`, `ui-sweep/interactive-findings.json`,
  scanner state before/after (`verify-scan-output.txt`, `verify-scan-after-fix.txt`,
  `verify-scan-baseline-rerun.txt`), test results before/after patches (`test-*-before-fix.txt`
  / `test-*-after-fix.txt`), checklist sweeps (`api-security-sweep.txt`,
  `ui-console-errors.txt`, `data-counts.txt`, `npm-test-fresh-db.txt`, `project-checks.txt`,
  `readme-setup-verification.txt`), `export-issues-csv-injection.csv`,
  `port-drawer-uptime-strip.png`, `pg_dump_before_tests.sql` (pre-test DB dump).
- `bugs.csv` — machine-readable bug list.
