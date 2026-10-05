import dotenv from 'dotenv';
import path from 'path';

// Load .env from candidate paths (cwd, parent dirs)
dotenv.config({ path: path.resolve(process.cwd(), '.env') });
dotenv.config({ path: path.resolve(process.cwd(), '../../.env') });
dotenv.config();

// Ensure process.env.DATABASE_URL is explicitly set for Prisma
const defaultDbUrl = 'postgresql://postgres:postgres@localhost:5432/portwatch?schema=public';
if (!process.env.DATABASE_URL) {
  process.env.DATABASE_URL = defaultDbUrl;
}

export const config = {
  port: parseInt(process.env.PORT || '3100', 10),
  host: process.env.HOST || '0.0.0.0',
  nodeEnv: process.env.NODE_ENV || 'development',
  databaseUrl: process.env.DATABASE_URL,
  jwtSecret: process.env.JWT_SECRET || 'super-secret-jwt-key-portwatch-2026-very-secure',
  adminUsername: process.env.ADMIN_USERNAME || 'admin',
  adminPassword: process.env.ADMIN_PASSWORD || 'admin',
  adminEmail: process.env.ADMIN_EMAIL || 'admin@leadowserver.local',
  scannerMode: (process.env.SCANNER_MODE || 'host') as 'host' | 'agent' | 'mock' | 'docker',
  scanIntervalSec: parseInt(process.env.SCAN_INTERVAL_SEC || '30', 10),
  tcpTimeoutMs: parseInt(process.env.TCP_TIMEOUT_MS || '3000', 10),
  slowThresholdMs: parseInt(process.env.SLOW_THRESHOLD_MS || '1500', 10),
  concurrencyLimit: parseInt(process.env.CONCURRENCY_LIMIT || '20', 10),
  retentionDays: parseInt(process.env.RETENTION_DAYS || '90', 10),
};
