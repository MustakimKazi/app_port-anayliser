import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';
import path from 'path';
import { PrismaClient } from '@prisma/client';

// Load .env
dotenv.config({ path: path.resolve(process.cwd(), '.env') });
dotenv.config({ path: path.resolve(process.cwd(), 'apps/api/.env') });
dotenv.config();

const prisma = new PrismaClient();

async function main() {
  const username = process.env.ADMIN_USERNAME || 'admin';
  const password = process.env.ADMIN_PASSWORD || 'HgkO916f3APE';
  const email = process.env.ADMIN_EMAIL || 'admin@leadowserver.local';

  console.log(`Setting password for user '${username}'...`);
  const hash = bcrypt.hashSync(password, 10);

  const user = await prisma.user.upsert({
    where: { username },
    update: {
      passwordHash: hash,
      role: 'admin'
    },
    create: {
      username,
      passwordHash: hash,
      role: 'admin',
      email
    }
  });

  console.log(`\n✅ Password successfully updated!`);
  console.log(`Username: ${user.username}`);
  console.log(`Password: ${password}`);
  console.log(`Role:     ${user.role}`);
}

main()
  .catch((e) => {
    console.error('❌ Failed to update password:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
