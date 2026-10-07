import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { CheckCircle2, AlertTriangle } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Button } from '../../components/ui/Button';
import { Modal } from '../../components/ui/Modal';
import { Server as ServerType } from '../../types';

interface AddBackendDialogProps {
  isOpen: boolean;
  onClose: () => void;
}

export function AddBackendDialog({ isOpen, onClose }: AddBackendDialogProps) {
  const queryClient = useQueryClient();
  const [tab, setTab] = useState<'single' | 'bulk'>('single');

  // Single backend state
  const [host, setHost] = useState('127.0.0.1');
  const [port, setPort] = useState('');
  const [serverId, setServerId] = useState('');
  const [label, setLabel] = useState('');
  const [notes, setNotes] = useState('');

  // Bulk paste state
  const [bulkText, setBulkText] = useState('');
  const [parsedRows, setParsedRows] = useState<Array<{ host: string; port: number; label?: string; valid: boolean; error?: string }>>([]);

  const { data: servers = [] } = useQuery<ServerType[]>({
    queryKey: ['servers-for-backends'],
    queryFn: () => apiRequest('/servers'),
    enabled: isOpen
  });

  const handleParseBulk = (text: string) => {
    setBulkText(text);
    const lines = text.split('\n').map((l) => l.trim()).filter(Boolean);
    const rows = lines.map((line) => {
      let h = '';
      let p = 0;
      let lbl = '';

      if (line.includes(':')) {
        const parts = line.split(':');
        h = parts[0].trim();
        p = parseInt(parts[1]?.split(',')[0]?.trim() || '0', 10);
      } else if (line.includes(',')) {
        const parts = line.split(',');
        h = parts[0].trim();
        p = parseInt(parts[1]?.trim() || '0', 10);
        lbl = parts[2]?.trim() || '';
      }

      const valid = Boolean(h && p > 0 && p <= 65535);
      return {
        host: h,
        port: p,
        label: lbl || `${h}:${p}`,
        valid,
        error: !valid ? 'Invalid host or port number' : undefined
      };
    });
    setParsedRows(rows);
  };

  const createSingleMutation = useMutation({
    mutationFn: (data: any) =>
      apiRequest('/backends', {
        method: 'POST',
        body: JSON.stringify(data)
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['backends'] });
      queryClient.invalidateQueries({ queryKey: ['topology'] });
      resetAndClose();
    }
  });

  const createBulkMutation = useMutation({
    mutationFn: (backendsList: any[]) =>
      apiRequest('/backends/bulk', {
        method: 'POST',
        body: JSON.stringify({ backendsList })
      }),
    onSuccess: (res) => {
      queryClient.invalidateQueries({ queryKey: ['backends'] });
      queryClient.invalidateQueries({ queryKey: ['topology'] });
      alert(`Successfully added ${res.count} backends!`);
      resetAndClose();
    }
  });

  const resetAndClose = () => {
    setHost('127.0.0.1');
    setPort('');
    setServerId('');
    setLabel('');
    setNotes('');
    setBulkText('');
    setParsedRows([]);
    onClose();
  };

  const handleSingleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const portNum = parseInt(port, 10);
    if (!host.trim() || isNaN(portNum)) return;

    createSingleMutation.mutate({
      host: host.trim(),
      port: portNum,
      serverId: serverId || undefined,
      label: label.trim() || `${host.trim()}:${portNum}`,
      notes: notes.trim()
    });
  };

  const handleBulkSubmit = () => {
    const validRows = parsedRows.filter((r) => r.valid).map((r) => ({
      host: r.host,
      port: r.port,
      label: r.label
    }));

    if (validRows.length === 0) return;
    createBulkMutation.mutate(validRows);
  };

  if (!isOpen) return null;

  return (
    <Modal isOpen={isOpen} onClose={resetAndClose} title="Add Upstream Backend">
      <div className="space-y-4">
        {/* Tab switch */}
        <div className="flex border-b border-border text-xs">
          <button
            onClick={() => setTab('single')}
            className={`px-4 py-2 font-medium border-b-2 transition-colors ${
              tab === 'single'
                ? 'border-primary text-primary'
                : 'border-transparent text-text-muted hover:text-text'
            }`}
          >
            Single Backend
          </button>
          <button
            onClick={() => setTab('bulk')}
            className={`px-4 py-2 font-medium border-b-2 transition-colors ${
              tab === 'bulk'
                ? 'border-primary text-primary'
                : 'border-transparent text-text-muted hover:text-text'
            }`}
          >
            Bulk Paste
          </button>
        </div>

        {tab === 'single' ? (
          <form onSubmit={handleSingleSubmit} className="space-y-3 text-xs">
            <div className="grid grid-cols-3 gap-3">
              <div className="col-span-2">
                <label className="block text-text font-semibold mb-1">Host / IP *</label>
                <input
                  type="text"
                  required
                  placeholder="127.0.0.1 or app-cluster.internal"
                  value={host}
                  onChange={(e) => setHost(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
                />
              </div>

              <div>
                <label className="block text-text font-semibold mb-1">Port *</label>
                <input
                  type="number"
                  required
                  min="1"
                  max="65535"
                  placeholder="8080"
                  value={port}
                  onChange={(e) => setPort(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
                />
              </div>
            </div>

            <div>
              <label className="block text-text font-semibold mb-1">Server Cluster</label>
              <select
                value={serverId}
                onChange={(e) => setServerId(e.target.value)}
                className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
              >
                <option value="">Unassigned / Default</option>
                {servers.map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.name} ({s.host || 'no host'})
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-text font-semibold mb-1">Label / Service Name</label>
              <input
                type="text"
                placeholder="e.g. Auth Microservice, Redis Cache"
                value={label}
                onChange={(e) => setLabel(e.target.value)}
                className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
              />
            </div>

            <div>
              <label className="block text-text font-semibold mb-1">Notes</label>
              <input
                type="text"
                placeholder="Optional notes"
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
              />
            </div>

            <div className="flex justify-end gap-2 pt-3 border-t border-border">
              <Button type="button" variant="secondary" size="sm" onClick={resetAndClose}>
                Cancel
              </Button>
              <Button
                type="submit"
                variant="primary"
                size="sm"
                isLoading={createSingleMutation.isPending}
              >
                Create Backend
              </Button>
            </div>
          </form>
        ) : (
          <div className="space-y-3 text-xs">
            <p className="text-text-muted">
              Paste lines in format: <code className="font-mono text-text bg-surface-2 px-1 rounded">host:port</code> or <code className="font-mono text-text bg-surface-2 px-1 rounded">host, port, label</code>
            </p>
            <textarea
              rows={5}
              placeholder="127.0.0.1:8080&#10;10.0.0.5:3000, Web Node 1&#10;10.0.0.6:3000, Web Node 2"
              value={bulkText}
              onChange={(e) => handleParseBulk(e.target.value)}
              className="w-full p-2.5 font-mono text-xs rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
            />

            {parsedRows.length > 0 && (
              <div className="max-h-48 overflow-y-auto border border-border rounded-lg">
                <table className="w-full text-left text-[11px]">
                  <thead className="bg-surface-2 border-b border-border text-text-muted uppercase">
                    <tr>
                      <th className="p-2">Status</th>
                      <th className="p-2">Host</th>
                      <th className="p-2">Port</th>
                      <th className="p-2">Label</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border/60">
                    {parsedRows.map((r, i) => (
                      <tr key={i} className="hover:bg-surface-2/40">
                        <td className="p-2">
                          {r.valid ? (
                            <span className="text-status-up flex items-center gap-1">
                              <CheckCircle2 className="w-3 h-3" /> Valid
                            </span>
                          ) : (
                            <span className="text-status-down flex items-center gap-1" title={r.error}>
                              <AlertTriangle className="w-3 h-3" /> Error
                            </span>
                          )}
                        </td>
                        <td className="p-2 font-mono text-text">{r.host}</td>
                        <td className="p-2 font-mono text-text-muted">{r.port}</td>
                        <td className="p-2 text-text">{r.label}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            <div className="flex justify-between items-center pt-3 border-t border-border">
              <span className="text-text-muted">
                {parsedRows.filter((r) => r.valid).length} valid of {parsedRows.length} rows
              </span>
              <div className="flex gap-2">
                <Button type="button" variant="secondary" size="sm" onClick={resetAndClose}>
                  Cancel
                </Button>
                <Button
                  type="button"
                  variant="primary"
                  size="sm"
                  onClick={handleBulkSubmit}
                  disabled={parsedRows.filter((r) => r.valid).length === 0}
                  isLoading={createBulkMutation.isPending}
                >
                  Import {parsedRows.filter((r) => r.valid).length} Backends
                </Button>
              </div>
            </div>
          </div>
        )}
      </div>
    </Modal>
  );
}
