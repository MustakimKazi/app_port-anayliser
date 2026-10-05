// Contrast Checker script according to WCAG 2.x specification

export interface PaletteTokens {
  bg: string;
  surface: string;
  surface2: string;
  surface3?: string;
  border: string;
  borderStrong: string;
  text: string;
  textMuted: string;
  primary: string;
  onPrimary: string;
  brand?: string;
  onBrand?: string;
  accent: string;
  status: {
    up: string;
    down: string;
    slow: string;
    unknown: string;
    info: string;
  };
}

export const lightTokens: PaletteTokens = {
  bg: '#F4F0E5',
  surface: '#FBF9F3',
  surface2: '#EBE5D6',
  surface3: '#EBE5D6',
  border: '#CFC6AE',
  borderStrong: '#8A8068',
  text: '#2A2418',
  textMuted: '#5E5543',
  primary: '#2F5D50',
  onPrimary: '#FBF9F3',
  accent: '#A8481F',
  status: {
    up: '#2B7A4B',
    down: '#B3372B',
    slow: '#8F5A00',
    unknown: '#6E6656',
    info: '#2A5F8A',
  },
};

export const darkTokens: PaletteTokens = {
  bg: '#21080E',
  surface: '#320B14',
  surface2: '#430F1B',
  surface3: '#531322',
  border: '#531322',
  borderStrong: '#94606F',
  text: '#F4F0E5',
  textMuted: '#CBB4B4',
  primary: '#EFC9A3',
  onPrimary: '#21080E',
  accent: '#F2A0B0',
  status: {
    up: '#6FD09A',
    down: '#FF9A8E',
    slow: '#EDB65A',
    unknown: '#B5A3A3',
    info: '#8EC1EA',
  },
};

function hexToRgb(hex: string): [number, number, number] {
  const clean = hex.replace('#', '');
  const r = parseInt(clean.substring(0, 2), 16);
  const g = parseInt(clean.substring(2, 4), 16);
  const b = parseInt(clean.substring(4, 6), 16);
  return [r, g, b];
}

function channelLuminance(c: number): number {
  const s = c / 255;
  return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4);
}

function relativeLuminance(hex: string): number {
  const [r, g, b] = hexToRgb(hex);
  return 0.2126 * channelLuminance(r) + 0.7152 * channelLuminance(g) + 0.0722 * channelLuminance(b);
}

export function contrastRatio(hex1: string, hex2: string): number {
  const lum1 = relativeLuminance(hex1);
  const lum2 = relativeLuminance(hex2);
  const max = Math.max(lum1, lum2);
  const min = Math.min(lum1, lum2);
  return (max + 0.05) / (min + 0.05);
}

interface CheckResult {
  theme: string;
  foreground: string;
  fgHex: string;
  background: string;
  bgHex: string;
  ratio: number;
  minRatio: number;
  passed: boolean;
}

