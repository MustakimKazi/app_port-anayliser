#!/usr/bin/env bash
#
# PortWatch — database restore helper (run on the TARGET server)
#
# Completes a deployment to another machine: loads a dump created by
# scripts/db-dump.sh into the local PostgreSQL (16 or 18).
#
# USAGE
#   ./scripts/db-restore.sh db/backups/portwatch_20261008_130000.dump
#
# PREREQUISITES on the new server:
#   sudo apt install postgresql-18
#   sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
#   npm install && npm run db:restore -- <dump>   (or call this script directly)
#
set -euo pipefail
cd "$(dirname "$0")/.."

DUMP="${1:?Usage: ./scripts/db-restore.sh <dump-file>}"
[ -f "$DUMP" ] || { echo "ERROR: dump file not found: $DUMP" >&2; exit 1; }

DB_URL="${DATABASE_URL:-}"
if [ -z "$DB_URL" ] && [ -f .env ]; then
  DB_URL="$(grep -E '^DATABASE_URL=' .env | head -1 | cut -d= -f2- | tr -d '"' | tr -d "'")"
fi
DB_URL="${DB_URL:-postgresql://postgres:postgres@localhost:5432/portwatch}"
DB_URL="${DB_URL%%\?*}"
DB_URL="${DB_URL%/}"

# Derive target database name and a maintenance connection (the target DB
# itself may not exist yet on a fresh server).
DB_NAME="${DB_URL##*/}"
MAINT_URL="$(printf '%s' "$DB_URL" | sed 's|/[^/]*$|/postgres|')"

if ! psql "$MAINT_URL" -tAc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1; then
  echo "Creating database $DB_NAME ..."
  psql "$MAINT_URL" -c "CREATE DATABASE \"$DB_NAME\""
fi

echo "Restoring $DUMP -> $DB_NAME ..."
pg_restore -d "$DB_URL" --clean --if-exists --no-owner "$DUMP"
echo
echo "Done. Verify counts, then start the app:  pm2 start ecosystem.config.cjs"
