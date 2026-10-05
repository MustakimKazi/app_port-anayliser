import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Server,
  Globe,
  Network,
  AlertTriangle,
  FileCode,
  ShieldCheck,
  Grid,
  History,
  Settings,
  Radio
} from 'lucide-react';

interface SidebarProps {
  isCollapsed: boolean;
  onToggle: () => void;
}

export function Sidebar({ isCollapsed, onToggle }: SidebarProps) {
  const navItems = [
    { name: 'Dashboard', path: '/', icon: LayoutDashboard },
    { name: 'Ports', path: '/ports', icon: Server },
    { name: 'Domains & Routes', path: '/routes', icon: Globe },
    { name: 'Backends & Topology', path: '/backends', icon: Network },
    { name: 'Issues & Checks', path: '/issues', icon: AlertTriangle },
    { name: 'Config Files', path: '/config-files', icon: FileCode },
    { name: 'Certificates', path: '/certificates', icon: ShieldCheck },
    { name: 'Port Map & Finder', path: '/port-map', icon: Grid },
    { name: 'History & Timeline', path: '/history', icon: History },
    { name: 'Settings & Alerts', path: '/settings', icon: Settings }
  ];

  return (
    <aside
      className={`fixed top-0 left-0 bottom-0 z-40 bg-surface border-r border-border transition-all duration-300 flex flex-col ${
        isCollapsed ? 'w-20' : 'w-64'
      }`}
    >
      {/* Brand Header */}
      <div className="h-16 flex items-center justify-between px-4 border-b border-border bg-surface">
        <NavLink to="/" className="flex items-center gap-3 group">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-accent p-0.5 flex items-center justify-center shadow-lg group-hover:scale-105 transition-transform">
            <div className="w-full h-full bg-surface rounded-[10px] flex items-center justify-center">
              <Radio className="w-5 h-5 text-primary group-hover:text-accent transition-colors" />
            </div>
          </div>
          {!isCollapsed && (
            <div className="flex flex-col">
              <span className="font-bold text-base tracking-tight text-text flex items-center gap-1.5">
                PortWatch
                <span className="text-[10px] font-mono font-medium px-1.5 py-0.2 rounded bg-primary/10 dark:bg-surface-3 text-primary border border-primary/30 dark:border-border">
                  v1.0
                </span>
              </span>
              <span className="text-[11px] text-text-muted font-mono">leadowserver</span>
            </div>
          )}
        </NavLink>
      </div>

      {/* Navigation Links */}
      <nav className="flex-1 overflow-y-auto p-3 space-y-1.5">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) =>
                `flex items-center gap-3 px-3 py-2.5 rounded-lg text-xs font-medium transition-all group ${
                  isActive
                    ? 'bg-primary/10 text-primary font-semibold border border-primary/30 shadow-sm dark:bg-surface-3 dark:text-primary dark:border-transparent'
                    : 'text-text-muted hover:text-text hover:bg-surface-2'
                } ${isCollapsed ? 'justify-center' : ''}`
              }
              title={isCollapsed ? item.name : undefined}
            >
              <Icon className="w-4 h-4 shrink-0 transition-transform group-hover:scale-110" />
              {!isCollapsed && <span className="truncate">{item.name}</span>}
            </NavLink>
          );
        })}
      </nav>

      {/* Footer Host Status */}
      <div className="p-4 border-t border-border bg-surface">
        <div className={`flex items-center gap-2.5 ${isCollapsed ? 'justify-center' : ''}`}>
          <div className="relative flex h-2.5 w-2.5">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-status-up opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-status-up"></span>
          </div>
          {!isCollapsed && (
            <div className="text-[11px] leading-tight truncate">
              <div className="font-semibold text-text">Target Server</div>
              <div className="text-text-muted font-mono truncate">127.0.0.1 (host)</div>
            </div>
          )}
        </div>
      </div>
    </aside>
  );
}
