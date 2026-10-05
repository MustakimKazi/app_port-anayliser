import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Grid, Search, Check, Copy, ArrowRight, Radio } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Card, CardHeader, CardTitle } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';

export function PortMapPage() {
  const [selectedRange, setSelectedRange] = useState('3000-3999');
  const [freePortCount, setFreePortCount] = useState(5);
  const [copiedPort, setCopiedPort] = useState<number | null>(null);

  // Query port map ranges
  const { data: portMapData } = useQuery<{
    ranges: Array<{
      label: string;
      min: number;
      max: number;
      totalCapacity: number;
      usedCount: number;
      usedPercentage: number;
      ports: any[];
    }>;
  }>({
    queryKey: ['port-map'],
    queryFn: () => apiRequest('/port-map')
  });

  // Query free ports
  const { data: freePortsData, refetch: findFreePorts, isFetching } = useQuery<{
    range: string;
    requestedCount: number;
    freePorts: number[];
  }>({
    queryKey: ['free-ports', selectedRange, freePortCount],
    queryFn: () => apiRequest(`/port-map/free?range=${selectedRange}&count=${freePortCount}`),
    enabled: false
  });

  const handleCopy = (p: number) => {
    navigator.clipboard.writeText(String(p));
    setCopiedPort(p);
    setTimeout(() => setCopiedPort(null), 2000);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
          <span>Port Map & Free Port Finder</span>
        </h1>
        <p className="text-xs text-text-muted mt-1">
          Visual heat strip across system port allocations, capacity utilization, and dynamic free port discovery.
        </p>
      </div>

      {/* Free Port Finder Tool Card */}
      <Card className="p-6 bg-gradient-to-r from-primary/10 via-surface to-primary/5 border-primary/30">
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div>
            <h2 className="text-base font-bold text-text flex items-center gap-2">
              <Search className="w-5 h-5 text-primary" />
              <span>Find Me a Free Port</span>
            </h2>
            <p className="text-xs text-text-muted mt-0.5">
              Live checks against documented ports and host socket listeners to find available ports.
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <select
              value={selectedRange}
              onChange={(e) => setSelectedRange(e.target.value)}
              className="px-3 py-1.5 rounded-lg bg-surface-2 border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
            >
              <option value="3000-3999">3000–3999 (Web Apps)</option>
              <option value="4000-4999">4000–4999 (Services)</option>
              <option value="8000-8999">8000–8999 (Proxies / APIS)</option>
              <option value="9000-9999">9000–9999 (Microservices)</option>
              <option value="10000-10999">10000–10999 (Internal Apps)</option>
            </select>

            <select
              value={freePortCount}
              onChange={(e) => setFreePortCount(parseInt(e.target.value))}
              className="px-3 py-1.5 rounded-lg bg-surface-2 border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
            >
              <option value="3">3 free ports</option>
              <option value="5">5 free ports</option>
              <option value="10">10 free ports</option>
            </select>

            <Button variant="primary" size="sm" onClick={() => findFreePorts()} isLoading={isFetching}>
              Find Free Ports
            </Button>
          </div>
        </div>

        {/* Free Ports Results */}
        {freePortsData && (
          <div className="mt-4 pt-4 border-t border-border flex flex-wrap items-center gap-3">
            <span className="text-xs font-semibold text-text-muted">Available Next Ports:</span>
            {freePortsData.freePorts.map((p) => (
              <button
                key={p}
                onClick={() => handleCopy(p)}
                className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-status-up/15 border border-status-up/30 text-status-up font-mono text-xs font-bold hover:bg-status-up/25 transition-colors"
                title="Click to copy port"
              >
                <span>:{p}</span>
                {copiedPort === p ? (
                  <Check className="w-3.5 h-3.5 text-status-up" />
                ) : (
                  <Copy className="w-3.5 h-3.5 opacity-60" />
                )}
              </button>
            ))}
          </div>
        )}
      </Card>

      {/* Visual Heat Strip of Port Ranges */}
      <div className="space-y-4">
        {portMapData?.ranges.map((range) => (
          <Card key={range.label} className="p-4 space-y-3">
            <div className="flex items-center justify-between">
              <div>
                <span className="font-bold text-sm text-text">{range.label}</span>
                <span className="text-xs text-text-muted font-mono ml-2">
                  ({range.min}–{range.max})
                </span>
              </div>
              <div className="text-xs font-mono text-text-muted">
                <span className="text-text font-bold">{range.usedCount}</span> / {range.totalCapacity} ports (
                {range.usedPercentage}%)
              </div>
            </div>

            {/* Capacity Progress Bar */}
            <div className="w-full bg-surface-2 rounded-full h-2 overflow-hidden border border-border">
              <div
                className="h-full bg-primary rounded-full transition-all"
                style={{ width: `${Math.max(1, range.usedPercentage)}%` }}
              />
            </div>

            {/* Active Port Badges in Range */}
            {range.ports.length > 0 && (
              <div className="flex flex-wrap items-center gap-2 pt-1">
                {range.ports.map((p) => (
                  <span
                    key={p.port}
                    className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded bg-surface-2 border border-border text-xs font-mono"
                  >
                    <span className="font-bold text-text">:{p.port}</span>
                    <span className="text-[10px] text-text-muted">{p.protocol}</span>
                  </span>
                ))}
              </div>
            )}
          </Card>
        ))}
      </div>
    </div>
  );
}
