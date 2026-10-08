import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Globe,
  Layers,
  Server,
  FileCode,
  Shield,
  Archive,
  RotateCcw,
  Trash2,
  ExternalLink,
  AlertTriangle
} from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Drawer } from '../../components/ui/Drawer';
import { Button } from '../../components/ui/Button';
import { ActionBadge, StatusBadge } from '../../components/ui/Badge';
import { CertificateInfo, Route } from '../../types';

interface DomainRoute {
  id: string;
  path: string;
  action: string;
  portNum: number | null;
  protocol: string;
  targetType: string;
  targetRaw: string | null;
  archivedAt: string | null;
  backend: { id: string; host: string; port: number; status: string } | null;
  configFile: { id: string; filename: string } | null;
  issues: Array<{ id: string; priority: string; title: string; status: string }>;
}

interface DomainDetail {
  domain: string;
  routes: DomainRoute[];
  ports: Array<{ portNum: number | null; purpose: string | null; protocol: string; routeCount: number }>;
  backends: Array<{ id: string; host: string; port: number; status: string; routeCount: number }>;
  configFiles: Array<{ id: string; filename: string }>;
  openIssues: Array<{ id: string; title: string; priority: string; status: string; path: string }>;
  counts: { routes: number; ports: number; backends: number; openIssues: number };
}

interface DomainImpact {
  routesCount: number;
  routes: Array<{ id: string; path: string; action: string; portNum: number | null }>;
  ports: Array<{ id: string; port: number; purpose: string | null }>;
  backends: Array<{ id: string; host: string; port: number }>;
  configFiles: Array<{ id: string; filename: string }>;
  openIssues: Array<{ id: string; title: string; priority: string }>;
  warningLevel: 'caution' | 'safe';
  notice: string;
}

interface DomainDrawerProps {
  domain: string | null;
  onClose: () => void;
  onOpenRoute?: (routeId: string) => void;
  onDelete?: (domain: string) => void;
  isViewer?: boolean;
}

