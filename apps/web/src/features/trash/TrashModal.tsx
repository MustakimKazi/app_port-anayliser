import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Trash2, RotateCcw, Archive, AlertTriangle, X, CheckCircle2 } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Button } from '../../components/ui/Button';

interface TrashModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function TrashModal({ isOpen, onClose }: TrashModalProps) {
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<'ports' | 'routes' | 'backends' | 'servers' | 'snapshots'>('ports');

  const { data: trash, isLoading } = useQuery<{
    ports: any[];
    routes: any[];
    backends: any[];
    servers: any[];
    snapshots: any[];
    totalArchived: number;
  }>({
    queryKey: ['trash'],
    queryFn: () => apiRequest('/trash'),
    enabled: isOpen
  });

  // Restore port mutation
  const restorePortMutation = useMutation({
    mutationFn: async (id: string) => {
      return apiRequest(`/ports/${id}/restore`, { method: 'POST' });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['trash'] });
      queryClient.invalidateQueries({ queryKey: ['ports'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
    }
  });

  // Restore route mutation
  const restoreRouteMutation = useMutation({
    mutationFn: async (id: string) => {
      return apiRequest(`/routes/${id}/restore`, { method: 'POST' });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['trash'] });
      queryClient.invalidateQueries({ queryKey: ['routes'] });
    }
  });

  // Restore backend mutation
  const restoreBackendMutation = useMutation({
    mutationFn: async (id: string) => {
      return apiRequest(`/backends/${id}/restore`, { method: 'POST' });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['trash'] });
      queryClient.invalidateQueries({ queryKey: ['backends'] });
    }
  });

  // Restore server mutation
  const restoreServerMutation = useMutation({
    mutationFn: async (id: string) => {
      return apiRequest(`/servers/${id}/restore`, { method: 'POST' });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['trash'] });
      queryClient.invalidateQueries({ queryKey: ['servers'] });
    }
  });

  // Restore snapshot mutation
  const restoreSnapshotMutation = useMutation({
    mutationFn: async (id: string) => {
      return apiRequest(`/trash/restore-snapshot/${id}`, { method: 'POST' });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['trash'] });
      queryClient.invalidateQueries({ queryKey: ['ports'] });
      queryClient.invalidateQueries({ queryKey: ['routes'] });
    }
  });

  if (!isOpen) return null;

  const ports = trash?.ports || [];
  const routes = trash?.routes || [];
  const backends = trash?.backends || [];
  const servers = trash?.servers || [];
  const snapshots = trash?.snapshots || [];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-text/50 backdrop-blur-sm animate-in fade-in">
      <div className="relative w-full max-w-3xl bg-surface border border-border-strong rounded-xl shadow-2xl flex flex-col max-h-[85vh] overflow-hidden">
        {/* Header */}
        <div className="px-6 py-4 border-b border-border bg-surface-2/60 flex items-center justify-between">
          <div>
            <div className="text-base font-semibold text-text flex items-center gap-2">
              <Archive className="w-5 h-5 text-text-muted" />
              <span>Archived Items & Trash</span>
            </div>
            <p className="text-xs text-text-muted mt-0.5">
              Review soft-deleted ports, routes, backends, and recoverable disaster snapshots.
            </p>
          </div>
          <button
            onClick={onClose}
            aria-label="Close dialog"
            className="p-1 rounded-lg text-text-muted hover:text-text hover:bg-surface transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Notice */}
        <div className="px-6 py-2 bg-surface-2/30 border-b border-border text-[11px] text-text-muted flex items-center gap-2">
          <AlertTriangle className="w-3.5 h-3.5 text-status-slow" />
          <span>Archived items are retained indefinitely (auto-purge is currently disabled).</span>
        </div>

        {/* Tabs */}
        <div className="flex border-b border-border bg-surface px-6 pt-2">
          {[
            { id: 'ports', label: `Ports (${ports.length})` },
            { id: 'routes', label: `Routes (${routes.length})` },
            { id: 'backends', label: `Backends (${backends.length})` },
            { id: 'servers', label: `Servers (${servers.length})` },
            { id: 'snapshots', label: `Deleted Snapshots (${snapshots.length})` }
          ].map((t) => (
            <button
              key={t.id}
              onClick={() => setActiveTab(t.id as any)}
              className={`px-3.5 py-2 text-xs font-medium border-b-2 transition-colors ${
                activeTab === t.id
                  ? 'border-primary text-primary font-bold'
                  : 'border-transparent text-text-muted hover:text-text'
              }`}
            >
              {t.label}
            </button>
          ))}
        </div>

        {/* Content list */}
        <div className="flex-1 overflow-y-auto p-6">
          {isLoading ? (
            <div className="text-center py-10 text-xs text-text-muted">Loading archived items...</div>
          ) : activeTab === 'ports' ? (
            ports.length === 0 ? (
              <div className="text-center py-12 text-xs text-text-muted">No archived ports.</div>
            ) : (
              <div className="divide-y divide-border border border-border rounded-lg overflow-hidden">
                {ports.map((p) => (
                  <div key={p.id} className="p-3 bg-surface hover:bg-surface-2/50 flex items-center justify-between transition-colors">
                    <div>
                      <div className="text-xs font-mono font-bold text-text flex items-center gap-2">
                        <span>Port :{p.port}</span>
                        <span className="text-[10px] px-1.5 py-0.2 rounded bg-surface-2 text-text-muted uppercase">
                          {p.protocol} / {p.layer}
                        </span>
                      </div>
                      <div className="text-[11px] text-text-muted mt-0.5">
                        {p.purpose || 'No purpose recorded'} • Archived {new Date(p.archivedAt).toLocaleString()} by {p.archivedBy || 'admin'}
                      </div>
                    </div>
                    <Button
                      variant="secondary"
                      size="sm"
                      onClick={() => restorePortMutation.mutate(p.id)}
                      isLoading={restorePortMutation.isPending}
                      className="text-xs"
                    >
                      <RotateCcw className="w-3.5 h-3.5 mr-1" />
                      Restore Port
                    </Button>
                  </div>
                ))}
              </div>
            )
          ) : activeTab === 'routes' ? (
            routes.length === 0 ? (
              <div className="text-center py-12 text-xs text-text-muted">No archived routes.</div>
            ) : (
              <div className="divide-y divide-border border border-border rounded-lg overflow-hidden">
                {routes.map((r) => (
                  <div key={r.id} className="p-3 bg-surface hover:bg-surface-2/50 flex items-center justify-between transition-colors">
                    <div>
                      <div className="text-xs font-mono font-bold text-text">
                        {r.domain}{r.path}
                      </div>
                      <div className="text-[11px] text-text-muted mt-0.5">
                        Action: {r.action} • Port: {r.portNum || 'unassigned'} • Archived {new Date(r.archivedAt).toLocaleString()}
                      </div>
                    </div>
                    <Button
                      variant="secondary"
                      size="sm"
                      onClick={() => restoreRouteMutation.mutate(r.id)}
                      isLoading={restoreRouteMutation.isPending}
                      className="text-xs"
                    >
                      <RotateCcw className="w-3.5 h-3.5 mr-1" />
                      Restore Route
                    </Button>
                  </div>
                ))}
              </div>
            )
          ) : activeTab === 'backends' ? (
            backends.length === 0 ? (
              <div className="text-center py-12 text-xs text-text-muted">No archived backends.</div>
            ) : (
              <div className="divide-y divide-border border border-border rounded-lg overflow-hidden">
                {backends.map((b) => (
                  <div key={b.id} className="p-3 bg-surface hover:bg-surface-2/50 flex items-center justify-between transition-colors">
                    <div>
                      <div className="text-xs font-mono font-bold text-text">
                        {b.host}:{b.port}
                      </div>
                      <div className="text-[11px] text-text-muted mt-0.5">
                        Label: {b.label} • Archived {new Date(b.archivedAt).toLocaleString()}
                      </div>
                    </div>
                    <Button
                      variant="secondary"
                      size="sm"
                      onClick={() => restoreBackendMutation.mutate(b.id)}
                      isLoading={restoreBackendMutation.isPending}
                      className="text-xs"
                    >
                      <RotateCcw className="w-3.5 h-3.5 mr-1" />
                      Restore Backend
                    </Button>
                  </div>
                ))}
              </div>
            )
          ) : activeTab === 'servers' ? (
            servers.length === 0 ? (
              <div className="text-center py-12 text-xs text-text-muted">No archived servers.</div>
            ) : (
              <div className="divide-y divide-border border border-border rounded-lg overflow-hidden">
                {servers.map((s) => (
                  <div key={s.id} className="p-3 bg-surface hover:bg-surface-2/50 flex items-center justify-between transition-colors">
                    <div>
                      <div className="text-xs font-bold text-text">
                        {s.name} ({s.host})
                      </div>
                      <div className="text-[11px] text-text-muted mt-0.5">
                        Kind: {s.kind} • Archived {new Date(s.archivedAt).toLocaleString()}
                      </div>
                    </div>
                    <Button
                      variant="secondary"
                      size="sm"
                      onClick={() => restoreServerMutation.mutate(s.id)}
                      isLoading={restoreServerMutation.isPending}
                      className="text-xs"
                    >
                      <RotateCcw className="w-3.5 h-3.5 mr-1" />
                      Restore Server
                    </Button>
                  </div>
                ))}
              </div>
            )
          ) : (
            snapshots.length === 0 ? (
              <div className="text-center py-12 text-xs text-text-muted">No deletion snapshots recorded.</div>
            ) : (
              <div className="divide-y divide-border border border-border rounded-lg overflow-hidden">
                {snapshots.map((snap) => (
                  <div key={snap.id} className="p-3 bg-surface hover:bg-surface-2/50 flex items-center justify-between transition-colors">
                    <div>
                      <div className="text-xs font-bold text-text flex items-center gap-2">
                        <span>{snap.entityName}</span>
                        <span className="text-[10px] px-1.5 py-0.2 rounded bg-surface-2 text-text-muted uppercase">
                          {snap.entityType} snapshot
                        </span>
                      </div>
                      <div className="text-[11px] text-text-muted mt-0.5">
                        Deleted permanently {new Date(snap.createdAt).toLocaleString()} by {snap.deletedBy}
                      </div>
                    </div>
                    <Button
                      variant="secondary"
                      size="sm"
                      onClick={() => restoreSnapshotMutation.mutate(snap.id)}
                      isLoading={restoreSnapshotMutation.isPending}
                      className="text-xs"
                    >
                      <RotateCcw className="w-3.5 h-3.5 mr-1" />
                      Restore from Snapshot
                    </Button>
                  </div>
                ))}
              </div>
            )
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-border bg-surface-2/60 flex items-center justify-end">
          <Button variant="secondary" size="sm" onClick={onClose} className="text-xs">
            Close
          </Button>
        </div>
      </div>
    </div>
  );
}
