# Changelog

All notable changes to the **PortWatch** project are documented in this file.

## [1.0.0] - 2026-10-05

### Added
- **Initial Production Release of PortWatch**: Production-grade server port and route monitoring dashboard for Linux/Nginx.
- **Repeatable Excel Seeder**: Automated parser importing `nginx_documentation.xlsx` into PostgreSQL with exact counts:
  - 106 routes (proxy, static, redirect, return, status)
  - 19 ports (13 HTTP + 6 TCP stream ports)
  - 34 backends with server cluster associations
  - 48 config files (including detection of 10 inactive backup files)
  - 12 issues with resolution commands
- **Pluggable Scanner Engine**:
  - Direct host `ss -tlnpH` / `netstat` socket reader
  - Concurrent TCP connect prober with latency tracking
  - HTTP/HTTPS SNI prober with slow threshold detection (>1500ms)
  - TLS certificate expiration detector (30/14/7 days warnings)
  - Auto-issue creator and auto-resolver for duplicate ports, rogue ports, public database ports, and unencrypted web ports.
- **Interactive UI with Dark SaaS Theme**:
  - Live KPI cards and Recharts analytics (Donut, Bar, Area charts)
  - Searchable, filterable, multi-sortable Ports table with URL state persistence
  - Row slide-over drawer with 24h uptime bar, route mappings, and check history
  - Ingress routing table with Group-by-Domain view and Nginx snippet generator
  - Server cluster manager with rename capability and blast radius dependency impact analysis
  - Issues Kanban board and workflow manager with syntax-highlighted terminal commands
  - Port Map heat strip and interactive "Find Free Port" discovery tool
  - Global `Cmd+K` command palette and single-key navigation shortcuts
  - Real-time Server-Sent Events (SSE) stream for live updates without page refreshes
  - Custom Fields Manager for zero-code dynamic schema extensions
  - Full system JSON database backup and CSV/XLSX/JSON table exports.
- **Docker Compose Deployment**:
  - Production-ready `db` (Postgres 16), `api` (Fastify Node 20), and `web` (Nginx SPA) containers with healthchecks.
- **Test Suite**:
  - Vitest parser unit tests and API integration tests
  - Playwright E2E test suite.