export function runChecks(): { results: CheckResult[]; passed: boolean } {
  const results: CheckResult[] = [];

  const checkTheme = (themeName: string, t: PaletteTokens) => {
    const fgItems: [string, string][] = [
      ['--text', t.text],
      ['--text-muted', t.textMuted],
      ['--primary', t.primary],
      ['--accent', t.accent],
      ['status.up', t.status.up],
      ['status.down', t.status.down],
      ['status.slow', t.status.slow],
      ['status.unknown', t.status.unknown],
      ['status.info', t.status.info],
    ];

    if (themeName === 'Dark' && t.surface3) {
      // Dark theme: check all 9 fgItems on all 4 burgundy backgrounds
      const bgSurfaces: [string, string][] = [
        ['--bg', t.bg],
        ['--surface', t.surface],
        ['--surface-2', t.surface2],
        ['--surface-3', t.surface3],
      ];

      for (const [fgName, fgHex] of fgItems) {
        for (const [bgName, bgHex] of bgSurfaces) {
          const ratio = contrastRatio(fgHex, bgHex);
          results.push({
            theme: themeName,
            foreground: fgName,
            fgHex,
            background: bgName,
            bgHex,
            ratio,
            minRatio: 4.5,
            passed: ratio >= 4.5,
          });
        }
      }

      // --on-primary on --primary >= 4.5:1
      const onPrimaryRatio = contrastRatio(t.onPrimary, t.primary);
      results.push({
        theme: themeName,
        foreground: '--on-primary',
        fgHex: t.onPrimary,
        background: '--primary',
        bgHex: t.primary,
        ratio: onPrimaryRatio,
        minRatio: 4.5,
        passed: onPrimaryRatio >= 4.5,
      });

      // --border-strong >= 3:1 on --bg, --surface, and --surface-2
      const borderSurfaces: [string, string][] = [
        ['--bg', t.bg],
        ['--surface', t.surface],
        ['--surface-2', t.surface2],
      ];

      for (const [bgName, bgHex] of borderSurfaces) {
        const ratio = contrastRatio(t.borderStrong, bgHex);
        results.push({
          theme: themeName,
          foreground: '--border-strong',
          fgHex: t.borderStrong,
          background: bgName,
          bgHex,
          ratio,
          minRatio: 3.0,
          passed: ratio >= 3.0,
        });
      }
    } else {
      // Light theme: keep light-theme checks as they are
      const bgSurfaces: [string, string][] = [
        ['--bg', t.bg],
        ['--surface', t.surface],
      ];

      for (const [fgName, fgHex] of fgItems) {
        for (const [bgName, bgHex] of bgSurfaces) {
          const ratio = contrastRatio(fgHex, bgHex);
          results.push({
            theme: themeName,
            foreground: fgName,
            fgHex,
            background: bgName,
            bgHex,
            ratio,
            minRatio: 4.5,
            passed: ratio >= 4.5,
          });
        }
      }

      const onPrimaryRatio = contrastRatio(t.onPrimary, t.primary);
      results.push({
        theme: themeName,
        foreground: '--on-primary',
        fgHex: t.onPrimary,
        background: '--primary',
        bgHex: t.primary,
        ratio: onPrimaryRatio,
        minRatio: 4.5,
        passed: onPrimaryRatio >= 4.5,
      });

      for (const [bgName, bgHex] of bgSurfaces) {
        const ratio = contrastRatio(t.borderStrong, bgHex);
        results.push({
          theme: themeName,
          foreground: '--border-strong',
          fgHex: t.borderStrong,
          background: bgName,
          bgHex,
          ratio,
          minRatio: 3.0,
          passed: ratio >= 3.0,
        });
      }

      const textOnSurface2 = contrastRatio(t.text, t.surface2);
      results.push({
        theme: themeName,
        foreground: '--text',
        fgHex: t.text,
        background: '--surface-2',
        bgHex: t.surface2,
        ratio: textOnSurface2,
        minRatio: 4.5,
        passed: textOnSurface2 >= 4.5,
      });

      const mutedOnSurface2 = contrastRatio(t.textMuted, t.surface2);
      results.push({
        theme: themeName,
        foreground: '--text-muted',
        fgHex: t.textMuted,
        background: '--surface-2',
        bgHex: t.surface2,
        ratio: mutedOnSurface2,
        minRatio: 4.5,
        passed: mutedOnSurface2 >= 4.5,
      });
    }
  };

  checkTheme('Light', lightTokens);
  checkTheme('Dark', darkTokens);

  const passed = results.every((r) => r.passed);
  return { results, passed };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const { results, passed } = runChecks();

  console.log('| Theme | Foreground | Hex | Background | Hex | Contrast Ratio | Min Required | Status |');
  console.log('|---|---|---|---|---|---|---|---|');
  for (const r of results) {
    const status = r.passed ? 'PASS' : 'FAIL';
    console.log(
      `| ${r.theme} | ${r.foreground} | \`${r.fgHex}\` | ${r.background} | \`${r.bgHex}\` | **${r.ratio.toFixed(2)} : 1** | ${r.minRatio} : 1 | ${status} |`
    );
  }

  if (!passed) {
    console.error('\nContrast checks FAILED!');
    process.exit(1);
  } else {
    console.log('\nAll contrast checks PASSED successfully!');
  }
}
