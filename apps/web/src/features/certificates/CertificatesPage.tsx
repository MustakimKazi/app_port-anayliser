import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Shield,
  ShieldAlert,
  ShieldCheck,
  Clock,
  RefreshCw,
  Globe,
  Copy,
  Check,
  Trash2,
  RotateCcw,
  AlertTriangle,
  ExternalLink,
  MoreVertical
} from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Drawer } from '../../components/ui/Drawer';
import { Modal } from '../../components/ui/Modal';
import { DropdownMenu } from '../../components/ui/DropdownMenu';
import { ActionBadge } from '../../components/ui/Badge';
import { CertificateInfo } from '../../types';

interface CertDetailResponse {
  certificate: CertificateInfo;
  routes: Array<{
    id: string;
    path: string;
    portNum: number | null;
    protocol: string;
    action: string;
    configFile?: { filename: string } | null;
  }>;
}

function statusColor(c: CertificateInfo): { text: string; bg: string; border: string; bar: string } {
  if (c.daysRemaining <= 7)
    return { text: 'text-status-down', bg: 'bg-status-down/10', border: 'border-status-down/30', bar: 'bg-status-down' };
  if (c.daysRemaining <= 30)
    return { text: 'text-status-slow', bg: 'bg-status-slow/10', border: 'border-status-slow/30', bar: 'bg-status-slow' };
  return { text: 'text-status-up', bg: 'bg-status-up/10', border: 'border-status-up/30', bar: 'bg-status-up' };
}

function CopyableField({ label, value, mono = true }: { label: string; value?: string | null; mono?: boolean }) {
  const [copied, setCopied] = useState(false);
  if (!value) return null;
  return (
    <div className="p-3 rounded-lg border border-border bg-surface-2/60">
      <span className="text-text-muted">{label}</span>
      <div className="flex items-start justify-between gap-2 mt-1">
        <p className={`${mono ? 'font-mono' : ''} text-text text-[11px] break-all`}>{value}</p>
        <button
          onClick={() => {
            navigator.clipboard.writeText(value);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
          }}
          className="p-1 rounded text-text-muted hover:text-text hover:bg-surface transition-colors shrink-0"
          title={`Copy ${label}`}
          aria-label={`Copy ${label}`}
        >
          {copied ? <Check className="w-3.5 h-3.5 text-status-up" /> : <Copy className="w-3.5 h-3.5" />}
        </button>
      </div>
    </div>
  );
}

