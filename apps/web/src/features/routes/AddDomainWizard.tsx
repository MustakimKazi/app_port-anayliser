import React, { useState } from 'react';
import { useMutation, useQueryClient, useQuery } from '@tanstack/react-query';
import { X, Plus, Globe, ArrowRight, ArrowLeft, CheckCircle2, AlertTriangle } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Button } from '../../components/ui/Button';
import { Modal } from '../../components/ui/Modal';

interface WizardRouteRow {
  key: number;
  path: string;
  action: string;
  portNum: string;
  targetRaw: string;
}

interface AddDomainWizardProps {
  isOpen: boolean;
  onClose: () => void;
}

let rowKey = 0;
const emptyRow = (): WizardRouteRow => ({ key: rowKey++, path: '/', action: 'Proxy', portNum: '', targetRaw: '' });

const DOMAIN_RE = /^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$/i;

function rowErrors(row: WizardRouteRow): string | null {
  if (!row.path.startsWith('/')) return 'Path must start with /';
  if (row.portNum && !(Number(row.portNum) >= 1 && Number(row.portNum) <= 65535 && Number.isInteger(Number(row.portNum))))
    return 'Port must be 1–65535';
  if (row.action === 'Proxy' && !row.targetRaw.trim()) return 'Proxy needs a target (upstream or URL)';
  if (row.action === 'Redirect' && !row.targetRaw.trim()) return 'Redirect needs a target URL';
  if ((row.action === 'Return' || row.action === 'Status') && !row.targetRaw.trim())
    return `${row.action} needs a value (code/body or status)`;
  return null;
}

