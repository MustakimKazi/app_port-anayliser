import React, { useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  Globe,
  Search,
  Filter,
  ExternalLink,
  ChevronDown,
  ChevronRight,
  Code,
  Zap,
  Shield
} from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { ActionBadge, UnresolvedBadge } from '../../components/ui/Badge';
import { Drawer } from '../../components/ui/Drawer';
import { CodeBlock } from '../../components/ui/CodeBlock';
import { Route } from '../../types';

export function RoutesPage() {
  const [searchParams, setSearchParams] = useSearchParams();

  const q = searchParams.get('q') || '';
  const domainFilter = searchParams.get('domain') || '';
  const portFilter = searchParams.get('port') || '';
  const actionFilter = searchParams.get('action') || '';
  const unresolvedFilter = searchParams.get('unresolved') || '';
  const catchAllFilter = searchParams.get('catchAll') || '';
  const websocketFilter = searchParams.get('websocket') || '';

  const [selectedRouteId, setSelectedRouteId] = useState<string | null>(null);
  const [groupByDomain, setGroupByDomain] = useState(true);
  const [collapsedDomains, setCollapsedDomains] = useState<Set<string>>(new Set());

  // Query routes
  const { data, isLoading } = useQuery<{ data: Route[]; pagination: { total: number } }>({
    queryKey: ['routes', searchParams.toString()],
    queryFn: () => {
      const qs = searchParams.toString();
      return apiRequest(`/routes?limit=200&${qs}`);
    }
  });

  // Query detail for drawer
  const { data: routeDetail } = useQuery<{ route: Route; nginxSnippet: string }>({
    queryKey: ['route-detail', selectedRouteId],
    queryFn: () => apiRequest(`/routes/${selectedRouteId}`),
    enabled: !!selectedRouteId
  });

  const updateFilter = (key: string, value: string) => {
    const next = new URLSearchParams(searchParams);
    if (!value) next.delete(key);
    else next.set(key, value);
    setSearchParams(next);
  };

  const routes = data?.data || [];

  // Group routes by domain if groupByDomain is enabled
  const groupedRoutes: Record<string, Route[]> = {};
  if (groupByDomain) {
    for (const r of routes) {
      if (!groupedRoutes[r.domain]) groupedRoutes[r.domain] = [];
      groupedRoutes[r.domain].push(r);
    }
  }

  const toggleDomainCollapse = (domain: string) => {
    const next = new Set(collapsedDomains);
    if (next.has(domain)) next.delete(domain);
    else next.add(domain);
    setCollapsedDomains(next);
  };

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
            <span>Domains & Routes</span>
            <span className="text-xs font-mono font-medium px-2 py-0.5 rounded-full bg-surface-2 text-primary border border-border">
              {data?.pagination.total ?? 106} routes
            </span>
          </h1>
          <p className="text-xs text-text-muted mt-1">
            Complete Nginx domain mappings, URL paths, proxy upstream targets, and static definitions.
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <Button
            variant={groupByDomain ? 'primary' : 'secondary'}
            size="sm"
            onClick={() => setGroupByDomain(!groupByDomain)}
            className="text-xs"
          >
            {groupByDomain ? 'Grouped by Domain' : 'Flat Table'}
          </Button>
        </div>
      </div>

      {/* Filter Toolbar */}
      <Card className="p-4 space-y-3">
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
          {/* Search */}
          <div className="relative col-span-1 sm:col-span-2">
            <Search className="w-4 h-4 text-text-muted absolute left-3 top-2.5" />
            <input
              type="text"
              value={q}
              onChange={(e) => updateFilter('q', e.target.value)}
              placeholder="Search domain, path, target..."
              className="w-full pl-9 pr-3 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text placeholder-text-muted focus:outline-none focus:border-primary"
            />
          </div>

          {/* Action Filter */}
          <select
            value={actionFilter}
            onChange={(e) => updateFilter('action', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Action: All</option>
            <option value="Proxy">Proxy (Forwarded)</option>
            <option value="Static">Static (Files)</option>
            <option value="Redirect">Redirect (301/302)</option>
            <option value="Return">Return</option>
            <option value="Status">Status (stub_status)</option>
          </select>

          {/* Unresolved Filter */}
          <select
            value={unresolvedFilter}
            onChange={(e) => updateFilter('unresolved', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Targets: All</option>
            <option value="true">Unresolved Targets Only</option>
          </select>

          {/* Catch-all Filter */}
          <select
            value={catchAllFilter}
            onChange={(e) => updateFilter('catchAll', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Catch-all: All</option>
            <option value="true">Catch-All (server_name _)</option>
          </select>

          {/* Websocket Filter */}
          <select
            value={websocketFilter}
            onChange={(e) => updateFilter('websocket', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Websocket: Any</option>
            <option value="true">Has WebSocket</option>
          </select>
        </div>
      </Card>

      {/* Routes List (Grouped or Flat) */}
      {groupByDomain ? (
        <div className="space-y-4">
          {Object.entries(groupedRoutes).map(([domain, items]) => {
            const isCollapsed = collapsedDomains.has(domain);
            return (
              <div
                key={domain}
                className="rounded-xl border border-border bg-surface backdrop-blur-md overflow-hidden"
              >
                {/* Domain Header Row */}
                <div
                  onClick={() => toggleDomainCollapse(domain)}
                  className="px-4 py-3 bg-surface-2/80 hover:bg-surface-2 cursor-pointer flex items-center justify-between border-b border-border transition-colors"
                >
                  <div className="flex items-center gap-2.5">
                    {isCollapsed ? (
                      <ChevronRight className="w-4 h-4 text-text-muted" />
                    ) : (
                      <ChevronDown className="w-4 h-4 text-text-muted" />
                    )}
                    <span className="font-mono text-sm font-bold text-text">{domain}</span>
                    {items[0]?.isCatchAll && (
                      <span className="text-[10px] px-1.5 py-0.2 rounded bg-status-slow/20 text-status-slow border border-status-slow/30">
                        catch-all
                      </span>
                    )}
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-xs text-text-muted">{items.length} paths</span>
                    <a
                      href={`https://${domain}`}
                      target="_blank"
                      rel="noreferrer"
                      onClick={(e) => e.stopPropagation()}
                      className="p-1 rounded text-text-muted hover:text-text hover:bg-surface-2"
                      title="Open in new tab"
                    >
                      <ExternalLink className="w-3.5 h-3.5" />
                    </a>
                  </div>
                </div>

                {/* Sub-table of routes under this domain */}
                {!isCollapsed && (
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs text-text">
                      <thead className="bg-surface-2/60 text-[10px] uppercase text-text-muted border-b border-border">
                        <tr>
                          <th className="py-2.5 px-4">#</th>
                          <th className="py-2.5 px-4">Port</th>
                          <th className="py-2.5 px-4">Proto</th>
                          <th className="py-2.5 px-4">Path(s)</th>
                          <th className="py-2.5 px-4">Action</th>
                          <th className="py-2.5 px-4">Target / Forwarding Destination</th>
                          <th className="py-2.5 px-4">Config File</th>
                          <th className="py-2.5 px-4">Flags</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-border">
                        {items.map((route) => (
                          <tr
                            key={route.id}
                            onClick={() => setSelectedRouteId(route.id)}
                            className="hover:bg-surface-2 cursor-pointer transition-colors"
                          >
                            <td className="py-2.5 px-4 font-mono text-[11px] text-text-muted">
                              {route.rowNum}
                            </td>
                            <td className="py-2.5 px-4 font-mono font-semibold text-text">
                              {route.portNum ? `:${route.portNum}` : <span className="text-status-slow">{route.portRaw}</span>}
                            </td>
                            <td className="py-2.5 px-4 font-mono text-[11px] text-text-muted">
                              {route.protocol}
                            </td>
                            <td className="py-2.5 px-4 font-mono font-medium text-text">
                              {route.path}
                            </td>
                            <td className="py-2.5 px-4">
                              <ActionBadge action={route.action} />
                            </td>
                            <td className="py-2.5 px-4 font-mono text-xs max-w-sm truncate">
                              {route.targetType === 'upstream' ||
                              route.targetType === 'variable' ||
                              route.targetType === 'unknown' ? (
                                <div className="flex items-center gap-1.5">
                                  <UnresolvedBadge type={route.targetType} />
                                  <span className="text-text-muted truncate">{route.targetRaw}</span>
                                </div>
                              ) : (
                                <span className="text-primary">{route.targetRaw}</span>
                              )}
                            </td>
                            <td className="py-2.5 px-4 font-mono text-[11px] text-text-muted">
                              {route.configFile?.filename || '—'}
                            </td>
                            <td className="py-2.5 px-4">
                              <div className="flex items-center gap-1">
                                {route.flags?.websocket && (
                                  <span className="p-0.5 rounded bg-primary/20 text-primary" title="WebSocket enabled">
                                    <Zap className="w-3 h-3" />
                                  </span>
                                )}
                                {route.flags?.rateLimit && (
                                  <span className="p-0.5 rounded bg-status-slow/20 text-status-slow" title="Rate limit zone configured">
                                    <Shield className="w-3 h-3" />
                                  </span>
                                )}
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      ) : (
        /* Flat Table */
        <div className="rounded-xl border border-border bg-surface backdrop-blur-md overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-text">
              <thead className="bg-surface-2 text-[11px] uppercase tracking-wider text-text-muted border-b border-border">
                <tr>
                  <th className="py-3 px-3">#</th>
                  <th className="py-3 px-3">Domain</th>
                  <th className="py-3 px-3">Port</th>
                  <th className="py-3 px-3">Proto</th>
                  <th className="py-3 px-3">Path</th>
                  <th className="py-3 px-3">Action</th>
                  <th className="py-3 px-3">Target</th>
                  <th className="py-3 px-3">Config File</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border font-sans">
                {routes.map((route) => (
                  <tr
                    key={route.id}
                    onClick={() => setSelectedRouteId(route.id)}
                    className="hover:bg-surface-2 cursor-pointer transition-colors"
                  >
                    <td className="py-2.5 px-3 font-mono text-text-muted">{route.rowNum}</td>
                    <td className="py-2.5 px-3 font-mono font-bold text-text">{route.domain}</td>
                    <td className="py-2.5 px-3 font-mono font-semibold text-text">
                      {route.portNum ? `:${route.portNum}` : route.portRaw}
                    </td>
                    <td className="py-2.5 px-3 font-mono text-text-muted">{route.protocol}</td>
                    <td className="py-2.5 px-3 font-mono">{route.path}</td>
                    <td className="py-2.5 px-3">
                      <ActionBadge action={route.action} />
                    </td>
                    <td className="py-2.5 px-3 font-mono text-xs max-w-xs truncate text-primary">
                      {route.targetRaw}
                    </td>
                    <td className="py-2.5 px-3 font-mono text-text-muted">
                      {route.configFile?.filename || '—'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Detail Drawer */}
      <Drawer
        isOpen={!!selectedRouteId}
        onClose={() => setSelectedRouteId(null)}
        title={
          routeDetail?.route ? (
            <div className="flex items-center gap-2">
              <Globe className="w-5 h-5 text-primary" />
              <span>{routeDetail.route.domain}</span>
            </div>
          ) : (
            'Route Details'
          )
        }
        subtitle={routeDetail?.route?.path}
      >
        {routeDetail && (
          <div className="space-y-6">
            {/* Metadata Summary */}
            <div className="grid grid-cols-2 gap-3 text-xs">
              <div className="p-3 rounded-lg border border-border bg-surface-2/60">
                <span className="text-text-muted">Action</span>
                <div className="mt-1">
                  <ActionBadge action={routeDetail.route.action} />
                </div>
              </div>
              <div className="p-3 rounded-lg border border-border bg-surface-2/60">
                <span className="text-text-muted">Port & Protocol</span>
                <p className="font-mono text-text mt-1">
                  Port :{routeDetail.route.portNum || routeDetail.route.portRaw} ({routeDetail.route.protocol})
                </p>
              </div>
              <div className="p-3 rounded-lg border border-border bg-surface-2/60">
                <span className="text-text-muted">Target Type</span>
                <p className="font-mono text-primary mt-1 uppercase text-[11px]">
                  {routeDetail.route.targetType}
                </p>
              </div>
              <div className="p-3 rounded-lg border border-border bg-surface-2/60">
                <span className="text-text-muted">Config File</span>
                <p className="font-mono text-text mt-1">
                  {routeDetail.route.configFile?.filename || 'sites-enabled/default.conf'}
                </p>
              </div>
            </div>

            {/* Target Details */}
            <div className="p-4 rounded-xl border border-border bg-surface-2/40 space-y-2">
              <span className="text-xs font-semibold text-text">Forwarding Destination</span>
              <div className="p-2.5 rounded bg-surface-2 border border-border font-mono text-xs text-primary break-all">
                {routeDetail.route.targetRaw || 'Direct static / return'}
              </div>
              {routeDetail.route.backend && (
                <div className="text-xs text-text-muted flex items-center justify-between pt-1">
                  <span>Backend Server: {routeDetail.route.backend.server?.name || 'Local Server'}</span>
                  <span className="font-mono font-semibold text-text">
                    {routeDetail.route.backend.host}:{routeDetail.route.backend.port}
                  </span>
                </div>
              )}
            </div>

            {/* Generated Nginx Snippet with Copy */}
            <div className="space-y-2">
              <div className="flex items-center justify-between text-xs">
                <span className="font-semibold text-text flex items-center gap-1.5">
                  <Code className="w-4 h-4 text-primary" />
                  <span>Nginx Configuration Preview</span>
                </span>
              </div>
              <CodeBlock code={routeDetail.nginxSnippet} />
            </div>

            {/* Notes */}
            {routeDetail.route.notes && (
              <div className="p-3 rounded-lg bg-surface-2/60 border border-border text-xs text-text">
                <span className="text-text-muted font-semibold block mb-1">Documentation Notes:</span>
                {routeDetail.route.notes}
              </div>
            )}
          </div>
        )}
      </Drawer>
    </div>
  );
}