export function CertificatesPage() {
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<'monitored' | 'excluded'>('monitored');
  const [certToDelete, setCertToDelete] = useState<CertificateInfo | null>(null);
  const [archiveRoutesOnDelete, setArchiveRoutesOnDelete] = useState(true);

  const { data: certs = [], isLoading, refetch, isRefetching } = useQuery<CertificateInfo[]>({
    queryKey: ['certificates'],
    queryFn: () => apiRequest('/certificates')
  });

  const { data: excludedCerts = [], isLoading: isLoadingExcluded, refetch: refetchExcluded } = useQuery<Array<{
    id: string;
    entityId: string;
    entityName: string;
    data: any;
    createdAt: string;
  }>>({
    queryKey: ['certificates-excluded'],
    queryFn: () => apiRequest('/certificates/excluded')
  });

  const [selected, setSelected] = useState<CertificateInfo | null>(null);

  const detailQuery = useQuery<CertDetailResponse>({
    queryKey: ['cert-detail', selected?.domain, selected?.port],
    queryFn: () =>
      apiRequest(
        `/certificates/${encodeURIComponent(selected!.domain)}?port=${selected!.port}`
      ),
    enabled: !!selected
  });

  const reprobe = useMutation({
    mutationFn: () =>
      apiRequest(
        `/certificates/${encodeURIComponent(selected!.domain)}?port=${selected!.port}`
      ),
    onSuccess: (data) => {
      if (selected) {
        queryClient.setQueryData(['cert-detail', selected.domain, selected.port], data);
      }
      refetch();
    }
  });

  const deleteCertMutation = useMutation({
    mutationFn: ({ domain, port, archiveRoutes }: { domain: string; port?: number; archiveRoutes?: boolean }) =>
      apiRequest(
        `/certificates/${encodeURIComponent(domain)}?port=${port || 443}&archiveRoutes=${archiveRoutes ? 'true' : 'false'}`,
        { method: 'DELETE' }
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['certificates'] });
      queryClient.invalidateQueries({ queryKey: ['certificates-excluded'] });
      queryClient.invalidateQueries({ queryKey: ['routes'] });
      setCertToDelete(null);
      setSelected(null);
    }
  });

  const restoreCertMutation = useMutation({
    mutationFn: (domain: string) =>
      apiRequest(`/certificates/${encodeURIComponent(domain)}/restore`, {
        method: 'POST',
        body: JSON.stringify({ restoreRoutes: true })
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['certificates'] });
      queryClient.invalidateQueries({ queryKey: ['certificates-excluded'] });
      queryClient.invalidateQueries({ queryKey: ['routes'] });
    }
  });

  const detail = detailQuery.data?.certificate;
  const coveredRoutes = detailQuery.data?.routes || [];
  const colors = detail ? statusColor(detail) : null;
  const validityTotal =
    detail && detail.validFrom && detail.validTo
      ? Math.max(1, (new Date(detail.validTo).getTime() - new Date(detail.validFrom).getTime()) / 86400000)
      : 90;
  const percentLeft = detail ? Math.min(100, Math.max(0, Math.round((detail.daysRemaining / validityTotal) * 100))) : 0;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
            <span>TLS / SSL Certificates</span>
            <span className="text-xs font-mono font-medium px-2 py-0.5 rounded-full bg-surface-2 text-primary border border-border">
              {certs.length} active
            </span>
          </h1>
          <p className="text-xs text-text-muted mt-1">
            Real-time peer certificate expiration tracking, issuers, and automated warning thresholds.
          </p>
        </div>

        <div className="flex items-center gap-2">
          {/* Tab Filter Pills */}
          <div className="flex items-center gap-1 p-1 rounded-lg bg-surface border border-border text-xs">
            <button
              onClick={() => setActiveTab('monitored')}
              className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
                activeTab === 'monitored'
                  ? 'bg-primary text-on-primary'
                  : 'text-text-muted hover:text-text'
              }`}
            >
              Monitored ({certs.length})
            </button>
            <button
              onClick={() => setActiveTab('excluded')}
              className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
                activeTab === 'excluded'
                  ? 'bg-status-down text-on-primary'
                  : 'text-text-muted hover:text-text'
              }`}
            >
              Excluded / Deleted ({excludedCerts.length})
            </button>
          </div>

          <Button variant="secondary" size="sm" onClick={() => refetch()} isLoading={isRefetching}>
            <RefreshCw className="w-3.5 h-3.5" />
            <span>Re-inspect</span>
          </Button>
        </div>
      </div>

      {activeTab === 'monitored' && (
        <>
          {/* Expiry summary badges */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="p-4 rounded-xl border border-status-up/30 bg-status-up/10 flex items-center gap-3">
              <ShieldCheck className="w-8 h-8 text-status-up" />
              <div>
                <span className="text-xs text-status-up font-medium">Valid (&gt;30 Days)</span>
                <div className="text-xl font-bold font-mono text-text mt-0.5">
                  {certs.filter((c) => c.daysRemaining > 30).length} certs
                </div>
              </div>
            </div>

            <div className="p-4 rounded-xl border border-status-slow/30 bg-status-slow/10 flex items-center gap-3">
              <Clock className="w-8 h-8 text-status-slow" />
              <div>
                <span className="text-xs text-status-slow font-medium">Expiring Soon (≤30 Days)</span>
                <div className="text-xl font-bold font-mono text-text mt-0.5">
                  {certs.filter((c) => c.daysRemaining <= 30 && c.daysRemaining > 7).length} certs
                </div>
              </div>
            </div>

            <div className="p-4 rounded-xl border border-status-down/30 bg-status-down/10 flex items-center gap-3">
              <ShieldAlert className="w-8 h-8 text-status-down" />
              <div>
                <span className="text-xs text-status-down font-medium">Critical / Expired (≤7 Days)</span>
                <div className="text-xl font-bold font-mono text-text mt-0.5">
                  {certs.filter((c) => c.daysRemaining <= 7).length} certs
                </div>
              </div>
            </div>
          </div>

          {/* Certificates Table */}
          <Card className="overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs text-text">
                <thead className="bg-surface-2 text-[11px] uppercase tracking-wider text-text-muted border-b border-border">
                  <tr>
                    <th className="py-3 px-4">Domain</th>
                    <th className="py-3 px-4">Port</th>
                    <th className="py-3 px-4">Issuer</th>
                    <th className="py-3 px-4">Expiration Date</th>
                    <th className="py-3 px-4">Days Left</th>
                    <th className="py-3 px-4 w-40">Status Bar</th>
                    <th className="py-3 px-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border/60 font-sans">
                  {certs.map((c) => {
                    const percent = Math.min(100, Math.max(0, Math.round((c.daysRemaining / 90) * 100)));
                    const isCritical = c.daysRemaining <= 7;
                    const isWarning = c.daysRemaining <= 30 && !isCritical;

                    return (
                      <tr
                        key={`${c.domain}-${c.port}`}
                        className="hover:bg-surface-2/60 transition-colors"
                        data-testid="cert-row"
                      >
                        <td
                          onClick={() => setSelected(c)}
                          className="py-3 px-4 font-mono font-bold text-text flex items-center gap-2 cursor-pointer"
                        >
                          <Shield className={`w-4 h-4 ${isCritical ? 'text-status-down' : isWarning ? 'text-status-slow' : 'text-status-up'}`} />
                          <span className="hover:underline">{c.domain}</span>
                        </td>
                        <td className="py-3 px-4 font-mono text-text-muted">:{c.port}</td>
                        <td className="py-3 px-4 text-text">{c.issuer}</td>
                        <td className="py-3 px-4 font-mono text-text-muted">
                          {c.validTo ? new Date(c.validTo).toLocaleDateString() : '—'}
                        </td>
                        <td className="py-3 px-4 font-mono font-bold">
                          <span className={isCritical ? 'text-status-down' : isWarning ? 'text-status-slow' : 'text-status-up'}>
                            {c.daysRemaining} days
                          </span>
                        </td>
                        <td className="py-3 px-4">
                          <div className="w-full bg-surface-2 rounded-full h-2 overflow-hidden border border-border">
                            <div
                              className={`h-full transition-all duration-500 ${
                                isCritical ? 'bg-status-down' : isWarning ? 'bg-status-slow' : 'bg-status-up'
                              }`}
                              style={{ width: `${percent}%` }}
                            />
                          </div>
                        </td>
                        <td className="py-3 px-4 text-right">
                          <div className="flex items-center justify-end gap-1.5">
                            <button
                              onClick={() => setSelected(c)}
                              className="px-2.5 py-1 rounded-md text-[11px] font-medium bg-surface-2 hover:bg-surface border border-border text-text transition-colors"
                              title="Inspect certificate details"
                            >
                              Inspect
                            </button>
                            <DropdownMenu
                              title="Certificate actions"
                              items={[
                                {
                                  label: 'Inspect Details',
                                  icon: <ExternalLink className="w-3.5 h-3.5" />,
                                  onClick: () => setSelected(c)
                                },
                                {
                                  label: 'Unmonitor & Delete',
                                  icon: <Trash2 className="w-3.5 h-3.5" />,
                                  variant: 'danger',
                                  onClick: () => setCertToDelete(c)
                                }
                              ]}
                            />
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                  {!isLoading && certs.length === 0 && (
                    <tr>
                      <td colSpan={7} className="py-10 text-center text-text-muted">
                        No active HTTPS routes found — certificates appear after a scan or manual inspection.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </Card>
        </>
      )}

      {activeTab === 'excluded' && (
        <Card className="overflow-hidden">
          <div className="p-4 border-b border-border bg-surface-2/40 flex items-center justify-between">
            <div className="text-xs text-text-muted">
              Certificates excluded from TLS expiration monitoring. PortWatch will not probe or alert on these domains.
            </div>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-text">
              <thead className="bg-surface-2 text-[11px] uppercase tracking-wider text-text-muted border-b border-border">
                <tr>
                  <th className="py-3 px-4">Domain / Target</th>
                  <th className="py-3 px-4">Deleted By</th>
                  <th className="py-3 px-4">Deleted At</th>
                  <th className="py-3 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border/60 font-sans">
                {excludedCerts.map((ex) => (
                  <tr key={ex.id} className="hover:bg-surface-2/60 transition-colors">
                    <td className="py-3 px-4 font-mono font-semibold text-text">
                      <div className="flex items-center gap-2">
                        <ShieldAlert className="w-4 h-4 text-text-muted" />
                        <span>{ex.entityName || ex.entityId}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4 text-text-muted font-mono">{ex.data?.deletedBy || 'admin'}</td>
                    <td className="py-3 px-4 text-text-muted font-mono">
                      {new Date(ex.createdAt).toLocaleString()}
                    </td>
                    <td className="py-3 px-4 text-right">
                      <Button
                        variant="secondary"
                        size="sm"
                        className="text-[11px] flex items-center gap-1.5 ml-auto"
                        onClick={() => restoreCertMutation.mutate(ex.entityId)}
                        isLoading={restoreCertMutation.isPending}
                      >
                        <RotateCcw className="w-3.5 h-3.5" />
                        <span>Restore to Monitoring</span>
                      </Button>
                    </td>
                  </tr>
                ))}
                {!isLoadingExcluded && excludedCerts.length === 0 && (
                  <tr>
                    <td colSpan={4} className="py-12 text-center text-text-muted">
                      No excluded certificates. All configured certificates are actively monitored.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {/* Detail Drawer */}
      <Drawer
        isOpen={!!selected}
        onClose={() => setSelected(null)}
        title={
          <div className="flex items-center gap-2">
            <Shield className="w-5 h-5 text-primary" />
            <span className="font-mono">{selected?.domain}</span>
          </div>
        }
        subtitle={selected ? `TLS certificate on port :${selected.port}` : undefined}
      >
        {detailQuery.isLoading && (
          <div className="space-y-4 animate-pulse" data-testid="cert-detail-loading">
            <div className="h-20 rounded-xl bg-surface-2" />
            <div className="grid grid-cols-2 gap-3">
              <div className="h-16 rounded-lg bg-surface-2" />
              <div className="h-16 rounded-lg bg-surface-2" />
              <div className="h-16 rounded-lg bg-surface-2" />
              <div className="h-16 rounded-lg bg-surface-2" />
            </div>
          </div>
        )}

        {detailQuery.isError && (
          <div className="p-4 rounded-xl border border-status-down/30 bg-status-down/10 text-xs text-text space-y-2" data-testid="cert-detail-error">
            <div className="font-semibold text-status-down">Failed to probe certificate</div>
            <div className="text-text-muted">
              {(detailQuery.error as Error)?.message || 'The host did not return a TLS certificate.'}
            </div>
            <Button variant="secondary" size="sm" className="text-xs" onClick={() => reprobe.mutate()} isLoading={reprobe.isPending}>
              <span>Retry probe</span>
            </Button>
          </div>
        )}

        {detail && colors && (
          <div className="space-y-6" data-testid="cert-detail-body">
            {/* Status + countdown */}
            <div className={`p-4 rounded-xl border ${colors.border} ${colors.bg} space-y-3`}>
              <div className="flex items-center justify-between">
                <span className={`text-sm font-bold ${colors.text}`}>
                  {detail.status === 'error'
                    ? 'Probe failed'
                    : detail.daysRemaining <= 0
                      ? 'Certificate expired'
                      : detail.daysRemaining <= 7
                        ? 'Critical — expiring within 7 days'
                        : detail.daysRemaining <= 30
                          ? 'Expiring soon — within 30 days'
                          : 'Valid'}
                </span>
                <span className={`font-mono text-lg font-bold ${colors.text}`}>
                  {detail.daysRemaining} days left
                </span>
              </div>

              {/* Countdown bar */}
              <div className="w-full bg-surface-2 rounded-full h-3 overflow-hidden border border-border" role="progressbar"
                aria-valuenow={percentLeft} aria-valuemin={0} aria-valuemax={100}
                aria-label="Certificate validity remaining">
                <div className={`h-full transition-all duration-500 ${colors.bar}`} style={{ width: `${percentLeft}%` }} />
              </div>

              <div className="grid grid-cols-2 gap-3 text-xs">
                <div className="p-3 rounded-lg bg-surface-2/60 border border-border">
                  <span className="text-text-muted">Valid From</span>
                  <p className="font-mono text-text mt-1">
                    {detail.validFrom ? new Date(detail.validFrom).toLocaleString() : '—'}
                  </p>
                </div>
                <div className="p-3 rounded-lg bg-surface-2/60 border border-border">
                  <span className="text-text-muted">Expires On</span>
                  <p className={`font-mono font-bold mt-1 ${colors.text}`}>
                    {detail.validTo ? new Date(detail.validTo).toLocaleString() : '—'}
                  </p>
                </div>
              </div>
            </div>

            {/* Issuer / subject / TLS info */}
            <div className="grid grid-cols-2 gap-3 text-xs">
              <div className="p-3 rounded-lg border border-border bg-surface-2/60">
                <span className="text-text-muted">Subject (CN)</span>
                <p className="font-mono text-text mt-1 break-all">{detail.subject}</p>
              </div>
              <div className="p-3 rounded-lg border border-border bg-surface-2/60">
                <span className="text-text-muted">Issuer</span>
                <p className="font-mono text-text mt-1 break-all">{detail.issuer}</p>
              </div>
              <div className="p-3 rounded-lg border border-border bg-surface-2/60">
                <span className="text-text-muted">TLS Protocol</span>
                <p className="font-mono text-text mt-1">{detail.protocol || '—'}</p>
              </div>
              <div className="p-3 rounded-lg border border-border bg-surface-2/60">
                <span className="text-text-muted">Cipher</span>
                <p className="font-mono text-text mt-1 break-all">{detail.cipher || '—'}</p>
              </div>
              <div className="p-3 rounded-lg border border-border bg-surface-2/60">
                <span className="text-text-muted">Signature Algorithm</span>
                <p className="font-mono text-text mt-1 break-all">{detail.signatureAlgorithm || '—'}</p>
              </div>
              <div className="p-3 rounded-lg border border-border bg-surface-2/60">
                <span className="text-text-muted">Serial Number</span>
                <p className="font-mono text-text mt-1 break-all">{detail.serialNumber || '—'}</p>
              </div>
            </div>

            {/* SANs */}
            <div className="p-4 rounded-xl border border-border bg-surface-2/40 space-y-2">
              <span className="text-xs font-semibold text-text">Subject Alternative Names</span>
              {detail.san ? (
                <div className="flex flex-wrap gap-1.5">
                  {detail.san
                    .split(',')
                    .map((s) => s.trim().replace(/^DNS:/i, ''))
                    .filter(Boolean)
                    .map((s) => (
                      <span
                        key={s}
                        className="px-2 py-0.5 rounded bg-surface-2 border border-border font-mono text-[11px] text-text"
                      >
                        {s}
                      </span>
                    ))}
                </div>
              ) : (
                <p className="text-xs text-text-muted">No SAN extension reported.</p>
              )}
            </div>

            {/* Fingerprint */}
            <div className="grid grid-cols-1 gap-3 text-xs">
              <CopyableField label="SHA-256 Fingerprint" value={detail.fingerprint256} />
            </div>

            {/* Covered routes */}
            <div className="p-4 rounded-xl border border-border bg-surface-2/40 space-y-2">
              <span className="text-xs font-semibold text-text flex items-center gap-1.5">
                <Globe className="w-4 h-4 text-primary" />
                <span>Routes Covered by this Certificate ({coveredRoutes.length})</span>
              </span>
              {coveredRoutes.length > 0 ? (
                <div className="overflow-x-auto rounded-lg border border-border">
                  <table className="w-full text-left text-[11px]">
                    <thead className="bg-surface-2 text-[10px] uppercase text-text-muted">
                      <tr>
                        <th className="py-2 px-3">Path</th>
                        <th className="py-2 px-3">Port</th>
                        <th className="py-2 px-3">Action</th>
                        <th className="py-2 px-3">Config File</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                      {coveredRoutes.map((r) => (
                        <tr key={r.id}>
                          <td className="py-2 px-3 font-mono text-text">{r.path}</td>
                          <td className="py-2 px-3 font-mono text-text-muted">
                            {r.portNum ? `:${r.portNum}` : '—'}
                          </td>
                          <td className="py-2 px-3">
                            <ActionBadge action={r.action as any} />
                          </td>
                          <td className="py-2 px-3 font-mono text-text-muted">
                            {r.configFile?.filename || '—'}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <p className="text-xs text-text-muted">No active routes found for this domain.</p>
              )}
            </div>

            {detail.error && (
              <div className="p-3 rounded-lg bg-status-down/10 border border-status-down/30 text-xs text-status-down">
                Probe error: {detail.error}
              </div>
            )}

            {/* Actions */}
            <div className="pt-2 border-t border-border flex items-center justify-between">
              <DropdownMenu
                trigger={
                  <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-border text-xs text-text-muted hover:text-text hover:bg-surface-2 transition-colors">
                    <MoreVertical className="w-3.5 h-3.5" />
                    <span>Manage</span>
                  </div>
                }
                items={[
                  {
                    label: 'Unmonitor & Delete Certificate',
                    icon: <Trash2 className="w-3.5 h-3.5" />,
                    variant: 'danger',
                    onClick: () => setCertToDelete(selected)
                  }
                ]}
              />
              <Button
                variant="secondary"
                size="sm"
                className="text-xs flex items-center gap-1.5"
                onClick={() => reprobe.mutate()}
                isLoading={reprobe.isPending}
              >
                <RefreshCw className="w-3.5 h-3.5" />
                <span>Re-probe Certificate</span>
              </Button>
            </div>
          </div>
        )}
      </Drawer>

      {/* Delete / Unmonitor Confirmation Modal */}
      <Modal
        isOpen={!!certToDelete}
        onClose={() => setCertToDelete(null)}
        title="Unmonitor & Delete Certificate"
        footer={
          <div className="flex items-center justify-end gap-2">
            <Button variant="secondary" size="sm" onClick={() => setCertToDelete(null)}>
              Cancel
            </Button>
            <Button
              variant="danger"
              size="sm"
              isLoading={deleteCertMutation.isPending}
              onClick={() => {
                if (certToDelete) {
                  deleteCertMutation.mutate({
                    domain: certToDelete.domain,
                    port: certToDelete.port,
                    archiveRoutes: archiveRoutesOnDelete
                  });
                }
              }}
            >
              Confirm Delete
            </Button>
          </div>
        }
      >
        <div className="space-y-4 text-xs text-text">
          <div className="p-3 rounded-lg bg-status-down/10 border border-status-down/30 text-text">
            <div className="flex items-center gap-2 font-semibold text-status-down mb-1">
              <AlertTriangle className="w-4 h-4 shrink-0" />
              <span>Are you sure you want to stop monitoring this certificate?</span>
            </div>
            <p className="text-text-muted">
              Domain: <strong className="text-text font-mono">{certToDelete?.domain}</strong> (Port: {certToDelete?.port || 443})
            </p>
          </div>

          <p className="text-text-muted leading-relaxed">
            Removing this certificate will exclude it from continuous TLS scanning and alerts. A snapshot will be saved to your Trash / Excluded list so you can restore monitoring anytime.
          </p>

          <label className="flex items-start gap-2.5 p-3 rounded-lg border border-border bg-surface-2/40 cursor-pointer hover:bg-surface-2/70 transition-colors">
            <input
              type="checkbox"
              checked={archiveRoutesOnDelete}
              onChange={(e) => setArchiveRoutesOnDelete(e.target.checked)}
              className="mt-0.5 rounded border-border text-primary focus:ring-primary"
            />
            <div className="space-y-0.5">
              <span className="font-semibold text-text">Archive associated HTTPS routes</span>
              <p className="text-[11px] text-text-muted">
                Move routes referencing this domain to archived status. If unchecked, routes will remain active without TLS monitoring.
              </p>
            </div>
          </label>
        </div>
      </Modal>
    </div>
  );
}