export function AddDomainWizard({ isOpen, onClose }: AddDomainWizardProps) {
  const queryClient = useQueryClient();
  const [step, setStep] = useState<1 | 2 | 3>(1);
  const [domain, setDomain] = useState('');
  const [domainTouched, setDomainTouched] = useState(false);
  const [rows, setRows] = useState<WizardRouteRow[]>([emptyRow()]);

  // Detect if domain already exists (step 1 validation aid)
  const { data: existing, isFetching: domainChecking, isError: domainIsNew } = useQuery<{ counts: { routes: number } }>({
    queryKey: ['domain-detail', domain.trim().toLowerCase() || '__none__'],
    queryFn: () => apiRequest(`/domains/${encodeURIComponent(domain.trim().toLowerCase())}`),
    enabled: isOpen && step === 1 && DOMAIN_RE.test(domain.trim()),
    retry: false
  });

  const createMutation = useMutation({
    mutationFn: (routesList: any[]) =>
      apiRequest('/routes/bulk', { method: 'POST', body: JSON.stringify({ routesList }) }),
    onSuccess: (res: any, routesList: any[]) => {
      queryClient.invalidateQueries({ queryKey: ['routes'] });
      queryClient.invalidateQueries({ queryKey: ['domains'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
      window.dispatchEvent(
        new CustomEvent('app-toast', { detail: `Domain ${domain.trim()} created — ${res?.count ?? routesList.length} routes added` })
      );
      resetAndClose();
    },
    onError: (err: any) => {
      window.dispatchEvent(new CustomEvent('app-toast', { detail: `Failed: ${err?.message || 'unknown error'}` }));
    }
  });

  const resetAndClose = () => {
    setStep(1);
    setDomain('');
    setDomainTouched(false);
    setRows([emptyRow()]);
    onClose();
  };

  const handleClose = () => {
    if (createMutation.isPending) return;
    resetAndClose();
  };

  const normalizedDomain = domain.trim().toLowerCase();
  const domainValid = DOMAIN_RE.test(normalizedDomain);
  const domainError = domainTouched && !domainValid ? 'Enter a valid domain name (e.g. example.com)' : undefined;
  const domainExists = step === 1 && domainValid && existing?.counts;

  const rowsValid = rows.length > 0 && rows.every((r) => !rowErrors(r));

  const updateRow = (key: number, patch: Partial<WizardRouteRow>) => {
    setRows((prev) => prev.map((r) => (r.key === key ? { ...r, ...patch } : r)));
  };

  const gotoStep2 = () => {
    setDomainTouched(true);
    if (!domainValid) return;
    setStep(2);
  };

  const submit = () => {
    if (!rowsValid || !domainValid) return;
    const routesList = rows.map((r) => ({
      domain: normalizedDomain,
      path: r.path.trim() || '/',
      action: r.action,
      portNum: r.portNum ? Number(r.portNum) : null,
      targetRaw: r.targetRaw.trim(),
      targetType:
        r.action === 'Proxy'
          ? /^https?:\/\//.test(r.targetRaw.trim())
            ? 'url'
            : r.targetRaw.trim().startsWith('$')
              ? 'variable'
              : 'upstream'
          : r.action === 'Redirect'
            ? 'redirect'
            : r.action === 'Static'
              ? 'static_root'
              : 'status',
      protocol: r.portNum && [443, 8443].includes(Number(r.portNum)) ? 'HTTPS' : 'HTTP',
      notes: ''
    }));
    createMutation.mutate(routesList);
  };

  const stepBadge = (n: 1 | 2 | 3, label: string) => (
    <div className="flex items-center gap-1.5">
      <span
        className={`w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold ${
          step >= n ? 'bg-primary text-on-primary' : 'bg-surface-2 text-text-muted border border-border'
        }`}
      >
        {n}
      </span>
      <span className={`text-[11px] ${step >= n ? 'text-text font-semibold' : 'text-text-muted'}`}>{label}</span>
    </div>
  );

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Add Domain">
      <div className="space-y-5" data-testid="add-domain-wizard">
        {/* Stepper */}
        <div className="flex items-center gap-4 pb-3 border-b border-border">
          {stepBadge(1, 'Domain')}
          <div className="h-px flex-1 bg-border" />
          {stepBadge(2, 'Routes')}
          <div className="h-px flex-1 bg-border" />
          {stepBadge(3, 'Review')}
        </div>

        {/* STEP 1: domain */}
        {step === 1 && (
          <div className="space-y-3">
            <div>
              <label className="block text-xs font-medium text-text-muted mb-1">Domain name</label>
              <div className="relative">
                <Globe className="w-4 h-4 text-text-muted absolute left-3 top-2.5" />
                <input
                  type="text"
                  value={domain}
                  onChange={(e) => {
                    setDomain(e.target.value);
                    setDomainTouched(true);
                  }}
                  onBlur={() => setDomainTouched(true)}
                  onKeyDown={(e) => e.key === 'Enter' && gotoStep2()}
                  placeholder="example.com"
                  data-testid="wizard-domain-input"
                  className="w-full pl-9 pr-3 py-2 rounded-lg bg-surface border border-border-strong text-sm font-mono text-text placeholder-text-muted focus:outline-none focus:border-primary"
                  autoFocus
                />
              </div>
              {domainError && (
                <p className="text-[11px] text-status-down mt-1 flex items-center gap-1" data-testid="wizard-domain-error">
                  <AlertTriangle className="w-3 h-3" />
                  {domainError}
                </p>
              )}
              {!domainError && domainValid && domainChecking && (
                <p className="text-[11px] text-text-muted mt-1">Checking if domain exists…</p>
              )}
              {!domainError && domainValid && existing?.counts && (
                <p className="text-[11px] text-status-slow mt-1 flex items-center gap-1" data-testid="wizard-domain-exists">
                  <AlertTriangle className="w-3 h-3" />
                  Domain already exists with {existing.counts.routes} routes — you can still add more paths below.
                </p>
              )}
              {!domainError && domainValid && !domainChecking && (domainIsNew || existing === undefined) && (
                <p className="text-[11px] text-status-up mt-1 flex items-center gap-1" data-testid="wizard-domain-new">
                  <CheckCircle2 className="w-3 h-3" />
                  New domain — looks good.
                </p>
              )}
            </div>
            <div className="flex justify-end gap-2 pt-1">
              <Button variant="ghost" size="sm" onClick={handleClose}>
                Cancel
              </Button>
              <Button
                variant="primary"
                size="sm"
                className="flex items-center gap-1.5"
                onClick={gotoStep2}
                disabled={!domainValid}
              >
                Next: Routes
                <ArrowRight className="w-3.5 h-3.5" />
              </Button>
            </div>
          </div>
        )}

        {/* STEP 2: routes */}
        {step === 2 && (
          <div className="space-y-3">
            <div className="text-xs text-text-muted">
              Adding routes for <span className="font-mono text-text font-semibold">{normalizedDomain}</span>
            </div>

            <div className="space-y-2 max-h-72 overflow-y-auto pr-1" data-testid="wizard-rows">
              {rows.map((row) => {
                const err = rowErrors(row);
                return (
                  <div key={row.key} className="p-2.5 rounded-lg border border-border bg-surface-2/50 space-y-2" data-testid="wizard-row">
                    <div className="grid grid-cols-12 gap-2">
                      <div className="col-span-3">
                        <input
                          type="text"
                          value={row.path}
                          onChange={(e) => updateRow(row.key, { path: e.target.value })}
                          placeholder="/path"
                          aria-label="Path"
                          className="w-full px-2 py-1.5 rounded bg-surface border border-border-strong text-xs font-mono text-text focus:outline-none focus:border-primary"
                        />
                      </div>
                      <div className="col-span-3">
                        <select
                          value={row.action}
                          onChange={(e) => updateRow(row.key, { action: e.target.value })}
                          aria-label="Action"
                          className="w-full px-2 py-1.5 rounded bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
                        >
                          <option value="Proxy">Proxy</option>
                          <option value="Static">Static</option>
                          <option value="Redirect">Redirect</option>
                          <option value="Return">Return</option>
                          <option value="Status">Status</option>
                        </select>
                      </div>
                      <div className="col-span-2">
                        <input
                          type="text"
                          value={row.portNum}
                          onChange={(e) => updateRow(row.key, { portNum: e.target.value.replace(/\D/g, '') })}
                          placeholder="port"
                          aria-label="Port"
                          className="w-full px-2 py-1.5 rounded bg-surface border border-border-strong text-xs font-mono text-text focus:outline-none focus:border-primary"
                        />
                      </div>
                      <div className="col-span-3">
                        <input
                          type="text"
                          value={row.targetRaw}
                          onChange={(e) => updateRow(row.key, { targetRaw: e.target.value })}
                          placeholder="target / upstream"
                          aria-label="Target"
                          className="w-full px-2 py-1.5 rounded bg-surface border border-border-strong text-xs font-mono text-text focus:outline-none focus:border-primary"
                        />
                      </div>
                      <div className="col-span-1 flex justify-end">
                        <button
                          onClick={() => setRows((prev) => (prev.length > 1 ? prev.filter((r) => r.key !== row.key) : prev))}
                          disabled={rows.length === 1}
                          className="p-1.5 rounded text-text-muted hover:text-status-down disabled:opacity-30 transition-colors"
                          title="Remove route"
                        >
                          <X className="w-3.5 h-3.5" />
                        </button>
                      </div>
                    </div>
                    {err && (
                      <div className="text-[11px] text-status-down flex items-center gap-1">
                        <AlertTriangle className="w-3 h-3" />
                        {err}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>

            <Button
              variant="secondary"
              size="sm"
              className="text-xs flex items-center gap-1.5"
              onClick={() => setRows((prev) => [...prev, emptyRow()])}
            >
              <Plus className="w-3.5 h-3.5" />
              Add another path
            </Button>

            <div className="flex justify-between gap-2 pt-1 border-t border-border">
              <Button variant="ghost" size="sm" className="flex items-center gap-1.5" onClick={() => setStep(1)}>
                <ArrowLeft className="w-3.5 h-3.5" />
                Back
              </Button>
              <Button
                variant="primary"
                size="sm"
                className="flex items-center gap-1.5"
                onClick={() => setStep(3)}
                disabled={!rowsValid}
              >
                Next: Review
                <ArrowRight className="w-3.5 h-3.5" />
              </Button>
            </div>
          </div>
        )}

        {/* STEP 3: review */}
        {step === 3 && (
          <div className="space-y-4">
            <div className="p-3 rounded-lg border border-border bg-surface-2/60 text-xs space-y-2" data-testid="wizard-review">
              <div className="flex items-center justify-between">
                <span className="text-text-muted">Domain</span>
                <span className="font-mono text-text font-bold">{normalizedDomain}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-text-muted">Routes to create</span>
                <span className="font-mono text-text font-bold">{rows.length}</span>
              </div>
              <div className="pt-2 border-t border-border space-y-1">
                {rows.map((r) => (
                  <div key={r.key} className="flex items-center justify-between font-mono text-[11px]">
                    <span className="text-text">
                      {r.path} → {r.targetRaw || '—'}
                    </span>
                    <span className="text-text-muted">
                      {r.action}
                      {r.portNum ? ` :${r.portNum}` : ''}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            <div className="flex justify-between gap-2 pt-1">
              <Button variant="ghost" size="sm" className="flex items-center gap-1.5" onClick={() => setStep(2)}>
                <ArrowLeft className="w-3.5 h-3.5" />
                Back
              </Button>
              <div className="flex gap-2">
                <Button variant="ghost" size="sm" onClick={handleClose}>
                  Cancel
                </Button>
                <Button
                  variant="primary"
                  size="sm"
                  disabled={!rowsValid || createMutation.isPending}
                  isLoading={createMutation.isPending}
                  onClick={submit}
                  data-testid="wizard-submit"
                >
                  Create {rows.length} route{rows.length === 1 ? '' : 's'}
                </Button>
              </div>
            </div>
          </div>
        )}
      </div>
    </Modal>
  );
}
