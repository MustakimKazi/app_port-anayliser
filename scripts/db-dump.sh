#!/usr/bin/env bash
#
# PortWatch — database dump helper
#
# WHY THIS EXISTS
# ---------------
# You plan to deploy PortWatch on another server. To move the data there,
# run this script on the CURRENT machine, copy the generated .dump file
# (together with your .env) to the new host, and load it there with
# scripts/db-restore.sh. No Docker required — plain pg_dump/pg_restore.
#
# USAGE
#   ./scripts/db-dump.sh                    # -> db/backups/portwatch_<timestamp>.dump
#   ./scripts/db-dump.sh /path/out.dump     # custom output file
#   DATABASE_URL=... ./scripts/db-dump.sh   # override connection (defaults to .env / local)
#
# SEE ALSO: scripts/db-restore.sh (run on the target server)
#
set -euo pipefail
cd "$(dirname "$0")/.."   # repo root

# Prefer explicit DATABASE_URL, else read it from .env, else local default.
DB_URL="${DATABASE_URL:-}"
if [ -z "$DB_URL" ] && [ -f .env ]; then
  DB_URL="$(grep -E '^DATABASE_URL=' .env | head -1 | cut -d= -f2- | tr -d '"' | tr -d "'")"
fi
DB_URL="${DB_URL:-postgresql://postgres:postgres@localhost:5432/portwatch}"
# Strip Prisma-style query suffix (e.g. ?schema=public) — libpq rejects it.
DB_URL="${DB_URL%%\?*}"

OUT="${1:-db/backups/portwatch_$(date +%Y%m%d_%H%M%S).dump}"
mkdir -p "$(dirname "$OUT")"

echo "Dumping database -> $OUT"
pg_dump -Fc --no-owner "$DB_URL" -f "$OUT"
ls -la "$OUT"
echo
echo "Done. To deploy elsewhere:"
echo "  1. copy $OUT and .env to the new server"
echo "  2. on the new server run:  ./scripts/db-restore.sh $OUT"
