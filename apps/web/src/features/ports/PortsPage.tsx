import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Server,
  Filter,
  Download,
  RefreshCw,
  Search,
  ExternalLink,
  Tag,
  Check,
  CheckCircle2,
  AlertTriangle,
  Clock,
  Eye,
  ChevronDown,
  Layers,
  ArrowUpDown,
  MoreVertical,
  X
} from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { StatusBadge, PriorityBadge, ActionBadge } from '../../components/ui/Badge';
import { Drawer } from '../../components/ui/Drawer';
import { Tabs } from '../../components/ui/Tabs';
import { Port, Route, Issue } from '../../types';

export function PortsPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const queryClient = useQueryClient();

  // Read URL filter states
  const q = searchParams.get('q') || '';
  const statusFilter = searchParams.get('status') || '';
  const layerFilter = searchParams.get('layer') || '';
  const protocolFilter = searchParams.get('protocol') || '';
  const bindFilter = searchParams.get('bind') || '';
  const hasIssuesFilter = searchParams.get('hasIssues') || '';
  const portMin = searchParams.get('portMin') || '';
  const portMax = searchParams.get('portMax') || '';
  const sort = searchParams.get('sort') || 'port';
  const density = searchParams.get('density') || 'comfortable';

  // Local state
  const [selectedPortId, setSelectedPortId] = useState<string | null>(null);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [isCheckingSingle, setIsCheckingSingle] = useState(false);
  const [bulkAction, setBulkAction] = useState<string>('');
  const [bulkTagInput, setBulkTagInput] = useState<string>('');
  const [activeDrawerTab, setActiveDrawerTab] = useState<'overview' | 'routes' | 'history' | 'issues'>('overview');

  // Inline notes/tags editing
  const [editingNotes, setEditingNotes] = useState(false);
  const [notesText, setNotesText] = useState('');
  const [newTagInput, setNewTagInput] = useState('');

  // Fetch Ports query based on filters
  const { data, isLoading } = useQuery<{ data: Port[]; pagination: { total: number } }>({
    queryKey: ['ports', searchParams.toString()],
    queryFn: () => {
      const qs = searchParams.toString();
      return apiRequest(`/ports?${qs}`);
    }
  });

  // Fetch Port Detail query when drawer is open
  const { data: portDetail, refetch: refetchPortDetail } = useQuery<{
    port: Port;
    routes: Route[];
    issues: Issue[];
    uptimeBlocks: Array<{ hour: number; label: string; status: any }>;
    recentChecks: any[];
    auditLogs: any[];
  }>({
    queryKey: ['port-detail', selectedPortId],
    queryFn: () => apiRequest(`/ports/${selectedPortId}`),
    enabled: !!selectedPortId
  });

  useEffect(() => {
    if (portDetail?.port) {
      setNotesText(portDetail.port.notes || '');
    }
  }, [portDetail]);

  const updateFilter = (key: string, value: string) => {
    const next = new URLSearchParams(searchParams);
    if (!value) {
      next.delete(key);
    } else {
      next.set(key, value);
    }
    setSearchParams(next);
  };

  const clearAllFilters = () => {
    setSearchParams(new URLSearchParams());
  };

  // Export current view
  const handleExport = (format: 'csv' | 'xlsx' | 'json') => {
    window.open(`/api/export?entity=ports&format=${format}`, '_blank');
  };

  // Check single target mutation
  const checkSingle = async (portId: string) => {
    try {
      setIsCheckingSingle(true);
      await apiRequest(`/scan/port/${portId}`, { method: 'POST' });
      await queryClient.invalidateQueries({ queryKey: ['ports'] });
      if (selectedPortId === portId) await refetchPortDetail();
    } catch (e) {
      console.error('Check failed:', e);
    } finally {
      setIsCheckingSingle(false);
    }
  };

  // Bulk actions mutation
  const executeBulkAction = async () => {
    if (!selectedIds.length || !bulkAction) return;

    await apiRequest('/ports/bulk', {
      method: 'POST',
      body: JSON.stringify({
        ids: selectedIds,
        action: bulkAction,
        payload: { tag: bulkTagInput }
      })
    });

    setSelectedIds([]);
    setBulkAction('');
    setBulkTagInput('');
    queryClient.invalidateQueries({ queryKey: ['ports'] });
  };

  // Save notes inline
  const saveNotes = async () => {
    if (!selectedPortId) return;
    await apiRequest(`/ports/${selectedPortId}`, {
      method: 'PATCH',
      body: JSON.stringify({ notes: notesText })
    });
    setEditingNotes(false);
    refetchPortDetail();
    queryClient.invalidateQueries({ queryKey: ['ports'] });
  };

  // Add tag inline
  const addTag = async () => {
    if (!selectedPortId || !newTagInput.trim() || !portDetail?.port) return;
    const currentTags = portDetail.port.tags || [];
    if (!currentTags.includes(newTagInput.trim())) {
      await apiRequest(`/ports/${selectedPortId}`, {
        method: 'PATCH',
        body: JSON.stringify({ tags: [...currentTags, newTagInput.trim()] })
      });
      setNewTagInput('');
      refetchPortDetail();
      queryClient.invalidateQueries({ queryKey: ['ports'] });
    }
  };

  const ports = data?.data || [];

  return (
    <div className="space-y-5">
      {/* Page Title & Actions */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
            <span>Ports</span>
            <span className="text-xs font-mono font-medium px-2 py-0.5 rounded-full bg-surface-2 text-primary border border-border">
              {data?.pagination.total ?? 0} total
            </span>
          </h1>
          <p className="text-xs text-text-muted mt-1">
            Every port listening or configured on leadowserver, process owners, and upstream routing.
          </p>
        </div>

        {/* Action Buttons */}
        <div className="flex items-center gap-2.5">
          {/* Saved Views Preset */}
          <select
            onChange={(e) => {
              const val = e.target.value;
              if (val === 'db') {
                updateFilter('layer', 'stream');
              } else if (val === 'public-http') {
                updateFilter('layer', 'http');
                updateFilter('protocol', 'HTTP');
                updateFilter('bind', 'public');
              } else if (val === 'issues') {
                updateFilter('hasIssues', 'true');
              } else {
                clearAllFilters();
              }
            }}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Saved Views...</option>
            <option value="db">My DB Ports (Redis/Mongo)</option>
            <option value="public-http">Public Plain HTTP</option>
            <option value="issues">Ports With Issues</option>
          </select>

          {/* Density toggle */}
          <button
            onClick={() =>
              updateFilter('density', density === 'comfortable' ? 'compact' : 'comfortable')
            }
            className="p-1.5 rounded-lg bg-surface hover:bg-surface-2 border border-border-strong text-text-muted hover:text-text text-xs transition-colors"
            title="Toggle table row density"
          >
            <Layers className="w-4 h-4" />
          </button>

          {/* Export Dropdown */}
          <div className="relative group">
            <Button variant="secondary" size="sm" className="text-xs">
              <Download className="w-3.5 h-3.5" />
              <span>Export</span>
              <ChevronDown className="w-3 h-3 opacity-60" />
            </Button>
            <div className="absolute right-0 mt-1 w-32 bg-surface border border-border-strong rounded-lg shadow-xl py-1 hidden group-hover:block z-20">
              <button
                onClick={() => handleExport('csv')}
                className="w-full text-left px-3 py-1.5 text-xs text-text hover:bg-surface-2"
              >
                Export CSV
              </button>
              <button
                onClick={() => handleExport('xlsx')}
                className="w-full text-left px-3 py-1.5 text-xs text-text hover:bg-surface-2"
              >
                Export Excel (.xlsx)
              </button>
              <button
                onClick={() => handleExport('json')}
                className="w-full text-left px-3 py-1.5 text-xs text-text hover:bg-surface-2"
              >
                Export JSON
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Filter Toolbar */}
      <Card className="p-4 space-y-3">
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
          {/* Free text search */}
          <div className="relative col-span-1 sm:col-span-2">
            <Search className="w-4 h-4 text-text-muted absolute left-3 top-2.5" />
            <input
              type="text"
              value={q}
              onChange={(e) => updateFilter('q', e.target.value)}
              placeholder="Search port, domain, process, purpose..."
              className="w-full pl-9 pr-3 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text placeholder-text-muted focus:outline-none focus:border-primary"
            />
            {q && (
              <button
                onClick={() => updateFilter('q', '')}
                className="absolute right-2.5 top-2.5 text-text-muted hover:text-text"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            )}
          </div>

          {/* Status Filter */}
          <select
            value={statusFilter}
            onChange={(e) => updateFilter('status', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Status: All</option>
            <option value="up">UP (Listening)</option>
            <option value="down">DOWN (Closed)</option>
            <option value="slow">SLOW</option>
            <option value="unknown">UNKNOWN</option>
          </select>

          {/* Layer Filter */}
          <select
            value={layerFilter}
            onChange={(e) => updateFilter('layer', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Layer: All</option>
            <option value="http">HTTP (Web)</option>
            <option value="stream">Stream (TCP Raw)</option>
          </select>

          {/* Protocol Filter */}
          <select
            value={protocolFilter}
            onChange={(e) => updateFilter('protocol', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Protocol: All</option>
            <option value="HTTP">HTTP</option>
            <option value="HTTPS">HTTPS</option>
            <option value="TCP">TCP</option>
          </select>

          {/* Bind Filter */}
          <select
            value={bindFilter}
            onChange={(e) => updateFilter('bind', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Bind: All</option>
            <option value="public">Public (0.0.0.0)</option>
            <option value="local">Local (127.0.0.1)</option>
          </select>
        </div>

        {/* Second Row: Has Issues, Port Range, Reset */}
        <div className="flex flex-wrap items-center justify-between gap-3 pt-2 border-t border-border">
          <div className="flex flex-wrap items-center gap-3">
            <select
              value={hasIssuesFilter}
              onChange={(e) => updateFilter('hasIssues', e.target.value)}
              className="px-2.5 py-1 rounded-md bg-surface border border-border-strong text-xs text-text focus:outline-none"
            >
              <option value="">Issues: Any</option>
              <option value="true">Has Open Issues</option>
              <option value="false">No Issues</option>
            </select>

            <div className="flex items-center gap-1.5 text-xs text-text-muted">
              <span>Port:</span>
              <input
                type="number"
                placeholder="Min"
                value={portMin}
                onChange={(e) => updateFilter('portMin', e.target.value)}
                className="w-20 px-2 py-1 rounded bg-surface border border-border-strong text-xs text-text"
              />
              <span>–</span>
              <input
                type="number"
                placeholder="Max"
                value={portMax}
                onChange={(e) => updateFilter('portMax', e.target.value)}
                className="w-20 px-2 py-1 rounded bg-surface border border-border-strong text-xs text-text"
              />
            </div>
          </div>

          {(statusFilter || layerFilter || protocolFilter || bindFilter || hasIssuesFilter || portMin || portMax || q) && (
            <Button variant="ghost" size="sm" onClick={clearAllFilters} className="text-xs text-status-down hover:text-status-down/80">
              Clear Filters
            </Button>
          )}
        </div>
      </Card>

      {/* Bulk Operations Bar if any rows selected */}
      {selectedIds.length > 0 && (
        <div className="p-3 rounded-lg bg-primary/10 border border-primary/30 flex items-center justify-between gap-3 text-xs text-text">
          <div className="flex items-center gap-2">
            <span className="font-semibold text-text">{selectedIds.length} ports selected</span>
          </div>
          <div className="flex items-center gap-2">
            <select
              value={bulkAction}
              onChange={(e) => setBulkAction(e.target.value)}
              className="px-2 py-1 rounded bg-surface border border-border-strong text-xs text-text focus:outline-none"
            >
              <option value="">Choose Bulk Action...</option>
              <option value="checkNow">Check Now</option>
              <option value="markExpected">Mark as Expected</option>
              <option value="ackIssues">Acknowledge Issues</option>
              <option value="addTag">Add Tag</option>
            </select>

            {bulkAction === 'addTag' && (
              <input
                type="text"
                placeholder="Tag name"
                value={bulkTagInput}
                onChange={(e) => setBulkTagInput(e.target.value)}
                className="w-28 px-2 py-1 rounded bg-surface border border-border-strong text-xs text-text placeholder-text-muted"
              />
            )}

            <Button variant="teal" size="sm" onClick={executeBulkAction}>
              Apply
            </Button>
            <Button variant="ghost" size="sm" onClick={() => setSelectedIds([])}>
              Cancel
            </Button>
          </div>
        </div>
      )}

      {/* Ports Table */}
      <div className="rounded-xl border border-border bg-surface backdrop-blur-md overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-text">
            <thead className="bg-surface-2 text-[11px] uppercase tracking-wider text-text-muted border-b border-border sticky top-0">
              <tr>
                <th className="py-3 px-3 w-8">
                  <input
                    type="checkbox"
                    checked={selectedIds.length > 0 && selectedIds.length === ports.length}
                    onChange={(e) => {
                      if (e.target.checked) setSelectedIds(ports.map((p) => p.id));
                      else setSelectedIds([]);
                    }}
                    className="rounded bg-surface border-border-strong text-primary focus:ring-0"
                  />
                </th>
                <th
                  onClick={() => updateFilter('sort', sort === 'port' ? '-port' : 'port')}
                  className="py-3 px-3 cursor-pointer hover:text-text"
                >
                  <div className="flex items-center gap-1">
                    <span>Port</span>
                    <ArrowUpDown className="w-3 h-3 opacity-60" />
                  </div>
                </th>
                <th className="py-3 px-3">Status</th>
                <th className="py-3 px-3">Layer</th>
                <th className="py-3 px-3">Protocol</th>
                <th className="py-3 px-3">Bind</th>
                <th className="py-3 px-3">Process</th>
                <th className="py-3 px-3 text-center">Domains</th>
                <th className="py-3 px-3 text-center">Routes</th>
                <th className="py-3 px-3">Purpose</th>
                <th className="py-3 px-3">Latency</th>
                <th className="py-3 px-3">Issues</th>
                <th className="py-3 px-3 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border font-sans">
              {isLoading ? (
                <tr>
                  <td colSpan={13} className="py-12 text-center text-text-muted">
                    Loading ports...
                  </td>
                </tr>
              ) : ports.length === 0 ? (
                <tr>
                  <td colSpan={13} className="py-12 text-center text-text-muted">
                    No ports match the selected filter criteria.
                  </td>
                </tr>
              ) : (
                ports.map((port) => {
                  const isSelected = selectedIds.includes(port.id);
                  const py = density === 'compact' ? 'py-2' : 'py-3.5';

                  return (
                    <tr
                      key={port.id}
                      onClick={() => setSelectedPortId(port.id)}
                      className={`hover:bg-surface-2 cursor-pointer transition-colors ${
                        isSelected ? 'bg-primary/10' : ''
                      }`}
                    >
                      <td className={`${py} px-3`} onClick={(e) => e.stopPropagation()}>
                        <input
                          type="checkbox"
                          checked={isSelected}
                          onChange={(e) => {
                            if (e.target.checked) setSelectedIds([...selectedIds, port.id]);
                            else setSelectedIds(selectedIds.filter((id) => id !== port.id));
                          }}
                          className="rounded bg-surface border-border-strong text-primary focus:ring-0"
                        />
                      </td>

                      {/* Port Number */}
                      <td className={`${py} px-3`}>
                        <div className="flex items-center gap-1.5 font-mono text-sm font-bold text-text">
                          <span>:{port.port}</span>
                          {port.layer === 'stream' && (
                            <span className="text-[10px] font-sans px-1 py-0.2 rounded bg-action-return/20 text-action-return border border-action-return/30">
                              stream
                            </span>
                          )}
                        </div>
                      </td>

                      {/* Status */}
                      <td className={`${py} px-3`}>
                        <StatusBadge status={port.status} size="sm" />
                      </td>

                      {/* Layer */}
                      <td className={`${py} px-3 uppercase text-[11px] font-semibold text-text-muted`}>
                        {port.layer}
                      </td>

                      {/* Protocol */}
                      <td className={`${py} px-3 font-mono text-xs text-text`}>
                        {port.protocol}
                      </td>

                      {/* Bind (Public vs Local) */}
                      <td className={`${py} px-3`}>
                        {port.isPublic ? (
                          <span className="inline-flex items-center px-1.5 py-0.5 rounded text-[11px] bg-surface-2 text-text font-mono border border-border">
                            0.0.0.0 (public)
                          </span>
                        ) : (
                          <span className="inline-flex items-center px-1.5 py-0.5 rounded text-[11px] bg-status-slow/20 text-status-slow font-mono border border-status-slow/30">
                            127.0.0.1 (local)
                          </span>
                        )}
                      </td>

                      {/* Process */}
                      <td className={`${py} px-3 font-mono text-xs text-text-muted`}>
                        {port.processName ? (
                          <span>
                            {port.processName}
                            {port.pid ? ` (${port.pid})` : ''}
                          </span>
                        ) : (
                          <span className="text-text-muted">—</span>
                        )}
                      </td>

                      {/* Domains count */}
                      <td className={`${py} px-3 text-center font-mono-numbers font-semibold text-text`}>
                        {port.domainsList ? port.domainsList.split(',').length : 0}
                      </td>

                      {/* Routes count */}
                      <td className={`${py} px-3 text-center font-mono-numbers text-text`}>
                        {port.routeCount}
                      </td>

                      {/* Purpose */}
                      <td className={`${py} px-3 max-w-xs truncate text-text-muted`} title={port.purpose || ''}>
                        {port.purpose || '—'}
                      </td>

                      {/* Latency */}
                      <td className={`${py} px-3 font-mono text-xs`}>
                        {port.latencyMs !== null ? (
                          <span className={port.latencyMs > 1500 ? 'text-status-slow' : 'text-text-muted'}>
                            {port.latencyMs}ms
                          </span>
                        ) : (
                          <span className="text-text-muted">—</span>
                        )}
                      </td>

                      {/* Issues */}
                      <td className={`${py} px-3`}>
                        {port.openIssueCount > 0 ? (
                          <span className="inline-flex items-center gap-1 text-status-down font-semibold font-mono">
                            <AlertTriangle className="w-3.5 h-3.5" />
                            <span>{port.openIssueCount}</span>
                          </span>
                        ) : (
                          <span className="text-text-muted">—</span>
                        )}
                      </td>

                      {/* Actions */}
                      <td className={`${py} px-3 text-right`} onClick={(e) => e.stopPropagation()}>
                        <button
                          onClick={() => checkSingle(port.id)}
                          className="p-1 rounded hover:bg-surface-2 text-text-muted hover:text-text transition-colors"
                          title="Check Port Now"
                        >
                          <RefreshCw className="w-3.5 h-3.5" />
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Side Drawer for Selected Port */}
      <Drawer
        isOpen={!!selectedPortId}
        onClose={() => setSelectedPortId(null)}
        title={
          portDetail?.port ? (
            <div className="flex items-center gap-2.5 font-mono">
              <span className="text-xl font-bold text-text">Port :{portDetail.port.port}</span>
              <StatusBadge status={portDetail.port.status} />
              <span className="text-xs uppercase font-sans text-text-muted font-medium px-2 py-0.5 bg-surface-2 rounded border border-border">
                {portDetail.port.layer} / {portDetail.port.protocol}
              </span>
            </div>
          ) : (
            'Port Details'
          )
        }
        subtitle={portDetail?.port?.purpose || 'Inspecting port telemetry and routes'}
      >
        {portDetail && (
          <div className="space-y-6">
            {/* Drawer Navigation Tabs */}
            <Tabs
              activeTab={activeDrawerTab}
              onChange={(t) => setActiveDrawerTab(t as any)}
              tabs={[
                { id: 'overview', label: 'Overview & Uptime' },
                { id: 'routes', label: 'Routes', badge: portDetail.routes.length },
                { id: 'history', label: 'Checks', badge: portDetail.recentChecks.length },
                { id: 'issues', label: 'Issues', badge: portDetail.issues.length }
              ]}
            />

            {/* TAB 1: OVERVIEW & 24H UPTIME */}
            {activeDrawerTab === 'overview' && (
              <div className="space-y-6">
                {/* 24h Uptime Strip */}
                <div className="p-4 rounded-xl border border-border bg-surface-2/40 space-y-2">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-semibold text-text">24-Hour Uptime Bar</span>
                    <span className="text-text-muted font-mono text-[11px]">Hover block for hour</span>
                  </div>
                  <div className="grid grid-cols-24 gap-1 h-7">
                    {portDetail.uptimeBlocks.map((b, idx) => (
                      <div
                        key={idx}
                        title={`${b.label} - Status: ${b.status.toUpperCase()}`}
                        className={`rounded-sm transition-transform hover:scale-110 cursor-pointer ${
                          b.status === 'up'
                            ? 'bg-status-up'
                            : b.status === 'down'
                            ? 'bg-status-down'
                            : b.status === 'slow'
                            ? 'bg-status-slow'
                            : 'bg-surface-2'
                        }`}
                      />
                    ))}
                  </div>
                </div>

                {/* Key metadata grid */}
                <div className="grid grid-cols-2 gap-3 text-xs">
                  <div className="p-3 rounded-lg border border-border bg-surface-2/40">
                    <span className="text-text-muted">Bind Address</span>
                    <p className="font-mono text-text mt-1">
                      {portDetail.port.listenAddress || '0.0.0.0'} ({portDetail.port.isPublic ? 'Public' : 'Local'})
                    </p>
                  </div>
                  <div className="p-3 rounded-lg border border-border bg-surface-2/40">
                    <span className="text-text-muted">Process / PID</span>
                    <p className="font-mono text-text mt-1">
                      {portDetail.port.processName || 'nginx'} (PID: {portDetail.port.pid || '—'})
                    </p>
                  </div>
                  <div className="p-3 rounded-lg border border-border bg-surface-2/40">
                    <span className="text-text-muted">Latency</span>
                    <p className="font-mono text-text mt-1">
                      {portDetail.port.latencyMs !== null ? `${portDetail.port.latencyMs} ms` : '—'}
                    </p>
                  </div>
                  <div className="p-3 rounded-lg border border-border bg-surface-2/40">
                    <span className="text-text-muted">Last Checked</span>
                    <p className="font-mono text-text mt-1">
                      {portDetail.port.lastCheckedAt
                        ? new Date(portDetail.port.lastCheckedAt).toLocaleTimeString()
                        : 'Never'}
                    </p>
                  </div>
                </div>

                {/* Inline Notes */}
                <div className="space-y-2">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-semibold text-text">Notes & Description</span>
                    {!editingNotes ? (
                      <button
                        onClick={() => setEditingNotes(true)}
                        className="text-primary hover:text-primary/80 text-xs"
                      >
                        Edit Note
                      </button>
                    ) : (
                      <div className="flex items-center gap-2">
                        <button onClick={saveNotes} className="text-status-up text-xs font-semibold">
                          Save
                        </button>
                        <button onClick={() => setEditingNotes(false)} className="text-text-muted text-xs">
                          Cancel
                        </button>
                      </div>
                    )}
                  </div>
                  {editingNotes ? (
                    <textarea
                      value={notesText}
                      onChange={(e) => setNotesText(e.target.value)}
                      className="w-full h-20 p-2 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
                    />
                  ) : (
                    <div className="p-3 rounded-lg bg-surface-2/50 border border-border text-xs text-text">
                      {portDetail.port.notes || 'No custom notes provided.'}
                    </div>
                  )}
                </div>

                {/* Tags Inline Management */}
                <div className="space-y-2">
                  <span className="text-xs font-semibold text-text">Tags</span>
                  <div className="flex flex-wrap items-center gap-1.5">
                    {portDetail.port.tags.map((tag) => (
                      <span
                        key={tag}
                        className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-mono bg-surface-2 text-text border border-border"
                      >
                        <Tag className="w-3 h-3 opacity-60" />
                        <span>{tag}</span>
                      </span>
                    ))}
                    <div className="flex items-center gap-1">
                      <input
                        type="text"
                        placeholder="+ add tag"
                        value={newTagInput}
                        onChange={(e) => setNewTagInput(e.target.value)}
                        onKeyDown={(e) => e.key === 'Enter' && addTag()}
                        className="w-24 px-2 py-0.5 rounded bg-surface border border-border text-xs text-text placeholder-text-muted"
                      />
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* TAB 2: ROUTES USING THIS PORT */}
            {activeDrawerTab === 'routes' && (
              <div className="space-y-3">
                <div className="text-xs text-text-muted font-medium">
                  {portDetail.routes.length} domain routes configured on this port
                </div>
                <div className="divide-y divide-border rounded-lg border border-border bg-surface-2/40">
                  {portDetail.routes.map((route) => (
                    <div key={route.id} className="p-3 text-xs space-y-1">
                      <div className="flex items-center justify-between">
                        <span className="font-mono font-bold text-text">{route.domain}</span>
                        <ActionBadge action={route.action} />
                      </div>
                      <div className="flex items-center justify-between text-text-muted">
                        <span className="font-mono">{route.path}</span>
                        <span className="font-mono text-primary truncate max-w-xs">{route.targetRaw}</span>
                      </div>
                      {route.backend && (
                        <div className="text-[11px] text-text-muted">
                          Target Backend:{' '}
                          <span className="text-text font-mono">
                            {route.backend.host}:{route.backend.port}
                          </span>
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* TAB 3: CHECK HISTORY */}
            {activeDrawerTab === 'history' && (
              <div className="space-y-2">
                <div className="text-xs text-text-muted font-medium">Recent check logs</div>
                <div className="rounded-lg border border-border bg-surface-2/40 overflow-hidden">
                  <table className="w-full text-xs text-left">
                    <thead className="bg-surface-2 text-text-muted text-[11px]">
                      <tr>
                        <th className="p-2">Time</th>
                        <th className="p-2">Status</th>
                        <th className="p-2">Latency</th>
                        <th className="p-2">Type</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                      {portDetail.recentChecks.map((c) => (
                        <tr key={c.id}>
                          <td className="p-2 font-mono text-text-muted">
                            {new Date(c.checkedAt).toLocaleTimeString()}
                          </td>
                          <td className="p-2">
                            <StatusBadge status={c.status} size="sm" />
                          </td>
                          <td className="p-2 font-mono">{c.latencyMs ? `${c.latencyMs}ms` : '—'}</td>
                          <td className="p-2 uppercase text-[10px] text-text-muted">{c.checkType}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {/* TAB 4: ISSUES */}
            {activeDrawerTab === 'issues' && (
              <div className="space-y-3">
                {portDetail.issues.length === 0 ? (
                  <div className="py-8 text-center text-text-muted text-xs">No open issues for this port.</div>
                ) : (
                  portDetail.issues.map((issue) => (
                    <div key={issue.id} className="p-3 rounded-lg border border-border bg-surface-2/60 space-y-1.5">
                      <div className="flex items-center justify-between">
                        <span className="text-xs font-semibold text-text">{issue.title}</span>
                        <PriorityBadge priority={issue.priority} />
                      </div>
                      <p className="text-xs text-text-muted">{issue.observed}</p>
                      <div className="p-2 rounded bg-surface-2 font-mono text-xs text-primary border border-border">
                        {issue.recommendation}
                      </div>
                    </div>
                  ))
                )}
              </div>
            )}
          </div>
        )}
      </Drawer>
    </div>
  );
}
