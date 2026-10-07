import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { AlertTriangle, Archive, Trash2, ShieldAlert, CheckCircle2, X, ExternalLink } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Button } from '../../components/ui/Button';
import { ImpactPreview } from '../../types';

interface RemovePortDialogProps {
  portId: string;
  portNumber: number;
  isOpen: boolean;
  onClose: () => void;
  onArchived?: (portNum: number, portId: string) => void;
}

export function RemovePortDialog({ portId, portNumber, isOpen, onClose, onArchived }: RemovePortDialogProps) {
  const queryClient = useQueryClient();
  const [actionChoice, setActionChoice] = useState<'archive' | 'archive_detach' | 'delete'>('archive');
  const [confirmInput, setConfirmInput] = useState<string>('');
  const [deleteRoutes, setDeleteRoutes] = useState<boolean>(false);

  // Fetch impact preview
  const { data: impact, isLoading } = useQuery<ImpactPreview>({
    queryKey: ['port-impact', portId],
    queryFn: () => apiRequest(`/ports/${portId}/impact`),
    enabled: isOpen
  });

  // Archive mutation
  const archiveMutation = useMutation({
    mutationFn: async (detachRoutes: boolean) => {
      return apiRequest(`/ports/${portId}/archive`, {
        method: 'POST',
        body: JSON.stringify({ detachRoutes })
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ports'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
      queryClient.invalidateQueries({ queryKey: ['trash'] });
      if (onArchived) onArchived(portNumber, portId);
      onClose();
    }
  });

  // Permanent Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async () => {
      return apiRequest(`/ports/${portId}?confirm=${confirmInput}&deleteRoutes=${deleteRoutes}`, {
        method: 'DELETE'
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ports'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
      queryClient.invalidateQueries({ queryKey: ['trash'] });
      onClose();
    }
  });

  if (!isOpen) return null;

  const warningLevel = impact?.warningLevel || 'safe';
  const hasRoutes = (impact?.routesCount || 0) > 0;
  const isConfirmValid = confirmInput.trim() === String(portNumber);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-text/50 backdrop-blur-sm animate-in fade-in">
      <div className="relative w-full max-w-lg bg-surface border border-border-strong rounded-xl shadow-2xl flex flex-col max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="px-6 py-4 border-b border-border bg-surface-2/60 flex items-center justify-between">
          <div className="flex items-center gap-2 text-text font-semibold text-base">
            <ShieldAlert className="w-5 h-5 text-status-slow" />
            <span>Remove Port :{portNumber}</span>
          </div>
          <button
            onClick={onClose}
            aria-label="Close dialog"
            className="p-1 rounded-lg text-text-muted hover:text-text hover:bg-surface transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content Body */}
        <div className="flex-1 overflow-y-auto p-6 space-y-5">
          {/* Important plain words notice */}
          <div className="p-3 bg-surface-2 border border-border rounded-lg text-xs text-text-muted flex items-start gap-2.5">
            <AlertTriangle className="w-4 h-4 text-status-slow shrink-0 mt-0.5" />
            <div>
              <span className="font-semibold text-text">PortWatch documentation only: </span>
              This removes the port from PortWatch only. The service and listeners on the host server will keep running.
            </div>
          </div>

          {/* Impact preview panel */}
          {isLoading ? (
            <div className="p-6 text-center text-xs text-text-muted">Calculating dependency impact...</div>
          ) : impact ? (
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase text-text-muted tracking-wider">
                  Impact Assessment
                </span>
                <span
                  className={`text-xs px-2.5 py-0.5 rounded-full font-bold uppercase tracking-wider border ${
                    warningLevel === 'dangerous'
                      ? 'bg-status-down/10 text-status-down border-status-down/30'
                      : warningLevel === 'caution'
                      ? 'bg-status-slow/10 text-status-slow border-status-slow/30'
                      : 'bg-status-up/10 text-status-up border-status-up/30'
                  }`}
                >
                  {warningLevel}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-2 text-xs bg-surface-2/50 p-3 rounded-lg border border-border">
                <div>
                  <span className="text-text-muted">Attached Routes: </span>
                  <span className="font-bold text-text">{impact.routesCount}</span>
                </div>
                <div>
                  <span className="text-text-muted">Impacted Domains: </span>
                  <span className="font-bold text-text">{impact.domainsCount}</span>
                </div>
                <div>
                  <span className="text-text-muted">Orphaned Backends: </span>
                  <span className="font-bold text-text">{impact.orphanedBackendsCount || 0}</span>
                </div>
                <div>
                  <span className="text-text-muted">Host Listener: </span>
                  <span className={`font-bold ${impact.isListening ? 'text-status-slow' : 'text-text-muted'}`}>
                    {impact.isListening ? 'Listening on host' : 'Not listening'}
                  </span>
                </div>
              </div>

              {hasRoutes && (
                <div className="border border-border rounded-lg overflow-hidden max-h-36 overflow-y-auto">
                  <div className="bg-surface-2 px-3 py-1.5 text-[11px] font-semibold text-text-muted border-b border-border">
                    Routes using Port :{portNumber}
                  </div>
                  <div className="divide-y divide-border">
                    {impact.routes.map((r) => (
                      <div key={r.id} className="px-3 py-1.5 text-xs flex items-center justify-between">
                        <span className="font-mono text-text truncate">
                          {r.domain}{r.path}
                        </span>
                        <span className="text-[10px] text-text-muted uppercase font-bold">{r.action}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          ) : null}

          {/* Action Choice Selection */}
          <div className="space-y-2">
            <span className="text-xs font-semibold uppercase text-text-muted tracking-wider">
              Choose Removal Action
            </span>

            {/* Option 1: Archive (Recommended) */}
            <label
              onClick={() => setActionChoice('archive')}
              className={`block p-3 rounded-lg border cursor-pointer transition-colors ${
                actionChoice === 'archive'
                  ? 'border-primary bg-primary/5 text-text'
                  : 'border-border bg-surface-2/40 hover:bg-surface-2 text-text'
              }`}
            >
              <div className="flex items-start gap-2">
                <input
                  type="radio"
                  name="removeAction"
                  checked={actionChoice === 'archive'}
                  onChange={() => setActionChoice('archive')}
                  className="mt-0.5 text-primary"
                />
                <div>
                  <div className="text-xs font-semibold flex items-center gap-1.5">
                    <span>Archive Port (Recommended)</span>
                    <span className="text-[10px] px-1.5 py-0.2 rounded-full bg-status-up/10 text-status-up font-bold">
                      Safe
                    </span>
                  </div>
                  <div className="text-[11px] text-text-muted mt-0.5">
                    Soft delete: hidden from lists, scanning paused, check history preserved, routes marked. Restorable anytime from Trash.
                  </div>
                </div>
              </div>
            </label>

            {/* Option 2: Archive & Detach Routes */}
            {hasRoutes && (
              <label
                onClick={() => setActionChoice('archive_detach')}
                className={`block p-3 rounded-lg border cursor-pointer transition-colors ${
                  actionChoice === 'archive_detach'
                    ? 'border-primary bg-primary/5 text-text'
                    : 'border-border bg-surface-2/40 hover:bg-surface-2 text-text'
                }`}
              >
                <div className="flex items-start gap-2">
                  <input
                    type="radio"
                    name="removeAction"
                    checked={actionChoice === 'archive_detach'}
                    onChange={() => setActionChoice('archive_detach')}
                    className="mt-0.5 text-primary"
                  />
                  <div>
                    <div className="text-xs font-semibold">Archive and Detach Routes</div>
                    <div className="text-[11px] text-text-muted mt-0.5">
                      Archives the port and unlinks attached routes (they become unassigned routes so nothing is lost).
                    </div>
                  </div>
                </div>
              </label>
            )}

            {/* Option 3: Delete Permanently */}
            <label
              onClick={() => setActionChoice('delete')}
              className={`block p-3 rounded-lg border cursor-pointer transition-colors ${
                actionChoice === 'delete'
                  ? 'border-status-down bg-status-down/5 text-text'
                  : 'border-border bg-surface-2/40 hover:bg-surface-2 text-text'
              }`}
            >
              <div className="flex items-start gap-2">
                <input
                  type="radio"
                  name="removeAction"
                  checked={actionChoice === 'delete'}
                  onChange={() => setActionChoice('delete')}
                  className="mt-0.5 text-status-down"
                />
                <div>
                  <div className="text-xs font-semibold text-status-down flex items-center gap-1.5">
                    <span>Delete Permanently (Admin Only)</span>
                  </div>
                  <div className="text-[11px] text-text-muted mt-0.5">
                    Removes port and its features. A full JSON snapshot is saved in the audit log & Trash snapshots for disaster recovery.
                  </div>
                </div>
              </div>
            </label>
          </div>

          {/* Delete Permanently Confirmation Inputs */}
          {actionChoice === 'delete' && (
            <div className="p-3 bg-status-down/10 border border-status-down/30 rounded-lg space-y-3">
              {hasRoutes && (
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="deleteRoutesCheck"
                    checked={deleteRoutes}
                    onChange={(e) => setDeleteRoutes(e.target.checked)}
                    className="w-4 h-4 rounded text-status-down focus:ring-status-down"
                  />
                  <label htmlFor="deleteRoutesCheck" className="text-xs font-medium text-status-down cursor-pointer">
                    Also permanently delete the {impact?.routesCount} attached routes
                  </label>
                </div>
              )}

              <div>
                <label className="block text-xs font-medium text-text mb-1">
                  Type <span className="font-mono font-bold text-status-down">{portNumber}</span> to confirm:
                </label>
                <input
                  type="text"
                  value={confirmInput}
                  onChange={(e) => setConfirmInput(e.target.value)}
                  placeholder={`Type ${portNumber}`}
                  className="w-full px-3 py-2 text-sm bg-surface border border-border rounded-lg text-text font-mono"
                  autoFocus
                />
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-border bg-surface-2/60 flex items-center justify-between">
          <Button variant="ghost" size="sm" onClick={onClose} className="text-xs">
            Cancel
          </Button>

          {actionChoice === 'archive' && (
            <Button
              variant="primary"
              size="sm"
              onClick={() => archiveMutation.mutate(false)}
              isLoading={archiveMutation.isPending}
              className="text-xs"
            >
              <Archive className="w-3.5 h-3.5 mr-1" />
              Archive Port
            </Button>
          )}

          {actionChoice === 'archive_detach' && (
            <Button
              variant="primary"
              size="sm"
              onClick={() => archiveMutation.mutate(true)}
              isLoading={archiveMutation.isPending}
              className="text-xs"
            >
              <Archive className="w-3.5 h-3.5 mr-1" />
              Archive & Detach Routes
            </Button>
          )}

          {actionChoice === 'delete' && (
            <Button
              variant="danger"
              size="sm"
              onClick={() => deleteMutation.mutate()}
              disabled={!isConfirmValid || (hasRoutes && !deleteRoutes)}
              isLoading={deleteMutation.isPending}
              className="text-xs"
            >
              <Trash2 className="w-3.5 h-3.5 mr-1" />
              Permanently Delete
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}
