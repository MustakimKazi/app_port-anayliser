import React, { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Archive, Trash2, AlertTriangle, Layers } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Modal } from '../../components/ui/Modal';
import { Button } from '../../components/ui/Button';

interface DomainImpact {
  domain: string;
  routesCount: number;
  ports: Array<{ id: string; port: number; purpose: string | null }>;
  backends: Array<{ id: string; host: string; port: number }>;
  configFiles: Array<{ id: string; filename: string }>;
  openIssues: Array<{ id: string; title: string; priority: string }>;
}

interface DeleteDomainDialogProps {
  domain: string | null;
  onClose: () => void;
  onDeleted?: () => void;
}

export function DeleteDomainDialog({ domain, onClose, onDeleted }: DeleteDomainDialogProps) {
  const queryClient = useQueryClient();
  const [confirmText, setConfirmText] = useState('');
  const [mode, setMode] = useState<'choose' | 'archive' | 'delete'>('choose');

  const { data: impact, isLoading } = useQuery<DomainImpact>({
    queryKey: ['domain-impact', domain],
    queryFn: () => apiRequest(`/domains/${encodeURIComponent(domain!)}/impact`),
    enabled: !!domain,
    retry: 1
  });

  const archiveMutation = useMutation({
    mutationFn: (d: string) => apiRequest(`/domains/${encodeURIComponent(d)}/archive`, { method: 'POST' }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['routes'] });
      queryClient.invalidateQueries({ queryKey: ['domains'] });
      queryClient.invalidateQueries({ queryKey: ['domain-detail'] });
      queryClient.invalidateQueries({ queryKey: ['domain-impact'] });
      resetAndClose();
    }
  });

  const deleteMutation = useMutation({
    mutationFn: (d: string) =>
      apiRequest(`/domains/${encodeURIComponent(d)}?confirm=${encodeURIComponent(d)}`, { method: 'DELETE' }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['routes'] });
      queryClient.invalidateQueries({ queryKey: ['domains'] });
      queryClient.invalidateQueries({ queryKey: ['domain-detail'] });
      queryClient.invalidateQueries({ queryKey: ['domain-impact'] });
      onDeleted?.();
      resetAndClose();
    }
  });

  const resetAndClose = () => {
    setConfirmText('');
    setMode('choose');
    onClose();
  };

  const handleClose = () => {
    if (archiveMutation.isPending || deleteMutation.isPending) return;
    resetAndClose();
  };

  const typedMatches = confirmText === domain;

  return (
    <Modal
      isOpen={!!domain}
      onClose={handleClose}
      title={mode === 'archive' ? `Archive domain ${domain}` : mode === 'delete' ? `Delete domain ${domain} permanently` : `Remove domain ${domain}`}
    >
      <div className="space-y-4" data-testid="delete-domain-dialog">
        {/* Impact summary */}
        <div className="p-3 rounded-lg border border-border bg-surface-2/60 text-xs space-y-2" data-testid="delete-domain-impact">
          {isLoading ? (
            <div className="text-text-muted animate-pulse">Loading impact…</div>
          ) : impact ? (
            <>
              <div className="font-semibold text-text">
                {impact.routesCount} route{impact.routesCount === 1 ? '' : 's'} will be affected
              </div>
              {impact.ports.length > 0 && (
                <div className="flex flex-wrap items-center gap-1.5">
                  <span className="text-text-muted flex items-center gap-1">
                    <Layers className="w-3 h-3" />
                    Attached ports:
                  </span>
                  {impact.ports.map((p) => (
                    <span
                      key={p.id}
                      className="px-1.5 py-0.5 rounded bg-surface border border-border font-mono font-semibold text-text"
                    >
                      :{p.port}
                      {p.purpose && <span className="text-text-muted font-normal"> {p.purpose}</span>}
                    </span>
                  ))}
                </div>
              )}
              {impact.backends.length > 0 && (
                <div className="text-text-muted">
                  {impact.backends.length} backend{impact.backends.length === 1 ? '' : 's'} in use (shared — NOT deleted).
                </div>
              )}
              {impact.configFiles.length > 0 && (
                <div className="text-text-muted">
                  Config file{impact.configFiles.length === 1 ? '' : 's'}: {impact.configFiles.map((c) => c.filename).join(', ')} (shared — NOT deleted).
                </div>
              )}
              <div className="text-text-muted">
                Ports, backends, and config files are shared with other domains and will not be removed. Domain routes are snapshotted to Trash before deletion.
              </div>
            </>
          ) : (
            <div className="text-text-muted">No active routes found for this domain.</div>
          )}
        </div>

        {mode === 'choose' && (
          <>
            <div className="flex gap-2.5 p-3 rounded-lg border border-status-slow/40 bg-status-slow/10 text-xs text-status-slow">
              <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5" />
              <span>Archiving is safe and reversible. Prefer it unless you really need to remove the domain.</span>
            </div>
            <div className="flex justify-end gap-2 pt-2">
              <Button variant="ghost" size="sm" onClick={handleClose}>
                Cancel
              </Button>
              <Button
                variant="secondary"
                size="sm"
                className="flex items-center gap-1.5"
                onClick={() => setMode('archive')}
                data-testid="choose-archive"
              >
                <Archive className="w-3.5 h-3.5" />
                Archive (recommended)
              </Button>
              <Button
                variant="danger"
                size="sm"
                className="flex items-center gap-1.5"
                onClick={() => setMode('delete')}
                data-testid="choose-delete"
              >
                <Trash2 className="w-3.5 h-3.5" />
                Delete permanently…
              </Button>
            </div>
          </>
        )}

        {mode === 'archive' && (
          <div className="flex justify-end gap-2 pt-2">
            <Button variant="ghost" size="sm" onClick={handleClose}>
              Cancel
            </Button>
            <Button
              variant="primary"
              size="sm"
              disabled={archiveMutation.isPending}
              isLoading={archiveMutation.isPending}
              onClick={() => archiveMutation.mutate(domain!)}
              data-testid="confirm-archive"
            >
              Archive Domain
            </Button>
          </div>
        )}

        {mode === 'delete' && (
          <div className="space-y-3">
            <div className="p-3 rounded-lg border border-status-down/40 bg-status-down/10 text-xs text-status-down flex gap-2.5">
              <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5" />
              <span>
                This permanently removes all {impact?.routesCount ?? 0} route{impact?.routesCount === 1 ? '' : 's'} for this domain. A trash snapshot is kept for recovery.
              </span>
            </div>
            <div>
              <label className="block text-xs font-medium text-text-muted mb-1">
                Type <span className="font-mono text-text">{domain}</span> to confirm
              </label>
              <input
                type="text"
                value={confirmText}
                onChange={(e) => setConfirmText(e.target.value)}
                placeholder={domain || ''}
                data-testid="delete-confirm-input"
                className="w-full px-3 py-2 rounded-lg bg-surface border border-border-strong text-sm font-mono text-text focus:outline-none focus:border-status-down"
                autoFocus
              />
            </div>
            <div className="flex justify-end gap-2 pt-1">
              <Button variant="ghost" size="sm" onClick={() => setMode('choose')}>
                Back
              </Button>
              <Button
                variant="danger"
                size="sm"
                className="flex items-center gap-1.5"
                disabled={!typedMatches || deleteMutation.isPending}
                isLoading={deleteMutation.isPending}
                onClick={() => deleteMutation.mutate(domain!)}
                data-testid="confirm-delete"
              >
                <Trash2 className="w-3.5 h-3.5" />
                Delete Permanently
              </Button>
            </div>
          </div>
        )}
      </div>
    </Modal>
  );
}
