import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { Shield, ShieldAlert, ShieldCheck, Clock, ExternalLink, RefreshCw } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { CertificateInfo } from '../../types';

export function CertificatesPage() {
  const { data: certs = [], isLoading, refetch, isRefetching } = useQuery<CertificateInfo[]>({
    queryKey: ['certificates'],
    queryFn: () => apiRequest('/certificates')
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
            <span>TLS / SSL Certificates</span>
            <span className="text-xs font-mono font-medium px-2 py-0.5 rounded-full bg-surface-2 text-primary border border-border">
              {certs.length} inspected
            </span>
          </h1>
          <p className="text-xs text-text-muted mt-1">
            Real-time peer certificate expiration tracking, issuers, and automated warning thresholds.
          </p>
        </div>

        <Button variant="secondary" size="sm" onClick={() => refetch()} isLoading={isRefetching}>
          <RefreshCw className="w-3.5 h-3.5" />
          <span>Re-inspect Certificates</span>
        </Button>
      </div>

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
                <th className="py-3 px-4 w-48">Status Bar</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border/60 font-sans">
              {certs.map((c) => {
                const percent = Math.min(100, Math.max(0, Math.round((c.daysRemaining / 90) * 100)));
                const isCritical = c.daysRemaining <= 7;
                const isWarning = c.daysRemaining <= 30 && !isCritical;

                return (
                  <tr key={`${c.domain}-${c.port}`} className="hover:bg-surface-2/60 transition-colors">
                    <td className="py-3 px-4 font-mono font-bold text-text flex items-center gap-2">
                      <Shield className={`w-4 h-4 ${isCritical ? 'text-status-down' : isWarning ? 'text-status-slow' : 'text-status-up'}`} />
                      <span>{c.domain}</span>
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
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
