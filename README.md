# PortWatch — Server Port & Route Monitoring Dashboard

> **Security Notice**: PortWatch exposes internal server networking topology, listening ports, reverse-proxy routes, and upstream application backends. It is designed for system administrators and DevOps engineers. Always deploy behind an authenticated VPN, WireGuard tunnel, or IP allow-list.

---

## 1. Overview

**PortWatch** is a production-grade operations and monitoring platform that continuously inspects your Linux server and Nginx reverse proxy. It provides a single, real-time pane of glass into:

- **Active Listening Ports**: Which TCP ports are bound (`0.0.0.0` public vs. `127.0.0.1` local) and which processes (PID & command) own each socket.
- **Routing & Upstreams**: The mapping of ingress domains, URL paths, and protocols to internal upstream backends.
- **Health & Latency**: Real-time TCP and HTTP/HTTPS health checks with response latency and 24-hour uptime timelines.
- **Automated Configuration Audit**: Automatic discovery of duplicate port mappings (e.g. 8080 and 9000), rogue/undocumented listening ports, publicly exposed database ports (Redis/MongoDB), and plain-HTTP public endpoints.
- **Interactive Topology & Blast Radius**: Interactive dependency graph linking Domain → Ingress Port → Backend Node, with an instant impact calculator ("if backend `10.0.0.100:8090` goes down, these 5 domains fail").

---

## 2. 5-Minute Quick Start

### Option A: Running with pm2 (Recommended)

1. **Clone the repository and copy the environment file**:

   ```bash
   cp .env.example .env
   ```

2. **Install PostgreSQL 18 and create the database** (native, no Docker):

   ```bash
   sudo apt install postgresql-18
   sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
   sudo -u postgres createdb portwatch
   ```

3. **Install dependencies, sync the database, build**:

   ```bash
   npm install
   npm run prisma:push
   npm run seed
   npm run build
   ```

4. **Start API + Web with pm2**:

   ```bash
   npm i -g pm2
   pm2 start ecosystem.config.cjs
   pm2 save
   pm2 startup                        # prints the systemd enable command (run it once)
   sudo loginctl enable-linger $USER   # start pm2 at boot without login
   ```

