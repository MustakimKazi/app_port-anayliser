import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { X, Plus, Upload, CheckCircle2, AlertTriangle, Layers } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Button } from '../../components/ui/Button';
import { Modal } from '../../components/ui/Modal';
import { Port, Backend } from '../../types';

interface AddRouteDialogProps {
  isOpen: boolean;
  onClose: () => void;
}

export function AddRouteDialog({ isOpen, onClose }: AddRouteDialogProps) {
  const queryClient = useQueryClient();
  const [tab, setTab] = useState<'single' | 'bulk'>('single');

  // Single route state
  const [domain, setDomain] = useState('');
  const [path, setPath] = useState('/');
  const [action, setAction] = useState<'Proxy' | 'Static' | 'Redirect'>('Proxy');
  const [protocol, setProtocol] = useState<'HTTP' | 'HTTPS'>('HTTP');
  const [portNum, setPortNum] = useState('');
  const [backendId, setBackendId] = useState('');
  const [targetRaw, setTargetRaw] = useState('');
  const [notes, setNotes] = useState('');

  // Bulk paste state
  const [bulkText, setBulkText] = useState('');
  const [parsedRows, setParsedRows] = useState<Array<{ domain: string; path: string; action: string; target: string; valid: boolean; error?: string }>>([]);

  // Fetch ports and backends
  const { data: portsData } = useQuery<{ data: Port[] }>({
    queryKey: ['active-ports-for-routes'],
    queryFn: () => apiRequest('/ports?limit=100'),
    enabled: isOpen
  });

  const { data: backends = [] } = useQuery<Backend[]>({
    queryKey: ['backends-for-routes'],
    queryFn: () => apiRequest('/backends'),
    enabled: isOpen
  });

  // Parse bulk text
  const handleParseBulk = (text: string) => {
    setBulkText(text);
    const lines = text.split('\n').map((l) => l.trim()).filter(Boolean);
    const rows = lines.map((line) => {
      const parts = line.split(',').map((p) => p.trim());
      const d = parts[0] || '';
      const p = parts[1] || '/';
      const a = parts[2] || 'Proxy';
      const t = parts[3] || '';

      const valid = Boolean(d && d.includes('.'));
      return {
        domain: d,
        path: p,
        action: a,
        target: t,
        valid,
        error: !valid ? 'Invalid domain name' : undefined
      };
    });
    setParsedRows(rows);
  };

  // Mutations
  const createSingleMutation = useMutation({
    mutationFn: (data: any) =>
      apiRequest('/routes', {
        method: 'POST',
        body: JSON.stringify(data)
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['routes'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
      resetAndClose();
    }
  });

  const createBulkMutation = useMutation({
    mutationFn: (routesList: any[]) =>
      apiRequest('/routes/bulk', {
        method: 'POST',
        body: JSON.stringify({ routesList })
      }),
    onSuccess: (res) => {
      queryClient.invalidateQueries({ queryKey: ['routes'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
      alert(`Successfully added ${res.count} routes!`);
      resetAndClose();
    }
  });

  const resetAndClose = () => {
    setDomain('');
    setPath('/');
    setAction('Proxy');
    setProtocol('HTTP');
    setPortNum('');
    setBackendId('');
    setTargetRaw('');
    setNotes('');
    setBulkText('');
    setParsedRows([]);
    onClose();
  };

  const handleSingleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!domain.trim()) return;

    createSingleMutation.mutate({
      domain: domain.trim(),
      path: path.trim() || '/',
      action,
      protocol,
      portNum: portNum ? parseInt(portNum, 10) : undefined,
      backendId: backendId || undefined,
      targetRaw: targetRaw.trim(),
      notes: notes.trim()
    });
  };

  const handleBulkSubmit = () => {
    const validRows = parsedRows.filter((r) => r.valid).map((r) => ({
      domain: r.domain,
      path: r.path,
      action: r.action,
      targetRaw: r.target
    }));

    if (validRows.length === 0) return;
    createBulkMutation.mutate(validRows);
  };

  if (!isOpen) return null;

  return (
    <Modal isOpen={isOpen} onClose={resetAndClose} title="Add Domain Route">
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
            Single Route
          </button>
          <button
            onClick={() => setTab('bulk')}
            className={`px-4 py-2 font-medium border-b-2 transition-colors ${
              tab === 'bulk'
                ? 'border-primary text-primary'
                : 'border-transparent text-text-muted hover:text-text'
            }`}
          >
            Bulk Paste / Import
          </button>
        </div>

        {tab === 'single' ? (
          <form onSubmit={handleSingleSubmit} className="space-y-3 text-xs">
            <div>
              <label className="block text-text font-semibold mb-1">Domain Name *</label>
              <input
                type="text"
                required
                placeholder="e.g. api.company.internal"
                value={domain}
                onChange={(e) => setDomain(e.target.value)}
                className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-text font-semibold mb-1">Path</label>
                <input
                  type="text"
                  placeholder="/"
                  value={path}
                  onChange={(e) => setPath(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
                />
              </div>

              <div>
                <label className="block text-text font-semibold mb-1">Action</label>
                <select
                  value={action}
                  onChange={(e) => setAction(e.target.value as any)}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
                >
                  <option value="Proxy">Proxy Pass</option>
                  <option value="Static">Static Content</option>
                  <option value="Redirect">Redirect</option>
                </select>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-text font-semibold mb-1">Listening Port</label>
                <select
                  value={portNum}
                  onChange={(e) => setPortNum(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
                >
                  <option value="">Select a port...</option>
                  {portsData?.data?.map((p) => (
                    <option key={p.id} value={p.port}>
                      :{p.port} ({p.purpose || p.layer})
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-text font-semibold mb-1">Target Upstream Backend</label>
                <select
                  value={backendId}
                  onChange={(e) => setBackendId(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
                >
                  <option value="">None / Custom Target</option>
                  {backends.map((b) => (
                    <option key={b.id} value={b.id}>
                      {b.label || `${b.host}:${b.port}`} ({b.host}:{b.port})
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div>
              <label className="block text-text font-semibold mb-1">Target URL / Raw Value</label>
              <input
                type="text"
                placeholder="http://127.0.0.1:8080 or /var/www/html"
                value={targetRaw}
                onChange={(e) => setTargetRaw(e.target.value)}
                className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
              />
            </div>

            <div>
              <label className="block text-text font-semibold mb-1">Notes</label>
              <input
                type="text"
                placeholder="Optional notes or routing context"
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
                Create Route
              </Button>
            </div>
          </form>
        ) : (
          <div className="space-y-3 text-xs">
            <p className="text-text-muted">
              Paste lines in format: <code className="font-mono text-text bg-surface-2 px-1 rounded">domain, path, action, backend</code>
            </p>
            <textarea
              rows={5}
              placeholder="api.example.com, /v1, Proxy, 127.0.0.1:3000&#10;app.example.com, /, Static, /var/www/app"
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
                      <th className="p-2">Domain</th>
                      <th className="p-2">Path</th>
                      <th className="p-2">Action</th>
                      <th className="p-2">Target</th>
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
                        <td className="p-2 font-mono text-text">{r.domain}</td>
                        <td className="p-2 font-mono text-text-muted">{r.path}</td>
                        <td className="p-2 text-text">{r.action}</td>
                        <td className="p-2 font-mono text-text-muted truncate max-w-xs">{r.target || '—'}</td>
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
                  Import {parsedRows.filter((r) => r.valid).length} Routes
                </Button>
              </div>
            </div>
          </div>
        )}
      </div>
    </Modal>
  );
}
