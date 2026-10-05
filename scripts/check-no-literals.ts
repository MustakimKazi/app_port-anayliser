import fs from 'fs';
import path from 'path';

const SRC_DIR = path.resolve(process.cwd(), 'apps/web/src');
const HTML_FILE = path.resolve(process.cwd(), 'apps/web/index.html');

// Allowed files where tokens or raw SVGs may define colors:
// 1. index.css (the token definition file)
// 2. favicon.svg (and any logo SVG file)
const ALLOWED_FILES = [
  path.resolve(SRC_DIR, 'index.css'),
  path.resolve(process.cwd(), 'apps/web/public/favicon.svg'),
];

// Patterns that indicate hardcoded colors or default Tailwind palette
const COLOR_PATTERNS = [
  /#[0-9a-fA-F]{3,8}\b/g,
  /\brgba?\([^)]+\)/g,
  /\bhsla?\([^)]+\)/g,
  /\b(?:bg|text|border|ring|fill|stroke|from|to|via)-(?:white|black|gray|slate|zinc|neutral|stone|blue|indigo|red|green|amber|yellow|emerald|rose|purple|teal)(?:-[0-9]{2,3})?(?:\/[0-9]+)?\b/g,
];

function scanFile(filePath: string): Array<{ line: number; match: string; lineContent: string }> {
  if (ALLOWED_FILES.includes(filePath)) {
    return [];
  }

  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');
  const violations: Array<{ line: number; match: string; lineContent: string }> = [];

  lines.forEach((lineContent, idx) => {
    // Ignore comments if any
    const trimmed = lineContent.trim();
    if (trimmed.startsWith('//') || trimmed.startsWith('/*') || trimmed.startsWith('*')) {
      return;
    }

    for (const pattern of COLOR_PATTERNS) {
      pattern.lastIndex = 0;
      let match: RegExpExecArray | null;
      while ((match = pattern.exec(lineContent)) !== null) {
        violations.push({
          line: idx + 1,
          match: match[0],
          lineContent: trimmed,
        });
      }
    }
  });

  return violations;
}

function walkDir(dir: string, fileList: string[] = []): string[] {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      walkDir(fullPath, fileList);
    } else if (/\.(tsx?|jsx?|css|html)$/.test(file)) {
      fileList.push(fullPath);
    }
  }
  return fileList;
}

function run() {
  const allFiles = [...walkDir(SRC_DIR), HTML_FILE];
  let totalViolations = 0;
  const fileViolations: Record<string, Array<{ line: number; match: string; lineContent: string }>> = {};

  for (const f of allFiles) {
    const v = scanFile(f);
    if (v.length > 0) {
      fileViolations[f] = v;
      totalViolations += v.length;
    }
  }

  const fileCount = Object.keys(fileViolations).length;
  if (totalViolations > 0) {
    console.error(`Found ${totalViolations} color literals / default palette colors across ${fileCount} files:\n`);
    for (const [file, list] of Object.entries(fileViolations)) {
      const rel = path.relative(process.cwd(), file);
      console.error(`--- ${rel} (${list.length}) ---`);
      list.slice(0, 5).forEach((item) => {
        console.error(`  Line ${item.line}: found "${item.match}" in: ${item.lineContent}`);
      });
      if (list.length > 5) {
        console.error(`  ... and ${list.length - 5} more`);
      }
    }
    console.error(`\nTotal hard-coded color occurrences: ${totalViolations}`);
    process.exit(1);
  } else {
    console.log('No color literals or default Tailwind palette colors found! Clean check.');
  }
}

run();