5. **Access PortWatch**:
   - **Web UI**: [http://localhost:3150](http://localhost:3150) (or `http://localhost:5173` in local dev mode)
   - **REST API**: [http://localhost:3100](http://localhost:3100)
   - **Interactive OpenAPI / Swagger**: [http://localhost:3100/api/docs](http://localhost:3100/api/docs)
   - **Default Admin**: `admin` / `admin` (change immediately in production via `.env`)

---

### Option B: Running Locally for Development

1. **Start the PostgreSQL database** (native — install steps as in Option A):

   ```bash
   systemctl status postgresql    # must be active on localhost:5432
   ```

2. **Install dependencies and sync database**:

   ```bash
   npm install
   npm run prisma:push
   npm run seed
   ```

3. **Start the API and Web applications concurrently**:
   ```bash
   npm run dev
   ```

   > Note: `npm run dev` binds the API to port `3100`. Stop the pm2 `portwatch-api`
   > process first (`pm2 stop portwatch-api`) if it is running.

---

### Deploying to Another Server (database dump & restore)

You plan to deploy PortWatch somewhere else — the included dump helpers make
the database portable. They create a single `.dump` file with the full
`portwatch` schema and data (ports, routes, config files, users, audit
history), which you can copy to the new host and load there:

```bash
# 1. On the CURRENT server — create a portable dump of the portwatch database
npm run db:dump
#    -> db/backups/portwatch_<timestamp>.dump
#    (custom path: ./scripts/db-dump.sh /path/custom-name.dump)

# 2. Copy the dump and your .env to the new server
scp db/backups/portwatch_*.dump .env user@new-server:/opt/portwatch/

# 3. On the NEW server — install PostgreSQL 18, then restore
sudo apt install postgresql-18
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
cd /opt/portwatch && npm install
npm run db:restore -- db/backups/portwatch_<timestamp>.dump

# 4. Build and start the app on the new server
npm run prisma:generate && npm run build
pm2 start ecosystem.config.cjs && pm2 save
```

Both scripts read `DATABASE_URL` from your `.env` (the Prisma `?schema=…`
suffix is stripped automatically for `pg_dump`/`pg_restore`), and the restore
script creates the `portwatch` database if it does not exist yet.

---

## 3. Architecture & Tech Stack

| Layer               | Technologies                                                                                                                  |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Database**        | PostgreSQL 18, Prisma ORM, materialized SQL view `v_port_overview`, time-series `port_checks`                                 |
| **Backend API**     | Node.js 22, TypeScript, Fastify, Zod validation, `@fastify/swagger` OpenAPI, `@fastify/cookie`, `@fastify/jwt`                |
| **Realtime**        | Server-Sent Events (SSE) broadcasting live status changes and scan progress                                                   |
| **Frontend**        | React 18, TypeScript, Vite, Tailwind CSS, TanStack Table v8, TanStack Query v5, Recharts, Lucide Icons                        |
| **Network Scanner** | Pluggable prober: safe host `ss -tlnpH` socket inspector, concurrent TCP prober, SNI-enabled HTTPS prober, TLS cert inspector |

---

## 4. Architectural Decisions & Defaults

Where the specification allowed design flexibility, the following professional defaults were implemented:

1. **Port Summary Row Count**: While the prompt overview mentioned "18 rows", the actual attached `nginx_documentation.xlsx` contains 19 rows (13 HTTP ports + 6 Stream TCP ports: 7001-7003 for Redis, 60007-60009 for Mongo). The parser faithfully imports all 19 ports.
2. **Polymorphic Time-Series Checks (`port_checks`)**: To support high-throughput continuous probing without foreign key contention across different tables (ports vs. backends vs. routes), `port_checks` uses `(target_type, target_id)` with composite B-tree indexes and a 90-day automated rolling purge job.
3. **Pluggable Scanner Modes (`SCANNER_MODE`)**:
   - `host` (default): Executes `ss -tlnpH` directly with safe parameter arrays (no shell interpolation) to read real Linux socket state and PID owners.
   - `mock`: Simulates host sockets for isolated container demos or local non-Linux environments.
   - `agent`: Allows calling an external agent endpoint when running within hardened container networks.
4. **Port Allocation**: Web UI runs on port `5173` (dev) / `3150` (pm2) and API runs on port `3100` to avoid conflict with existing host services (such as other apps on 3000, 3001, etc.).
5. **Zero-Code Custom Fields**: Custom fields created by administrators are stored with metadata in `custom_fields` and values in `custom_field_values` (and indexed `custom_values` JSONB), automatically surfacing across tables, filters, drawers, and exports.

---

## 5. Seed Data Import & Export

### Repeatable Seed Script

The command `npm run seed` executes `scripts/seed.ts`, which parses `nginx_documentation.xlsx` and upserts records into PostgreSQL:

- **106 Ingress Routes** (domain, paths array, proxy target, static root, redirect code, websocket/ratelimit flags)
- **19 Listening Ports** (HTTP & Stream TCP layers, purpose, process ownership)
- **34 Upstream Backends** (host, port, assigned routes, and server cluster link)
- **48 Configuration Files** (identifying 10 inactive backup `.bak` / `.save` files)
- **12 Initial Health Checks & Conflict Issues** (with copy-paste bash verification commands)

### UI Import & Export

- **Import**: Navigate to **Settings > Import / Export** to drag-and-drop any updated `.xlsx` or `.csv` workbook.
- **Export**: Export any filtered view on the Ports or Routes page to **CSV**, **Excel (.xlsx)**, or **JSON**.
- **System Backup**: Download a full JSON snapshot of all database entities via **Settings > Download Backup**.

---

## 6. Testing

The project includes unit tests, integration tests, and Playwright end-to-end tests:

```bash
# Run Vitest parser unit tests and API integration tests
npm test

# Run Playwright E2E browser tests
npx playwright test
```

---

## 7. Keyboard Shortcuts & Global UX

- `⌘K` or `Ctrl+K`: Open the Command Palette to instantly jump to any port (`:443`), domain, or page.
- `/`: Focus search input.
- `G` followed by `D`: Jump to Dashboard.
- `G` followed by `P`: Jump to Ports.
- `G` followed by `R`: Jump to Routes.
- `G` followed by `B`: Jump to Backends.
- `G` followed by `I`: Jump to Issues.
- `Esc`: Close any open drawer, modal, or command palette.

---

## 8. License

Internal Operations & Infrastructure Tool — MIT License.
