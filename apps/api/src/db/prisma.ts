import { PrismaClient } from '@prisma/client';
import { config } from '../config/env.js';

export const prisma = new PrismaClient({
  datasources: {
    db: {
      url: config.databaseUrl,
    },
  },
  log: config.nodeEnv === 'development' ? ['error', 'warn'] : ['error'],
});

export default prisma;
