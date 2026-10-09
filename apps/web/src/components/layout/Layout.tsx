import React, { useState, useEffect } from 'react';
import { Outlet, useNavigate, Navigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { apiRequest } from '../../lib/api';
import { Sidebar } from './Sidebar';
import { Header } from './Header';
import { CommandPalette } from '../ui/CommandPalette';
import { AddPortDialog } from '../../features/ports/AddPortDialog';

export function Layout() {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [isMobileNavOpen, setIsMobileNavOpen] = useState(false);

  // Auth guard: without a valid session every API call returns 401, so route
  // unauthenticated users to the login page instead of rendering a broken shell
  const { isError: unauthenticated, isLoading: authChecking } = useQuery({
    queryKey: ['auth-guard'],
    queryFn: () => apiRequest('/auth/me'),
    retry: false,
    staleTime: 30000
  });
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

  // Auth guard (declared after ALL hooks — an early return above them would
  // change the hook count between renders and crash React)
  if (!authChecking && unauthenticated) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="min-h-screen bg-bg text-text flex">
      {/* Sidebar (off-canvas below lg, fixed rail on lg+) */}
      <Sidebar
        isCollapsed={isCollapsed}
        onToggle={() => setIsCollapsed(!isCollapsed)}
        mobileOpen={isMobileNavOpen}
      />
      {isMobileNavOpen && (
        <button
          aria-label="Close navigation menu"
          onClick={() => setIsMobileNavOpen(false)}
          className="fixed inset-0 z-30 bg-black/40 lg:hidden"
        />
      )}

      {/* Main Content Area — padding only on lg+ (a fixed pl-64 caused
          horizontal overflow on 1366px/768px/390px viewports); min-w-0 lets
          the column shrink so wide tables scroll inside overflow-x-auto
          instead of stretching the whole page */}
      <div className={`min-w-0 flex-1 flex flex-col transition-all duration-300 pl-0 ${isCollapsed ? 'lg:pl-20' : 'lg:pl-64'}`}>
        <Header
          onOpenPalette={() => setIsPaletteOpen(true)}
          onOpenAddPort={() => setIsAddPortOpen(true)}
          onToggleMobileNav={() => setIsMobileNavOpen((v) => !v)}
        />
        <main className="flex-1 px-4 sm:px-6 lg:px-8 py-6 max-w-[1600px] w-full mx-auto">
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
