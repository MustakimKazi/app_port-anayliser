import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Sliders, Check, ArrowRight, X, AlertTriangle } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Button } from '../../components/ui/Button';
import { FeaturePreset } from '../../types';

interface ApplyPresetModalProps {
  portIds: string[];
  isOpen: boolean;
  onClose: () => void;
}

export function ApplyPresetModal({ portIds, isOpen, onClose }: ApplyPresetModalProps) {
  const queryClient = useQueryClient();
  const [selectedPresetId, setSelectedPresetId] = useState<string>('');
  const [diffPreview, setDiffPreview] = useState<any>(null);

  const { data: presets = [] } = useQuery<FeaturePreset[]>({
    queryKey: ['feature-presets'],
    queryFn: () => apiRequest('/feature-presets'),
    enabled: isOpen
  });

  // Preview mutation
  const previewMutation = useMutation({
    mutationFn: async () => {
      return apiRequest('/ports/features/apply-preset', {
        method: 'POST',
        body: JSON.stringify({
          portIds,
          presetId: selectedPresetId,
          previewOnly: true
        })
      });
    },
    onSuccess: (data) => {
      setDiffPreview(data);
    }
  });

  // Apply mutation
  const applyMutation = useMutation({
    mutationFn: async () => {
      return apiRequest('/ports/features/apply-preset', {
        method: 'POST',
        body: JSON.stringify({
          portIds,
          presetId: selectedPresetId,
          previewOnly: false
        })
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ports'] });
      queryClient.invalidateQueries({ queryKey: ['port-detail'] });
      onClose();
    }
  });

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-text/50 backdrop-blur-sm animate-in fade-in">
      <div className="relative w-full max-w-xl bg-surface border border-border-strong rounded-xl shadow-2xl flex flex-col max-h-[85vh] overflow-hidden">
        {/* Header */}
        <div className="px-6 py-4 border-b border-border bg-surface-2/60 flex items-center justify-between">
          <div className="flex items-center gap-2 text-text font-semibold text-base">
            <Sliders className="w-5 h-5 text-primary" />
            <span>Apply Preset to {portIds.length} Ports</span>
          </div>
          <button
            onClick={onClose}
            className="p-1 rounded-lg text-text-muted hover:text-text hover:bg-surface transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto p-6 space-y-4">
          <div>
            <label className="block text-xs font-medium text-text mb-1">Select Preset</label>
            <select
              value={selectedPresetId}
              onChange={(e) => {
                setSelectedPresetId(e.target.value);
                setDiffPreview(null);
              }}
              className="w-full px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text focus:outline-none focus:border-primary"
            >
              <option value="">-- Choose a feature preset --</option>
              {presets.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name} {p.isBuiltin ? '(Built-in)' : '(Custom)'}
                </option>
              ))}
            </select>
          </div>

          {selectedPresetId && !diffPreview && (
            <Button
              variant="secondary"
              size="sm"
              onClick={() => previewMutation.mutate()}
              isLoading={previewMutation.isPending}
              className="text-xs"
            >
              Calculate Diff Preview
            </Button>
          )}

          {diffPreview && (
            <div className="space-y-3">
              <div className="text-xs font-semibold text-text flex items-center justify-between">
                <span>Diff Preview for Preset: "{diffPreview.presetName}"</span>
                <span className="text-text-muted">{diffPreview.portsCount} ports</span>
              </div>

              <div className="border border-border rounded-lg overflow-hidden divide-y divide-border max-h-64 overflow-y-auto">
                {diffPreview.diffs.map((d: any) => (
                  <div key={d.portId} className="p-3 text-xs bg-surface space-y-1">
                    <div className="font-mono font-bold text-text">Port :{d.portNum}</div>
                    {d.changes.length === 0 ? (
                      <div className="text-text-muted text-[11px]">No changes — port already matches preset.</div>
                    ) : (
                      <div className="space-y-0.5">
                        {d.changes.map((c: any, idx: number) => (
                          <div key={idx} className="text-[11px] flex items-center gap-1.5 text-text-muted">
                            <span className="font-mono text-text">{c.featureKey}:</span>
                            <span className={c.fromEnabled ? 'text-status-up' : 'text-text-muted'}>
                              {c.fromEnabled ? 'ON' : 'OFF'}
                            </span>
                            <ArrowRight className="w-3 h-3 text-text-muted" />
                            <span className={c.toEnabled ? 'text-status-up font-bold' : 'text-text-muted font-bold'}>
                              {c.toEnabled ? 'ON' : 'OFF'}
                            </span>
                            {c.configChanges && <span className="text-status-info text-[10px]">(config updated)</span>}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-border bg-surface-2/60 flex items-center justify-between">
          <Button variant="ghost" size="sm" onClick={onClose} className="text-xs">
            Cancel
          </Button>
          <Button
            variant="primary"
            size="sm"
            onClick={() => applyMutation.mutate()}
            disabled={!selectedPresetId}
            isLoading={applyMutation.isPending}
            className="text-xs"
          >
            Apply Preset to All
          </Button>
        </div>
      </div>
    </div>
  );
}
