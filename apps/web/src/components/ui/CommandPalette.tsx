import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Globe, Server, AlertTriangle, Layers, FileText, Shield, ArrowRight, Plus, Trash2 } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { apiRequest } from '../../lib/api';
import { Port, Route } from '../../types';

interface CommandPaletteProps {
  isOpen: boolean;
  onClose: () => void;
  onOpenAddPort?: () => void;
}

export function CommandPalette({ isOpen, onClose, onOpenAddPort }: CommandPaletteProps) {
  const [search, setSearch] = useState('');
  const navigate = useNavigate();

  const { data: portsData } = useQuery<{ data: Port[] }>({
    queryKey: ['palette-ports'],
    queryFn: () => apiRequest('/ports?limit=100'),
    enabled: isOpen
  });

  const { data: routesData } = useQuery<{ data: Route[] }>({
    queryKey: ['palette-routes'],
    queryFn: () => apiRequest('/routes?limit=150'),
    enabled: isOpen
  });

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) onClose();
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  const { data: currentUser } = useQuery<{ role: string; username: string }>({
    queryKey: ['auth-me'],
    queryFn: () => apiRequest('/auth/me').catch(() => ({ role: 'admin', username: 'admin' })),
    staleTime: 60000
  });
  const isViewer = currentUser?.role === 'viewer';

  const query = search.toLowerCase().trim();

  // Quick Actions
  const actions = [
    ...(!isViewer && onOpenAddPort ? [{
      name: 'Add port',
      description: 'Open guided dialog to add an active, planned or reserved port',
      action: () => {
        onClose();
        onOpenAddPort();
      },
      icon: Plus,
      shortcut: 'Action'
    }] : []),
    {
      name: 'Archived Ports & Trash',
      description: 'View soft-deleted ports and restore them',
      action: () => {
        onClose();
        navigate('/ports?showArchived=true');
      },
      icon: Trash2,
      shortcut: 'Trash'
    }
  ].filter(a => !query || a.name.toLowerCase().includes(query) || a.description.toLowerCase().includes(query));

  // Pages
  const pages = [
    { name: 'Dashboard', path: '/', icon: Layers, shortcut: 'G D' },
    { name: 'Ports Overview', path: '/ports', icon: Server, shortcut: 'G P' },
    { name: 'Domains & Routes', path: '/routes', icon: Globe, shortcut: 'G R' },
    { name: 'Backends & Topology', path: '/backends', icon: Server, shortcut: 'G B' },
    { name: 'Issues & Checks', path: '/issues', icon: AlertTriangle, shortcut: 'G I' },
    { name: 'Config Files', path: '/config-files', icon: FileText, shortcut: 'G C' },
    { name: 'Certificates', path: '/certificates', icon: Shield, shortcut: 'G S' },
    { name: 'Port Map & Finder', path: '/port-map', icon: Layers, shortcut: 'G M' },
    { name: 'Settings & Alerts', path: '/settings', icon: Server, shortcut: 'G ,' }
  ].filter(p => !query || p.name.toLowerCase().includes(query));

  // Matched ports
  const matchedPorts = (portsData?.data || [])
    .filter(p =>
      !query ||
      String(p.port).includes(query) ||
      (p.purpose && p.purpose.toLowerCase().includes(query)) ||
      (p.domainsList && p.domainsList.toLowerCase().includes(query))
    )
    .slice(0, 5);

  // Matched routes
  const matchedRoutes = (routesData?.data || [])
    .filter(r =>
      !query ||
      r.domain.toLowerCase().includes(query) ||
      r.path.toLowerCase().includes(query)
    )
    .slice(0, 5);

  const handleSelect = (path: string) => {
    navigate(path);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-20 px-4">
      <div className="fixed inset-0 bg-text/50 backdrop-blur-sm" onClick={onClose} />
      <div className="relative w-full max-w-xl bg-surface border border-border-strong rounded-xl shadow-2xl overflow-hidden z-10 animate-in fade-in zoom-in-95 duration-100">
        {/* Search bar */}
        <div className="flex items-center gap-3 px-4 py-3.5 border-b border-border bg-surface-2/60">
          <Search className="w-5 h-5 text-text-muted" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Type a command, port number, or domain..."
            autoFocus
            className="flex-1 bg-transparent text-sm text-text placeholder-text-muted focus:outline-none"
          />
          <kbd className="px-2 py-0.5 text-[10px] font-mono text-text-muted bg-surface-2 rounded border border-border-strong">
            ESC
          </kbd>
        </div>

        {/* Results */}
        <div className="max-h-96 overflow-y-auto p-2 space-y-3">
          {/* Quick Actions */}
          {actions.length > 0 && (
            <div>
              <div className="text-[10px] uppercase font-semibold text-text-muted px-3 py-1">Actions</div>
              {actions.map((act) => {
                const Icon = act.icon;
                return (
                  <button
                    key={act.name}
                    onClick={act.action}
                    className="w-full flex items-center justify-between px-3 py-2 rounded-lg text-sm text-text hover:bg-primary/10 hover:text-text group transition-colors text-left"
                  >
                    <div className="flex items-center gap-2.5">
                      <div className="p-1 rounded bg-primary/20 text-primary group-hover:bg-primary group-hover:text-primary-foreground transition-colors">
                        <Icon className="w-3.5 h-3.5" />
                      </div>
                      <div>
                        <div className="font-medium text-xs text-text">{act.name}</div>
                        <div className="text-[11px] text-text-muted">{act.description}</div>
                      </div>
                    </div>
                    <kbd className="text-[10px] font-mono text-text-muted group-hover:text-text">
                      {act.shortcut}
                    </kbd>
                  </button>
                );
              })}
            </div>
          )}

          {/* Navigation Pages */}
          {pages.length > 0 && (
            <div>
              <div className="text-[10px] uppercase font-semibold text-text-muted px-3 py-1">Pages</div>
              {pages.map((p) => {
                const Icon = p.icon;
                return (
                  <button
                    key={p.path}
                    onClick={() => handleSelect(p.path)}
                    className="w-full flex items-center justify-between px-3 py-2 rounded-lg text-sm text-text hover:bg-primary/10 hover:text-text group transition-colors"
                  >
                    <div className="flex items-center gap-2.5">
                      <Icon className="w-4 h-4 text-text-muted group-hover:text-primary" />
                      <span>{p.name}</span>
                    </div>
                    <kbd className="text-[10px] font-mono text-text-muted group-hover:text-text">
                      {p.shortcut}
                    </kbd>
                  </button>
                );
              })}
            </div>
          )}

          {/* Matched Ports */}
          {matchedPorts.length > 0 && (
            <div>
              <div className="text-[10px] uppercase font-semibold text-text-muted px-3 py-1">Ports</div>
              {matchedPorts.map((p) => (
                <button
                  key={p.id}
                  onClick={() => handleSelect(`/ports?portMin=${p.port}&portMax=${p.port}`)}
                  className="w-full flex items-center justify-between px-3 py-2 rounded-lg text-sm text-text hover:bg-primary/10 hover:text-text group transition-colors"
                >
                  <div className="flex items-center gap-2.5">
                    <span className="font-mono font-semibold text-primary">:{p.port}</span>
                    <span className="text-xs text-text-muted truncate max-w-xs">{p.purpose || p.domainsList}</span>
                  </div>
                  <ArrowRight className="w-4 h-4 text-text-muted group-hover:text-primary" />
                </button>
              ))}
            </div>
          )}

          {/* Matched Routes */}
          {matchedRoutes.length > 0 && (
            <div>
              <div className="text-[10px] uppercase font-semibold text-text-muted px-3 py-1">Domains & Routes</div>
              {matchedRoutes.map((r) => (
                <button
                  key={r.id}
                  onClick={() => handleSelect(`/routes?q=${r.domain}`)}
                  className="w-full flex items-center justify-between px-3 py-2 rounded-lg text-sm text-text hover:bg-primary/10 hover:text-text group transition-colors"
                >
                  <div className="flex items-center gap-2.5 truncate">
                    <Globe className="w-3.5 h-3.5 text-accent shrink-0" />
                    <span className="font-mono text-xs text-text">{r.domain}</span>
                    <span className="text-xs text-text-muted truncate">{r.path}</span>
                  </div>
                  <span className="text-[10px] px-1.5 py-0.5 rounded bg-surface-2 text-text-muted">
                    {r.action}
                  </span>
                </button>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