export function DomainDrawer({ domain, onClose, onOpenRoute, onDelete, isViewer }: DomainDrawerProps) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const { data: detail, isLoading, isError, refetch } = useQuery<DomainDetail>({
    queryKey: ['domain-detail', domain],
    queryFn: () => apiRequest(`/domains/${encodeURIComponent(domain!)}`),
    enabled: !!domain,
    retry: 1
  });

  const { data: impact } = useQuery<DomainImpact>({
    queryKey: ['domain-impact', domain],
    queryFn: () => apiRequest(`/domains/${encodeURIComponent(domain!)}/impact`),
    enabled: !!domain,
    retry: 1
  });

  const { data: certs = [] } = useQuery<CertificateInfo[]>({
    queryKey: ['certificates'],
    queryFn: () => apiRequest('/certificates'),
    staleTime: 60000
  });

  const cert = domain ? certs.find((c) => c.domain === domain) : undefined;

  const archiveMutation = useMutation({
    mutationFn: (d: string) => apiRequest(`/domains/${encodeURIComponent(d)}/archive`, { method: 'POST' }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['domain-detail'] });
      queryClient.invalidateQueries({ queryKey: ['domain-impact'] });
      queryClient.invalidateQueries({ queryKey: ['routes'] });
      queryClient.invalidateQueries({ queryKey: ['domains'] });
    }
  });

  const restoreMutation = useMutation({
    mutationFn: (d: string) => apiRequest(`/domains/${encodeURIComponent(d)}/restore`, { method: 'POST' }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['domain-detail'] });
      queryClient.invalidateQueries({ queryKey: ['domain-impact'] });
      queryClient.invalidateQueries({ queryKey: ['routes'] });
      queryClient.invalidateQueries({ queryKey: ['domains'] });
    }
  });

  const isArchived = detail?.routes.every((r) => r.archivedAt !== null) && (detail?.routes.length || 0) > 0;

  return (
    <Drawer
      isOpen={!!domain}
      onClose={onClose}
      title={
        <span className="flex items-center gap-2 font-mono">
          <Globe className="w-4 h-4 text-primary" />
          <span>{domain}</span>
        </span>
      }
      subtitle={detail ? `${detail.counts.routes} routes · ${detail.counts.ports} ports · ${detail.counts.backends} backends` : undefined}
      width="max-w-2xl"
    >
      <div className="flex-1 overflow-y-auto p-6 space-y-6" data-testid="domain-drawer">
        {isLoading && (
          <div className="space-y-3 animate-pulse" data-testid="domain-drawer-loading">
            <div className="h-4 w-1/3 rounded bg-surface-2" />
            <div className="h-24 rounded-lg bg-surface-2" />
            <div className="h-32 rounded-lg bg-surface-2" />
          </div>
        )}

        {isError && (
          <div className="p-4 rounded-xl border border-status-down/30 bg-status-down/10 text-xs text-text space-y-2" data-testid="domain-drawer-error">
            <div className="font-semibold text-status-down">Failed to load domain details</div>
            <div className="text-text-muted">The domain may have been removed, or the API is unreachable.</div>
            <Button variant="secondary" size="sm" className="text-xs" onClick={() => refetch()}>
              <span>Retry</span>
            </Button>
          </div>
        )}

        {detail && (
          <>
            {/* Certificate summary */}
            <div className="p-3 rounded-lg border border-border bg-surface-2/60 flex items-center justify-between text-xs" data-testid="domain-cert-summary">
              <div className="flex items-center gap-2">
                <Shield className={`w-4 h-4 ${cert && cert.daysRemaining < 14 ? 'text-status-down' : cert ? 'text-status-up' : 'text-text-muted'}`} />
                <span className="font-semibold text-text">TLS Certificate</span>
              </div>
              {cert ? (
                <div className="flex items-center gap-2">
                  <span className="font-mono text-text-muted">{cert.issuer}</span>
                  <span
                    className={`px-2 py-0.5 rounded font-semibold border ${
                      cert.status === 'valid'
                        ? 'bg-status-up/10 text-status-up border-status-up/30'
                        : cert.status === 'expiring_soon'
                          ? 'bg-status-slow/10 text-status-slow border-status-slow/30'
                          : 'bg-status-down/10 text-status-down border-status-down/30'
                    }`}
                  >
                    {cert.daysRemaining} days left
                  </span>
                </div>
              ) : (
                <span className="text-text-muted">No certificate on record</span>
              )}
            </div>

            {/* Ports */}
            <div>
              <div className="text-[11px] uppercase tracking-wider text-text-muted font-semibold mb-2 flex items-center gap-1.5">
                <Layers className="w-3.5 h-3.5" />
                <span>Attached Ports ({detail.ports.length})</span>
              </div>
              {detail.ports.length === 0 ? (
                <div className="text-xs text-text-muted">No listening ports attached.</div>
              ) : (
                <div className="space-y-1.5" data-testid="domain-ports">
                  {detail.ports.map((p) => (
                    <div key={`${p.portNum}-${p.protocol}`} className="flex items-center justify-between p-2 rounded bg-surface-2/60 border border-border text-xs">
                      <div className="flex items-center gap-2.5">
                        <span className="font-mono font-bold text-text">:{p.portNum ?? '—'}</span>
                        <span className="text-text-muted">{p.protocol}</span>
                        {p.purpose && <span className="text-text-muted italic">{p.purpose}</span>}
                      </div>
                      <span className="text-text-muted font-mono">{p.routeCount} routes</span>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Backends */}
            <div>
              <div className="text-[11px] uppercase tracking-wider text-text-muted font-semibold mb-2 flex items-center gap-1.5">
                <Server className="w-3.5 h-3.5" />
                <span>Backends ({detail.backends.length})</span>
              </div>
              {detail.backends.length === 0 ? (
                <div className="text-xs text-text-muted">No upstream backends (static/redirect only).</div>
              ) : (
                <div className="space-y-1.5" data-testid="domain-backends">
                  {detail.backends.map((b) => (
                    <div key={b.id} className="flex items-center justify-between p-2 rounded bg-surface-2/60 border border-border text-xs">
                      <span className="font-mono font-semibold text-text">{b.host}:{b.port}</span>
                      <div className="flex items-center gap-2">
                        <span className="text-text-muted font-mono">{b.routeCount} routes</span>
                        <StatusBadge status={b.status as any} size="sm" />
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Config files */}
            <div>
              <div className="text-[11px] uppercase tracking-wider text-text-muted font-semibold mb-2 flex items-center gap-1.5">
                <FileCode className="w-3.5 h-3.5" />
                <span>Config Files ({detail.configFiles.length})</span>
              </div>
              {detail.configFiles.length === 0 ? (
                <div className="text-xs text-text-muted">Not linked to any config file.</div>
              ) : (
                <div className="space-y-1.5" data-testid="domain-config-files">
                  {detail.configFiles.map((c) => (
                    <button
                      key={c.id}
                      onClick={() => navigate(`/config-files/${c.id}`)}
                      className="w-full flex items-center justify-between p-2 rounded bg-surface-2/60 border border-border text-xs font-mono text-text hover:border-primary/50 transition-colors cursor-pointer"
                    >
                      <span>{c.filename}</span>
                      <ExternalLink className="w-3.5 h-3.5 text-text-muted" />
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Routes */}
            <div>
              <div className="text-[11px] uppercase tracking-wider text-text-muted font-semibold mb-2 flex items-center gap-1.5">
                <Globe className="w-3.5 h-3.5" />
                <span>Routes ({detail.routes.length})</span>
              </div>
              <div className="space-y-1.5" data-testid="domain-routes">
                {detail.routes.map((r) => (
                  <div
                    key={r.id}
                    role="button"
                    tabIndex={0}
                    onClick={() => onOpenRoute?.(r.id)}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter' || e.key === ' ') {
                        e.preventDefault();
                        onOpenRoute?.(r.id);
                      }
                    }}
                    className="flex items-center justify-between p-2 rounded bg-surface-2/60 border border-border text-xs cursor-pointer hover:border-primary/50 transition-colors focus:outline-none focus:border-primary"
                    data-testid="domain-route-item"
                  >
                    <div className="flex items-center gap-2.5 min-w-0">
                      <span className="font-mono text-text font-semibold">{r.path}</span>
                      <ActionBadge action={r.action} />
                      <span className="font-mono text-text-muted">:{r.portNum ?? '—'}</span>
                    </div>
                    <div className="flex items-center gap-2 shrink-0 ml-2">
                      {r.issues.length > 0 && (
                        <span className="text-[10px] px-1.5 py-0.5 rounded bg-status-slow/20 text-status-slow border border-status-slow/30 font-semibold">
                          {r.issues.length} issues
                        </span>
                      )}
                      {r.archivedAt && (
                        <span className="text-[10px] px-1.5 py-0.5 rounded bg-surface-2 text-text-muted border border-border">archived</span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Open issues */}
            {detail.openIssues.length > 0 && (
              <div className="p-3 rounded-lg border border-status-slow/40 bg-status-slow/10 space-y-1.5">
                <div className="text-xs font-semibold text-status-slow flex items-center gap-1.5">
                  <AlertTriangle className="w-4 h-4" />
                  <span>Open Issues ({detail.openIssues.length})</span>
                </div>
                {detail.openIssues.map((i) => (
                  <div key={i.id} className="flex items-center justify-between text-[11px]">
                    <span className="text-text truncate">{i.title}</span>
                    <span className="font-mono text-text-muted uppercase shrink-0 ml-2">{i.priority}</span>
                  </div>
                ))}
              </div>
            )}

            {/* Impact notice */}
            {impact && impact.warningLevel === 'caution' && (
              <div className="flex gap-2.5 p-3 rounded-lg border border-status-down/40 bg-status-down/10 text-xs text-status-down" data-testid="domain-impact-notice">
                <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5" />
                <span>{impact.notice}</span>
              </div>
            )}

            {/* Actions */}
            {!isViewer && (
              <div className="pt-4 border-t border-border flex items-center justify-between">
                <span className="text-xs text-text-muted">
                  {isArchived ? 'This domain is archived (all routes).' : 'Active domain'}
                </span>
                <div className="flex items-center gap-2">
                  {!isArchived ? (
                    <Button
                      variant="secondary"
                      size="sm"
                      className="text-xs flex items-center gap-1.5"
                      disabled={archiveMutation.isPending}
                      onClick={() => archiveMutation.mutate(domain!)}
                      data-testid="domain-archive-btn"
                    >
                      <Archive className="w-3.5 h-3.5" />
                      Archive Domain
                    </Button>
                  ) : (
                    <Button
                      variant="secondary"
                      size="sm"
                      className="text-xs flex items-center gap-1.5"
                      disabled={restoreMutation.isPending}
                      onClick={() => restoreMutation.mutate(domain!)}
                      data-testid="domain-restore-btn"
                    >
                      <RotateCcw className="w-3.5 h-3.5" />
                      Restore
                    </Button>
                  )}
                  <Button
                    variant="danger"
                    size="sm"
                    className="text-xs flex items-center gap-1.5"
                    onClick={() => onDelete?.(domain!)}
                    data-testid="domain-delete-btn"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                    Delete Domain
                  </Button>
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </Drawer>
  );
}
