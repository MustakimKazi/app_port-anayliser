import React, { useState, useEffect } from 'react';
import { Search, RefreshCw, Sun, Moon } from 'lucide-react';
import { Button } from '../ui/Button';
import { apiRequest } from '../../lib/api';
import { useSSE } from '../../hooks/useSSE';

interface HeaderProps {
  onOpenPalette: () => void;
}

export function Header({ onOpenPalette }: HeaderProps) {
  const { isConnected, scanProgress } = useSSE();
  const [isScanning, setIsScanning] = useState(false);
  const [theme, setTheme] = useState<'dark' | 'light'>(() => {
    if (typeof window !== 'undefined') {
      return document.documentElement.classList.contains('dark') ? 'dark' : 'light';
    }
    return 'dark';
  });
  const [countdown, setCountdown] = useState(30);

  // Scan countdown timer
  useEffect(() => {
    const timer = setInterval(() => {
      setCountdown((prev) => (prev <= 1 ? 30 : prev - 1));
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const handleScanNow = async () => {
    try {
      setIsScanning(true);
      await apiRequest('/scan', { method: 'POST' });
      setCountdown(30);
    } catch (err) {
      console.error('Scan error:', err);
    } finally {
      setTimeout(() => setIsScanning(false), 2000);
    }
  };

  const toggleTheme = () => {
    const next = theme === 'dark' ? 'light' : 'dark';
    setTheme(next);
    localStorage.setItem('theme', next);
    if (next === 'dark') {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
    const bg = getComputedStyle(document.documentElement).getPropertyValue('--bg').trim();
    const meta = document.getElementById('meta-theme-color');
    if (meta && bg) meta.setAttribute('content', bg);
  };

  return (
    <header className="h-16 border-b border-border bg-surface/80 backdrop-blur-md sticky top-0 z-30 px-6 flex items-center justify-between">
      {/* Search trigger for Command Palette */}
      <button
        onClick={onOpenPalette}
        className="flex items-center gap-3 px-3.5 py-1.5 rounded-lg bg-surface-2 hover:bg-surface border border-border text-text-muted hover:text-text text-xs transition-colors w-72 justify-between"
      >
        <span className="flex items-center gap-2">
          <Search className="w-3.5 h-3.5" />
          <span>Quick jump to port, domain...</span>
        </span>
        <kbd className="px-1.5 py-0.5 text-[10px] font-mono bg-surface text-text-muted rounded border border-border-strong">
          ⌘K
        </kbd>
      </button>

      {/* Right control items */}
      <div className="flex items-center gap-4">
        {/* Realtime Live Pulse */}
        <div className="flex items-center gap-2 px-2.5 py-1 rounded-full bg-surface-2 border border-border text-xs">
          <span className="relative flex h-2 w-2">
            <span
              className={`animate-ping absolute inline-flex h-full w-full rounded-full ${
                isConnected ? 'bg-status-up opacity-75' : 'bg-status-slow opacity-75'
              }`}
            />
            <span
              className={`relative inline-flex rounded-full h-2 w-2 ${
                isConnected ? 'bg-status-up' : 'bg-status-slow'
              }`}
            />
          </span>
          <span className="text-[11px] text-text font-medium">
            {isConnected ? 'Live SSE' : 'Connecting'}
          </span>
          <span className="text-text-muted text-[10px] font-mono">({countdown}s)</span>
        </div>

        {/* Scan Now Button */}
        <Button
          variant="secondary"
          size="sm"
          onClick={handleScanNow}
          isLoading={isScanning || !!scanProgress}
          className="text-xs"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${isScanning ? 'animate-spin' : ''}`} />
          <span>{scanProgress ? `Scanning ${scanProgress.progress}%` : 'Scan Now'}</span>
        </Button>

        {/* Theme Toggle */}
        <button
          onClick={toggleTheme}
          className="p-2 rounded-lg text-text-muted hover:text-text hover:bg-surface-2 transition-colors"
          title={`Switch to ${theme === 'dark' ? 'Light' : 'Dark'} mode`}
          aria-label="Toggle theme"
        >
          {theme === 'dark' ? <Sun className="w-4 h-4" /> : <Moon className="w-4 h-4" />}
        </button>

        {/* User Pill */}
        <div className="flex items-center gap-2 pl-2 border-l border-border">
          <div className="w-7 h-7 rounded-full bg-primary/20 text-primary border border-primary/30 flex items-center justify-center font-bold text-xs">
            A
          </div>
          <span className="text-xs font-medium text-text">admin</span>
        </div>
      </div>
    </header>
  );
}
