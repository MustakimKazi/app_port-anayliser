import * as path from 'path';
import * as fs from 'fs';
import * as xlsx from 'xlsx';
import { PrismaClient } from '@prisma/client';
import { parseWorkbook, importParsedData } from './import-excel.js';

const prisma = new PrismaClient();

async function main() {
  const filePath = path.resolve(process.cwd(), 'nginx_documentation.xlsx');
  if (!fs.existsSync(filePath)) {
    console.error(`Error: File not found at ${filePath}`);
    process.exit(1);
  }

  console.log(`Reading seed Excel file: ${filePath}`);
  const wb = xlsx.readFile(filePath);

  console.log('Parsing workbook...');
  const parsed = parseWorkbook(wb);

  console.log(`Parsed entities:`);
  console.log(`  Config Files: ${parsed.configFiles.length}`);
  console.log(`  Port Summary: ${parsed.ports.length}`);
  console.log(`  Backends: ${parsed.backends.length}`);
  console.log(`  Domain Map Routes: ${parsed.routes.length}`);
  console.log(`  Issues & Checks: ${parsed.issues.length}`);

  console.log('Importing into PostgreSQL database...');
  const result = await importParsedData(prisma, parsed);

  console.log('\n--- Seed Complete! ---');
  console.log(`Servers in DB:      ${result.serversCount}`);
  console.log(`Config Files in DB: ${result.configFilesCount}`);
  console.log(`Backends in DB:     ${result.backendsCount}`);
  console.log(`Ports in DB:        ${result.portsCount}`);
  console.log(`Routes in DB:       ${result.routesCount}`);
  console.log(`Issues in DB:       ${result.issuesCount}`);

  if (result.warnings.length > 0) {
    console.log('\nWarnings:');
    result.warnings.forEach(w => console.log(' - ' + w));
  }
}

main()
  .catch(err => {
    console.error('Seed error:', err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
