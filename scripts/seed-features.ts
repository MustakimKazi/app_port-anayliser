import prisma from '../apps/api/src/db/prisma.js';
import { seedBuiltinPresets, backfillPortFeatures } from '../apps/api/src/features/presets.js';

async function main() {
  console.log('Seeding built-in feature presets...');
  await seedBuiltinPresets(prisma);
  console.log('Backfilling default port features for existing ports...');
  await backfillPortFeatures(prisma);
  console.log('Features seed and backfill complete!');
  await prisma.$disconnect();
}

main().catch(err => {
  console.error('Seed features failed:', err);
  process.exit(1);
});
