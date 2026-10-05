/** @type {import('tailwindcss').Config} */

function withOpacity(variableName) {
  return ({ opacityValue }) => {
    if (opacityValue !== undefined) {
      return `color-mix(in srgb, var(${variableName}) calc(${opacityValue} * 100%), transparent)`;
    }
    return `var(${variableName})`;
  };
}

export default {
  darkMode: 'class',
  content: [
    './index.html',
    './src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        bg: withOpacity('--bg'),
        surface: {
          DEFAULT: withOpacity('--surface'),
          2: withOpacity('--surface-2'),
        },
        border: {
          DEFAULT: withOpacity('--border'),
          strong: withOpacity('--border-strong'),
        },
        text: {
          DEFAULT: withOpacity('--text'),
          muted: withOpacity('--text-muted'),
        },
        primary: {
          DEFAULT: withOpacity('--primary'),
          foreground: withOpacity('--on-primary'),
        },
        'on-primary': withOpacity('--on-primary'),
        accent: withOpacity('--accent'),
        status: {
          up: withOpacity('--status-up'),
          down: withOpacity('--status-down'),
          slow: withOpacity('--status-slow'),
          unknown: withOpacity('--status-unknown'),
          info: withOpacity('--status-info'),
        },
        action: {
          proxy: withOpacity('--action-proxy'),
          static: withOpacity('--action-static'),
          redirect: withOpacity('--action-redirect'),
          return: withOpacity('--action-return'),
          status: withOpacity('--action-status'),
        },
        priority: {
          high: withOpacity('--priority-high'),
          medium: withOpacity('--priority-medium'),
          low: withOpacity('--priority-low'),
          info: withOpacity('--priority-info'),
        },
        chart: {
          1: withOpacity('--chart-1'),
          2: withOpacity('--chart-2'),
          3: withOpacity('--chart-3'),
          4: withOpacity('--chart-4'),
          5: withOpacity('--chart-5'),
          6: withOpacity('--chart-6'),
          7: withOpacity('--chart-7'),
          8: withOpacity('--chart-8'),
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'Fira Code', 'monospace'],
      },
      animation: {
        'pulse-fast': 'pulse 1.2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      }
    },
  },
  plugins: [],
};
