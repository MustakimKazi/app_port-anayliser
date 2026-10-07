import React, { useState, useEffect } from 'react';
import { Outlet, useNavigate } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Header } from './Header';
import { CommandPalette } from '../ui/CommandPalette';
import { AddPortDialog } from '../../features/ports/AddPortDialog';

export function Layout() {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [isPaletteOpen, setIsPaletteOpen] = useState(false);
  const [isAddPortOpen, setIsAddPortOpen] = useState(false);
  const navigate = useNavigate();

  // Global keyboard shortcuts (Cmd+K, /, g d, g p, etc.)
  useEffect(() => {
    let lastKey = '';
    let keyTimeout: NodeJS.Timeout;

    const handleKeyDown = (e: KeyboardEvent) => {
      // Cmd+K or Ctrl+K -> Command Palette
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        setIsPaletteOpen((prev) => !prev);
        return;
      }

      // Ignore single key shortcuts if typing inside input, textarea, or contentEditable
      const target = e.target as HTMLElement;
      if (['INPUT', 'TEXTAREA', 'SELECT'].includes(target.tagName) || target.isContentEditable) {
        return;
      }

      // '/' -> open command palette or focus search
      if (e.key === '/') {
        e.preventDefault();
        setIsPaletteOpen(true);
        return;
      }

      // 'g' key sequence shortcuts
      if (e.key === 'g') {
        lastKey = 'g';
        clearTimeout(keyTimeout);
        keyTimeout = setTimeout(() => {
          lastKey = '';
        }, 1000);
        return;
      }

      if (lastKey === 'g') {
        lastKey = '';
        if (e.key === 'd') navigate('/');
        else if (e.key === 'p') navigate('/ports');
        else if (e.key === 'r') navigate('/routes');
        else if (e.key === 'b') navigate('/backends');
        else if (e.key === 'i') navigate('/issues');
        else if (e.key === 'c') navigate('/config-files');
        else if (e.key === 's') navigate('/certificates');
        else if (e.key === 'm') navigate('/port-map');
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [navigate]);

  return (
    <div className="min-h-screen bg-bg text-text flex">
      {/* Sidebar */}
      <Sidebar isCollapsed={isCollapsed} onToggle={() => setIsCollapsed(!isCollapsed)} />

      {/* Main Content Area */}
      <div className={`flex-1 flex flex-col transition-all duration-300 ${isCollapsed ? 'pl-20' : 'pl-64'}`}>
        <Header
          onOpenPalette={() => setIsPaletteOpen(true)}
          onOpenAddPort={() => setIsAddPortOpen(true)}
        />
        <main className="flex-1 p-6 max-w-7xl w-full mx-auto">
          <Outlet />
        </main>
      </div>

      {/* Global Command Palette */}
      <CommandPalette
        isOpen={isPaletteOpen}
        onClose={() => setIsPaletteOpen(false)}
        onOpenAddPort={() => setIsAddPortOpen(true)}
      />

      {/* Global Add Port Dialog */}
      <AddPortDialog
        isOpen={isAddPortOpen}
        onClose={() => setIsAddPortOpen(false)}
      />
    </div>
  );
}
