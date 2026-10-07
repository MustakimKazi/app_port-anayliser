-- Migration 002: Add Port Lifecycle, Soft Delete, Port Features, Presets, and Trash Snapshots

-- 1. Ports Table: Lifecycle and management columns
ALTER TABLE ports ADD COLUMN IF NOT EXISTS "lifecycle" TEXT NOT NULL DEFAULT 'active';
ALTER TABLE ports ADD COLUMN IF NOT EXISTS "lifecycleReason" TEXT;
ALTER TABLE ports ADD COLUMN IF NOT EXISTS "targetDate" TIMESTAMP(3);
ALTER TABLE ports ADD COLUMN IF NOT EXISTS "owner" TEXT;
ALTER TABLE ports ADD COLUMN IF NOT EXISTS "maintenanceFrom" TIMESTAMP(3);
ALTER TABLE ports ADD COLUMN IF NOT EXISTS "maintenanceTo" TIMESTAMP(3);
ALTER TABLE ports ADD COLUMN IF NOT EXISTS "archivedAt" TIMESTAMP(3);
ALTER TABLE ports ADD COLUMN IF NOT EXISTS "archivedBy" TEXT;
ALTER TABLE ports ADD COLUMN IF NOT EXISTS "expectedBind" TEXT;
ALTER TABLE ports ADD COLUMN IF NOT EXISTS "isDocumented" BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE ports ADD COLUMN IF NOT EXISTS "serverId" TEXT REFERENCES servers(id) ON DELETE SET NULL;

-- Drop strict unique constraint on port number so archived ports can be re-added
ALTER TABLE ports DROP CONSTRAINT IF EXISTS ports_port_key;
DROP INDEX IF EXISTS ports_port_key;

-- Partial unique indexes: active ports must be unique
CREATE UNIQUE INDEX IF NOT EXISTS uq_ports_active_port ON ports (port) WHERE "archivedAt" IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_ports_server_port_proto ON ports (COALESCE("serverId", '00000000-0000-0000-0000-000000000000'), port, protocol) WHERE "archivedAt" IS NULL;

-- Lifecycle index
CREATE INDEX IF NOT EXISTS idx_ports_lifecycle ON ports (lifecycle);
CREATE INDEX IF NOT EXISTS idx_ports_archived_at ON ports ("archivedAt");

-- 2. Soft delete columns for routes, backends, servers
ALTER TABLE routes ADD COLUMN IF NOT EXISTS "archivedAt" TIMESTAMP(3);
ALTER TABLE routes ADD COLUMN IF NOT EXISTS "archivedBy" TEXT;
CREATE INDEX IF NOT EXISTS idx_routes_archived_at ON routes ("archivedAt");

ALTER TABLE backends ADD COLUMN IF NOT EXISTS "archivedAt" TIMESTAMP(3);
ALTER TABLE backends ADD COLUMN IF NOT EXISTS "archivedBy" TEXT;
CREATE INDEX IF NOT EXISTS idx_backends_archived_at ON backends ("archivedAt");

ALTER TABLE servers ADD COLUMN IF NOT EXISTS "archivedAt" TIMESTAMP(3);
ALTER TABLE servers ADD COLUMN IF NOT EXISTS "archivedBy" TEXT;
CREATE INDEX IF NOT EXISTS idx_servers_archived_at ON servers ("archivedAt");

-- 3. Port Features Table
CREATE TABLE IF NOT EXISTS port_features (
    id TEXT PRIMARY KEY,
    "portId" TEXT NOT NULL REFERENCES ports(id) ON DELETE CASCADE,
    "featureKey" TEXT NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT true,
    config JSONB NOT NULL DEFAULT '{}'::jsonb,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_port_feature UNIQUE ("portId", "featureKey")
);
CREATE INDEX IF NOT EXISTS idx_port_features_port ON port_features ("portId");
CREATE INDEX IF NOT EXISTS idx_port_features_key ON port_features ("featureKey");

-- 4. Feature Presets Table
CREATE TABLE IF NOT EXISTS feature_presets (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    "isBuiltin" BOOLEAN NOT NULL DEFAULT false,
    features JSONB NOT NULL DEFAULT '{}'::jsonb,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. Trash Snapshots Table (for audit and restorable permanent deletes)
CREATE TABLE IF NOT EXISTS trash_snapshots (
    id TEXT PRIMARY KEY,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "entityName" TEXT NOT NULL,
    data JSONB NOT NULL,
    "deletedBy" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_trash_snapshots_entity ON trash_snapshots ("entityType", "entityId");
CREATE INDEX IF NOT EXISTS idx_trash_snapshots_created ON trash_snapshots ("createdAt");

-- 6. Registry Feature Settings (global feature toggle)
CREATE TABLE IF NOT EXISTS registry_feature_settings (
    key TEXT PRIMARY KEY,
    "globallyEnabled" BOOLEAN NOT NULL DEFAULT true,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
