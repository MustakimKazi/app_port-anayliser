# README setup verification (2026-10-07T08:05:39Z)

== Step: DATABASE_URL=...portwatch_readme npm run prisma:push ==
20 tables created
migration 002 indexes ABSENT: uq_ports_active_port, uq_ports_server_port_proto, idx_ports_lifecycle, idx_ports_archived_at, ...

== Step: npm run seed ==

> portwatch@1.0.0 seed
> tsx scripts/seed.ts

Reading seed Excel file: /home/leadows/Downloads/app_port-anayliser/nginx_documentation.xlsx
Parsing workbook...
Parsed entities:
  Config Files: 48
  Port Summary: 19
  Backends: 34
  Domain Map Routes: 106
  Issues & Checks: 12
Importing into PostgreSQL database...

--- Seed Complete! ---
Servers in DB:      5
Config Files in DB: 48
Backends in DB:     34
Ports in DB:        19
Routes in DB:       106
Issues in DB:       12

== BUG-038 A/B: duplicate active port ==
fresh DB (documented setup):  INSERT 0 2  <- duplicates ACCEPTED
live DB (migration 002):      ERROR: duplicate key value violates unique constraint "uq_ports_active_port"

== Health ==
/api/health -> 200 ; /health -> 404
== .env.example vs config/env.ts keys: all covered ==
== docker-compose.yml ports: db 5432 / api 3100 / web 3150 (matches README) ==
== CI: no .github/ (check scripts not wired anywhere) ==
