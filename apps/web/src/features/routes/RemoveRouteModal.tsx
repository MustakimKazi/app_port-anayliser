import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { AlertTriangle, Archive, Trash2, CheckCircle2 } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Button } from '../../components/ui/Button';
import { Modal } from '../../components/ui/Modal';
import { Route } from '../../types';

interface RemoveRouteModalProps {
  route: Route | null;
  onClose: () => void;
  onArchived?: () => void;
}

export function RemoveRouteModal({ route, onClose, onArchived }: RemoveRouteModalProps) {
  const queryClient = useQueryClient();
  const [deleteMode, setDeleteMode] = useState<'archive' | 'permanent'>('archive');
  const [confirmInput, setConfirmInput] = useState('');

  const { data: impact, isLoading } = useQuery<{
    backendOrphaned: boolean;
    openIssuesCount: number;
    warningLevel: 'safe' | 'caution' | 'dangerous';
    notice: string;
  }>({
    queryKey: ['route-impact', route?.id],
    queryFn: () => apiRequest(`/routes/${route?.id}/impact`),
    enabled: !!route
  });

  const archiveMutation = useMutation({
    mutationFn: () =>
      apiRequest(`/routes/${route?.id}/archive`, {
        method: 'POST',
        body: JSON.stringify({ reason: 'Archived from routes manager' })
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['routes'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
      onArchived?.();
      onClose();
    }
  });

  const permanentDeleteMutation = useMutation({
    mutationFn: () =>
      apiRequest(`/routes/${route?.id}?confirm=yes`, {
        method: 'DELETE'
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['routes'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
      onClose();
    }
  });

  if (!route) return null;

  const isConfirmed = confirmInput.trim() === route.domain.trim();

  return (
    <Modal isOpen={!!route} onClose={onClose} title={`Remove Route: ${route.domain}${route.path}`}>
      <div className="space-y-4 text-xs">
        {/* Impact Warning */}
        {isLoading ? (
          <div className="py-4 text-center text-text-muted">Computing routing dependency impact...</div>
        ) : (
          <div className="space-y-3">
            <div
              className={`p-3 rounded-lg border flex items-start gap-2.5 ${
                impact?.warningLevel === 'caution'
                  ? 'bg-status-slow/10 border-status-slow/30 text-status-slow'
                  : 'bg-status-up/10 border-status-up/30 text-status-up'
              }`}
            >
              <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5" />
              <div>
                <div className="font-bold">
                  {impact?.warningLevel === 'caution' ? 'Caution: Upstream Target Affected' : 'Safe to Remove'}
                </div>
                <div className="mt-1 text-[11px] text-text-muted">
                  {impact?.backendOrphaned && 'The upstream backend will have zero active routes remaining. '}
                  {impact?.openIssuesCount ? `${impact.openIssuesCount} issues linked to this route. ` : ''}
                  {impact?.notice}
                </div>
              </div>
            </div>

            {/* Mode selection */}
            <div className="space-y-2">
              <label
                onClick={() => setDeleteMode('archive')}
                className={`flex items-start gap-3 p-3 rounded-lg border cursor-pointer transition-colors ${
                  deleteMode === 'archive'
                    ? 'border-primary bg-primary/5'
                    : 'border-border bg-surface-2/40 hover:bg-surface-2'
                }`}
              >
                <input
                  type="radio"
                  name="route-delete-mode"
                  checked={deleteMode === 'archive'}
                  onChange={() => setDeleteMode('archive')}
                  className="mt-0.5"
                />
                <div>
                  <div className="font-semibold text-text flex items-center gap-1.5">
                    <Archive className="w-3.5 h-3.5 text-primary" />
                    <span>Archive (Recommended)</span>
                  </div>
                  <div className="text-[11px] text-text-muted mt-0.5">
                    Hides route from active tables and topology. Preserves history and allows one-click restoration.
                  </div>
                </div>
              </label>

              <label
                onClick={() => setDeleteMode('permanent')}
                className={`flex items-start gap-3 p-3 rounded-lg border cursor-pointer transition-colors ${
                  deleteMode === 'permanent'
                    ? 'border-status-down bg-status-down/5'
                    : 'border-border bg-surface-2/40 hover:bg-surface-2'
                }`}
              >
                <input
                  type="radio"
                  name="route-delete-mode"
                  checked={deleteMode === 'permanent'}
                  onChange={() => setDeleteMode('permanent')}
                  className="mt-0.5"
                />
                <div>
                  <div className="font-semibold text-status-down flex items-center gap-1.5">
                    <Trash2 className="w-3.5 h-3.5" />
                    <span>Permanent Delete</span>
                  </div>
                  <div className="text-[11px] text-text-muted mt-0.5">
                    Deletes record from database with full JSON snapshot archived in audit log.
                  </div>
                </div>
              </label>
            </div>

            {deleteMode === 'permanent' && (
              <div className="p-3 rounded-lg bg-surface-2 border border-border space-y-2">
                <label className="block text-text font-semibold">
                  Type <span className="font-mono text-status-down">{route.domain}</span> to confirm:
                </label>
                <input
                  type="text"
                  value={confirmInput}
                  onChange={(e) => setConfirmInput(e.target.value)}
                  placeholder={route.domain}
                  className="w-full px-3 py-1.5 rounded-lg bg-surface border border-border-strong text-text focus:outline-none focus:border-status-down font-mono"
                />
              </div>
            )}

            <div className="flex justify-end gap-2 pt-3 border-t border-border">
              <Button variant="secondary" size="sm" onClick={onClose}>
                Cancel
              </Button>
              {deleteMode === 'archive' ? (
                <Button
                  variant="primary"
                  size="sm"
                  onClick={() => archiveMutation.mutate()}
                  isLoading={archiveMutation.isPending}
                >
                  Archive Route
                </Button>
              ) : (
                <Button
                  variant="danger"
                  size="sm"
                  disabled={!isConfirmed}
                  onClick={() => permanentDeleteMutation.mutate()}
                  isLoading={permanentDeleteMutation.isPending}
                >
                  Delete Permanently
                </Button>
              )}
            </div>
          </div>
        )}
      </div>
    </Modal>
  );
}
