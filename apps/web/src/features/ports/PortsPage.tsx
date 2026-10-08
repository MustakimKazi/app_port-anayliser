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
  X,
  Plus,
  Archive,
  Trash2,
  Sliders,
  Shield,
  RotateCcw,
  Calendar,
  AlertOctagon
} from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { StatusBadge, PriorityBadge, ActionBadge, LifecycleBadge } from '../../components/ui/Badge';
import { Drawer } from '../../components/ui/Drawer';
import { Tabs } from '../../components/ui/Tabs';
import { Port, Route, Issue, FeaturePreset, FeatureItem, ImpactPreview } from '../../types';
import { AddPortDialog } from './AddPortDialog';
import { RemovePortDialog } from './RemovePortDialog';
import { ApplyPresetModal } from './ApplyPresetModal';
import { TrashModal } from '../trash/TrashModal';
import { PlannedPortsWidget } from './PlannedPortsWidget';

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
  const lifecycleFilter = searchParams.get('lifecycle') || '';
  const showArchived = searchParams.get('showArchived') || '';
  const portMin = searchParams.get('portMin') || '';
  const portMax = searchParams.get('portMax') || '';
  const sort = searchParams.get('sort') || 'port';
  const density = searchParams.get('density') || 'comfortable';

  // Dialog States
  const [isAddPortOpen, setIsAddPortOpen] = useState(false);
  const [addPortPrefill, setAddPortPrefill] = useState<any>(null);
  const [removePortTarget, setRemovePortTarget] = useState<{ id: string; port: number } | null>(null);
  const [isApplyPresetOpen, setIsApplyPresetOpen] = useState(false);
  const [isTrashOpen, setIsTrashOpen] = useState(false);

  // Undo Toast state
  const [undoToast, setUndoToast] = useState<{ portNum: number; portId: string; timer: any } | null>(null);

  // Selected row & drawer state
  const [selectedPortId, setSelectedPortId] = useState<string | null>(null);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [isCheckingSingle, setIsCheckingSingle] = useState(false);
  const [bulkAction, setBulkAction] = useState<string>('');
  const [bulkTagInput, setBulkTagInput] = useState<string>('');
  const [bulkLifecycleInput, setBulkLifecycleInput] = useState<string>('');
  const [activeDrawerTab, setActiveDrawerTab] = useState<
    'overview' | 'routes' | 'features' | 'lifecycle' | 'impact' | 'history' | 'issues'
  >('overview');

  // Inline notes/tags editing in drawer
  const [editingNotes, setEditingNotes] = useState(false);
  const [notesText, setNotesText] = useState('');
  const [newTagInput, setNewTagInput] = useState('');

  // Fetch current user for role permission check
  const { data: currentUser } = useQuery<{ role: string; username: string }>({
    queryKey: ['me'],
    queryFn: () => apiRequest('/auth/me').catch(() => ({ role: 'viewer', username: 'guest' }))
  });

  const isViewer = currentUser?.role === 'viewer';

  // Check URL action (e.g. ?action=add)
  useEffect(() => {
    if (searchParams.get('action') === 'add') {
      setIsAddPortOpen(true);
    }
  }, [searchParams]);

  // Fetch Ports query
  const { data, isLoading, isError: isPortsError } = useQuery<{
    data: Port[];
    pagination: { total: number; page: number; totalPages: number };
  }>({
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
    features: any[];
    uptimeBlocks: Array<{ hour: number; label: string; status: any }>;
    recentChecks: any[];
    statusEvents: any[];
    auditLogs: any[];
  }>({
    queryKey: ['port-detail', selectedPortId],
    queryFn: () => apiRequest(`/ports/${selectedPortId}`),
    enabled: !!selectedPortId
  });

  // Fetch Registry Features & Presets for drawer
  const { data: registryFeatures = [] } = useQuery<FeatureItem[]>({
    queryKey: ['features-registry'],
    queryFn: () => apiRequest('/features/registry'),
    enabled: activeDrawerTab === 'features' && !!selectedPortId
  });

  const { data: presets = [] } = useQuery<FeaturePreset[]>({
    queryKey: ['feature-presets'],
    queryFn: () => apiRequest('/feature-presets'),
    enabled: activeDrawerTab === 'features' && !!selectedPortId
  });

  // Fetch impact preview when impact tab is open
  const { data: portImpact } = useQuery<ImpactPreview>({
    queryKey: ['port-impact', selectedPortId],
    queryFn: () => apiRequest(`/ports/${selectedPortId}/impact`),
    enabled: activeDrawerTab === 'impact' && !!selectedPortId
  });

  useEffect(() => {
    if (portDetail?.port) {
      setNotesText(portDetail.port.notes || '');
    }
  }, [portDetail]);

  const updateFilter = (key: string, value: string) => {
    const next = new URLSearchParams(searchParams);
    // changing any filter restarts from page 1
    if (key !== 'page') next.delete('page');
    if (!value) {
      next.delete(key);
    } else {
      next.set(key, value);
    }
    // replace: typing a search must not flood browser back-history
    setSearchParams(next, { replace: true });
  };

  const clearAllFilters = () => {
    setSearchParams(new URLSearchParams(), { replace: true });
  };

  // Export current view — the active URL filters are passed along so the
  // exported file matches exactly what is on screen (it used to export the
  // full unfiltered table, including archived ports)
  const handleExport = (format: 'csv' | 'xlsx' | 'json') => {
    const params = new URLSearchParams(searchParams);
    params.set('entity', 'ports');
    params.set('format', format);
    window.open(`/api/export?${params.toString()}`, '_blank');
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

    if (bulkAction === 'applyPreset') {
      setIsApplyPresetOpen(true);
      return;
    }

    if (bulkAction === 'archiveSelected') {
      if (confirm(`Archive ${selectedIds.length} ports? They can be restored from the trash.`)) {
        for (const id of selectedIds) {
          await apiRequest(`/ports/${id}/archive`, { method: 'POST' });
        }
        setSelectedIds([]);
        setBulkAction('');
        queryClient.invalidateQueries({ queryKey: ['ports'] });
        queryClient.invalidateQueries({ queryKey: ['overview'] });
      }
      return;
    }

    if (bulkAction === 'setLifecycle' && bulkLifecycleInput) {
      for (const id of selectedIds) {
        await apiRequest(`/ports/${id}/lifecycle`, {
          method: 'POST',
          body: JSON.stringify({
            lifecycle: bulkLifecycleInput,
            reason: 'Bulk lifecycle update'
          })
        });
      }
      setSelectedIds([]);
      setBulkAction('');
      setBulkLifecycleInput('');
      queryClient.invalidateQueries({ queryKey: ['ports'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
      return;
    }

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

  // Toggle single feature in drawer
  const handleFeatureToggle = async (featureKey: string, enabled: boolean) => {
    if (!selectedPortId) return;
    await apiRequest(`/ports/${selectedPortId}/features`, {
      method: 'PUT',
      body: JSON.stringify({
        features: {
          [featureKey]: { enabled }
        }
      })
    });
    refetchPortDetail();
    queryClient.invalidateQueries({ queryKey: ['ports'] });
  };

  // Save current drawer features as custom preset
  const handleSaveAsPreset = async () => {
    const name = prompt('Enter a name for this new Feature Preset:');
    if (!name || !selectedPortId) return;

    try {
      await apiRequest('/feature-presets', {
        method: 'POST',
        body: JSON.stringify({
          name,
          portId: selectedPortId,
          features: {}
        })
      });
      alert(`Preset "${name}" saved successfully!`);
      queryClient.invalidateQueries({ queryKey: ['feature-presets'] });
    } catch (e: any) {
      alert(e.message || 'Failed to save preset');
    }
  };

  // Lifecycle transition mutation in drawer
  const changeLifecycle = async (newLifecycle: string, reasonPrompt: boolean = false) => {
    if (!selectedPortId) return;
    let reason = '';
    if (reasonPrompt) {
      reason = prompt(`Reason for setting status to ${newLifecycle.toUpperCase()}:`) || '';
    }

    await apiRequest(`/ports/${selectedPortId}/lifecycle`, {
      method: 'POST',
      body: JSON.stringify({
        lifecycle: newLifecycle,
        reason
      })
    });
    refetchPortDetail();
    queryClient.invalidateQueries({ queryKey: ['ports'] });
    queryClient.invalidateQueries({ queryKey: ['overview'] });
  };

  // Trigger undo toast
  const handlePortArchived = (portNum: number, portId?: string) => {
    if (undoToast?.timer) clearTimeout(undoToast.timer);

    const timer = setTimeout(() => {
      setUndoToast(null);
    }, 10000);

    const actualPortId = portId || removePortTarget?.id || '';
    setUndoToast({
      portNum,
      portId: actualPortId,
      timer
    });
  };

  const handleUndo = async () => {
    if (!undoToast) return;
    try {
      await apiRequest(`/ports/${undoToast.portId}/restore`, { method: 'POST' });
      clearTimeout(undoToast.timer);
      setUndoToast(null);
      queryClient.invalidateQueries({ queryKey: ['ports'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
    } catch (e) {
      console.error('Undo failed:', e);
    }
  };

  const ports = data?.data || [];

  return (
    <div className="space-y-5">
      {/* Undo Toast Notification (10 seconds) */}
      {undoToast && (
        <div className="fixed bottom-6 right-6 z-50 bg-surface border border-primary/50 text-text px-4 py-3 rounded-xl shadow-2xl flex items-center gap-3 animate-in fade-in slide-in-from-bottom-5">
          <CheckCircle2 className="w-5 h-5 text-status-up" />
          <span className="text-xs font-medium">
            Port :{undoToast.portNum} archived.
          </span>
          <Button variant="secondary" size="sm" onClick={handleUndo} className="text-xs py-1 h-7">
            <RotateCcw className="w-3.5 h-3.5 mr-1" />
            Undo
          </Button>
          <button
            onClick={() => setUndoToast(null)}
            className="text-text-muted hover:text-text p-1"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

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
          {/* Primary Add Port Button (Admin Only) */}
          {!isViewer && (
            <Button
              variant="primary"
              size="sm"
              onClick={() => { setAddPortPrefill(null); setIsAddPortOpen(true); }}
              className="text-xs shadow-sm"
            >
              <Plus className="w-3.5 h-3.5 mr-1" />
              <span>Add Port</span>
            </Button>
          )}

          {/* Archived / Trash View Button */}
          <Button
            variant="secondary"
            size="sm"
            onClick={() => setIsTrashOpen(true)}
            className="text-xs"
            title="Open archived items and trash view"
          >
            <Archive className="w-3.5 h-3.5 mr-1 text-text-muted" />
            <span>Trash</span>
          </Button>

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
              <Download className="w-3.5 h-3.5 mr-1" />
              <span>Export</span>
              <ChevronDown className="w-3 h-3 opacity-60 ml-1" />
            </Button>
            <div className="absolute right-0 mt-1 w-36 bg-surface border border-border-strong rounded-lg shadow-xl py-1 hidden group-hover:block z-20">
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

      {/* Planned Ports Schedule Widget */}
      <PlannedPortsWidget ports={ports} onOpenPort={(id) => setSelectedPortId(id)} />

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
              placeholder="Search port, domain, process, owner, purpose..."
              aria-label="Search ports"
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

          {/* Lifecycle Filter */}
          <select
            aria-label="Lifecycle filter"
            value={lifecycleFilter}
            onChange={(e) => updateFilter('lifecycle', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary font-medium"
          >
            <option value="">Lifecycle: All Standard</option>
            <option value="active">Active (In use)</option>
            <option value="planned">Planned (Upcoming)</option>
            <option value="reserved">Reserved</option>
            <option value="maintenance">Maintenance</option>
            <option value="deprecated">Deprecated</option>
            <option value="archived">Archived (Soft deleted)</option>
          </select>

          {/* Status Filter */}
          <select
            aria-label="Status filter"
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
            aria-label="Layer filter"
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
            aria-label="Protocol filter"
            value={protocolFilter}
            onChange={(e) => updateFilter('protocol', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Protocol: All</option>
            <option value="HTTP">HTTP</option>
            <option value="HTTPS">HTTPS</option>
            <option value="TCP">TCP</option>
          </select>
        </div>

        {/* Second Row: Show Archived Toggle, Bind, Issues, Clear */}
        <div className="flex flex-wrap items-center justify-between gap-3 pt-2 border-t border-border">
          <div className="flex flex-wrap items-center gap-3">
            {/* Show Archived Switch */}
            <label className="flex items-center gap-2 cursor-pointer text-xs font-medium text-text bg-surface-2 px-2.5 py-1 rounded-md border border-border">
              <input
                type="checkbox"
                checked={showArchived === 'true'}
                onChange={(e) => updateFilter('showArchived', e.target.checked ? 'true' : '')}
                className="w-3.5 h-3.5 rounded text-primary focus:ring-0"
              />
              <span>Show Archived</span>
            </label>

            {/* Bind Filter */}
            <select
              aria-label="Bind filter"
              value={bindFilter}
              onChange={(e) => updateFilter('bind', e.target.value)}
              className="px-2.5 py-1 rounded-md bg-surface border border-border-strong text-xs text-text focus:outline-none"
            >
              <option value="">Bind: All</option>
              <option value="public">Public (0.0.0.0)</option>
              <option value="local">Local (127.0.0.1)</option>
            </select>

            {/* Issues Filter */}
            <select
              aria-label="Issues filter"
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
                aria-label="Minimum port number"
                value={portMin}
                onChange={(e) => updateFilter('portMin', e.target.value)}
                className="w-20 px-2 py-1 rounded bg-surface border border-border-strong text-xs text-text font-mono"
              />
              <span>–</span>
              <input
                type="number"
                placeholder="Max"
                aria-label="Maximum port number"
                value={portMax}
                onChange={(e) => updateFilter('portMax', e.target.value)}
                className="w-20 px-2 py-1 rounded bg-surface border border-border-strong text-xs text-text font-mono"
              />
            </div>
          </div>

          {(statusFilter || layerFilter || protocolFilter || bindFilter || hasIssuesFilter || lifecycleFilter || showArchived || portMin || portMax || q) && (
            <Button variant="ghost" size="sm" onClick={clearAllFilters} className="text-xs text-status-down hover:text-status-down/80">
              Clear Filters
            </Button>
          )}
        </div>
      </Card>

      {/* Bulk Operations Toolbar */}
      {selectedIds.length > 0 && !isViewer && (
        <div className="p-3 rounded-lg bg-primary/10 border border-primary/30 flex flex-wrap items-center justify-between gap-3 text-xs text-text">
          <div className="flex items-center gap-2">
            <span className="font-semibold text-text">{selectedIds.length} ports selected</span>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <select
              aria-label="Bulk action"
              value={bulkAction}
              onChange={(e) => setBulkAction(e.target.value)}
              className="px-2.5 py-1 rounded bg-surface border border-border-strong text-xs text-text focus:outline-none"
            >
              <option value="">Choose Bulk Action...</option>
              <option value="applyPreset">Apply Preset...</option>
              <option value="setLifecycle">Set Lifecycle...</option>
              <option value="archiveSelected">Archive Selected</option>
              <option value="checkNow">Check Now</option>
              <option value="markExpected">Mark as Expected</option>
              <option value="ackIssues">Acknowledge Issues</option>
              <option value="addTag">Add Tag</option>
            </select>

            {bulkAction === 'setLifecycle' && (
              <select
                aria-label="Bulk lifecycle"
                value={bulkLifecycleInput}
                onChange={(e) => setBulkLifecycleInput(e.target.value)}
                className="px-2 py-1 rounded bg-surface border border-border-strong text-xs text-text"
              >
                <option value="">Select Lifecycle</option>
                <option value="active">Active</option>
                <option value="maintenance">Maintenance</option>
                <option value="deprecated">Deprecated</option>
                <option value="planned">Planned</option>
                <option value="reserved">Reserved</option>
              </select>
            )}

            {bulkAction === 'addTag' && (
              <input
                type="text"
                placeholder="Tag name"
                value={bulkTagInput}
                onChange={(e) => setBulkTagInput(e.target.value)}
                className="w-28 px-2 py-1 rounded bg-surface border border-border-strong text-xs text-text placeholder-text-muted"
              />
            )}

            <Button variant="primary" size="sm" onClick={executeBulkAction} className="text-xs">
              Apply
            </Button>
            <Button variant="ghost" size="sm" onClick={() => setSelectedIds([])} className="text-xs">
              Cancel
            </Button>
          </div>
        </div>
      )}

      {/* Ports Table */}
      <div className="rounded-xl border border-border bg-surface backdrop-blur-md overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-text">
            <thead className="bg-surface-2 text-[11px] uppercase tracking-wider text-text-muted border-b border-border sticky top-0 z-10">
              <tr>
                <th className="py-3 px-3 w-8">
                  <input
                    type="checkbox"
                    aria-label="Select all visible ports"
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
                <th className="py-3 px-3">Lifecycle</th>
                <th className="py-3 px-3">Layer</th>
                <th className="py-3 px-3">Protocol</th>
                <th className="py-3 px-3">Bind</th>
                <th className="py-3 px-3">Process</th>
                <th className="py-3 px-3 text-center">Domains</th>
                <th className="py-3 px-3 text-center">Routes</th>
                <th className="py-3 px-3">Purpose</th>
                <th className="py-3 px-3">Latency</th>
                <th className="py-3 px-3">Issues</th>
                <th className="py-3 px-3 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border font-sans">
              {isLoading ? (
                <tr>
                  <td colSpan={14} className="py-12 text-center text-text-muted">
                    Loading ports...
                  </td>
                </tr>
              ) : isPortsError ? (
                <tr>
                  <td colSpan={14} className="py-12 text-center text-status-down">
                    Failed to load ports — the server rejected the current filter parameters
                    (e.g. an invalid page or limit value).
                  </td>
                </tr>
              ) : ports.length === 0 ? (
                <tr>
                  <td colSpan={14} className="py-12 text-center text-text-muted">
                    <div className="max-w-sm mx-auto space-y-3">
                      <div>No ports matching current filter criteria.</div>
                      {!isViewer && (
                        <Button
                          variant="secondary"
                          size="sm"
                          onClick={() => { setAddPortPrefill(null); setIsAddPortOpen(true); }}
                        >
                          <Plus className="w-3.5 h-3.5 mr-1" />
                          Add Port Now
                        </Button>
                      )}
                    </div>
                  </td>
                </tr>
              ) : (
                ports.map((port) => {
                  const isSelected = selectedIds.includes(port.id);
                  const py = density === 'compact' ? 'py-1.5' : 'py-3';

                  return (
                    <tr
                      key={port.id}
                      onClick={() => setSelectedPortId(port.id)}
                      className={`hover:bg-surface-2/60 transition-colors cursor-pointer ${
                        selectedPortId === port.id ? 'bg-primary/5' : ''
                      }`}
                    >
                      {/* Checkbox */}
                      <td className={`${py} px-3`} onClick={(e) => e.stopPropagation()}>
                        <input
                          type="checkbox"
                          aria-label={`Select port ${port.port}`}
                          checked={isSelected}
                          onChange={(e) => {
                            if (e.target.checked) setSelectedIds([...selectedIds, port.id]);
                            else setSelectedIds(selectedIds.filter((id) => id !== port.id));
                          }}
                          className="rounded bg-surface border-border-strong text-primary focus:ring-0"
                        />
                      </td>

                      {/* Port Number */}
                      <td className={`${py} px-3 font-mono font-bold text-sm text-text`}>
                        :{port.port}
                      </td>

                      {/* Status */}
                      <td className={`${py} px-3`}>
                        <StatusBadge status={port.status} size="sm" />
                      </td>

                      {/* Lifecycle Column */}
                      <td className={`${py} px-3`}>
                        <LifecycleBadge lifecycle={port.lifecycle} size="sm" />
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
                        {port.listenAddress ? (
                          <span className={`inline-flex items-center px-1.5 py-0.5 rounded text-[11px] font-mono border ${port.isPublic ? 'bg-surface-2 text-text border-border' : 'bg-status-slow/20 text-status-slow border-status-slow/30'}`}>
                            {port.listenAddress} {port.isPublic ? '(public)' : '(local)'}
                          </span>
                        ) : (
                          <span className="inline-flex items-center px-1.5 py-0.5 rounded text-[11px] bg-surface-2 text-text-muted font-mono border border-border">
                            not listening
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
                        <div className="flex items-center justify-end gap-1">
                          <button
                            onClick={() => checkSingle(port.id)}
                            className="p-1 rounded hover:bg-surface-2 text-text-muted hover:text-text transition-colors"
                            title="Check Port Now"
                          >
                            <RefreshCw className="w-3.5 h-3.5" />
                          </button>
                          {!isViewer && (
                            <button
                              onClick={() => setRemovePortTarget({ id: port.id, port: port.port })}
                              className="p-1 rounded hover:bg-surface-2 text-text-muted hover:text-status-down transition-colors"
                              title="Remove / Archive Port"
                            >
                              <Archive className="w-3.5 h-3.5" />
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination (backend caps each request at 50 rows by default;
            without controls, rows past page 1 were unreachable) */}
        {data?.pagination && data.pagination.totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-border text-xs text-text-muted">
            <span>
              Page {data.pagination.page} of {data.pagination.totalPages} — {data.pagination.total} ports total
            </span>
            <div className="flex gap-2">
              <Button
                variant="secondary"
                size="sm"
                className="text-xs"
                disabled={data.pagination.page <= 1}
                onClick={() => updateFilter('page', String(data.pagination.page - 1))}
              >
                Previous
              </Button>
              <Button
                variant="secondary"
                size="sm"
                className="text-xs"
                disabled={data.pagination.page >= data.pagination.totalPages}
                onClick={() => updateFilter('page', String(data.pagination.page + 1))}
              >
                Next
              </Button>
            </div>
          </div>
        )}
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
              <LifecycleBadge lifecycle={portDetail.port.lifecycle} />
              <span className="text-xs uppercase font-sans text-text-muted font-medium px-2 py-0.5 bg-surface-2 rounded border border-border">
                {portDetail.port.layer} / {portDetail.port.protocol}
              </span>
            </div>
          ) : (
            'Port Details'
          )
        }
        subtitle={portDetail?.port?.purpose || 'Inspecting port telemetry, features, and routes'}
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
                { id: 'features', label: 'Features' },
                { id: 'lifecycle', label: 'Lifecycle' },
                { id: 'impact', label: 'Impact' },
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
                  <div className="grid grid-cols-[repeat(24,minmax(0,1fr))] gap-1 h-7">
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

                {/* Metadata summary */}
                <div className="grid grid-cols-2 gap-3 text-xs">
                  <div className="p-3 bg-surface-2/50 rounded-lg border border-border">
                    <span className="text-text-muted block">Owner / Team:</span>
                    <span className="text-text font-medium">{portDetail.port.owner || 'Unassigned'}</span>
                  </div>
                  <div className="p-3 bg-surface-2/50 rounded-lg border border-border">
                    <span className="text-text-muted block">Expected Bind:</span>
                    <span className="text-text font-mono">{portDetail.port.expectedBind || '0.0.0.0'}</span>
                  </div>
                  <div className="p-3 bg-surface-2/50 rounded-lg border border-border">
                    <span className="text-text-muted block">Process:</span>
                    <span className="text-text font-mono">{portDetail.port.processName || 'Unknown'} (PID: {portDetail.port.pid || '—'})</span>
                  </div>
                  <div className="p-3 bg-surface-2/50 rounded-lg border border-border">
                    <span className="text-text-muted block">Server Host:</span>
                    <span className="text-text font-medium">{portDetail.port.serverName || 'localhost'}</span>
                  </div>
                </div>

                {/* Inline Notes */}
                <div className="p-3 bg-surface-2/40 border border-border rounded-lg space-y-2 text-xs">
                  <div className="flex items-center justify-between font-semibold text-text">
                    <span>Notes & Runbook</span>
                    {!isViewer && (
                      <button
                        onClick={() => setEditingNotes(!editingNotes)}
                        className="text-primary hover:underline text-[11px]"
                      >
                        {editingNotes ? 'Cancel' : 'Edit Notes'}
                      </button>
                    )}
                  </div>
                  {editingNotes ? (
                    <div className="space-y-2">
                      <textarea
                        rows={3}
                        value={notesText}
                        onChange={(e) => setNotesText(e.target.value)}
                        className="w-full p-2 bg-surface border border-border rounded text-text text-xs"
                      />
                      <Button variant="primary" size="sm" onClick={saveNotes} className="text-xs">
                        Save Notes
                      </Button>
                    </div>
                  ) : (
                    <div className="text-text-muted whitespace-pre-wrap">
                      {portDetail.port.notes || 'No notes documented for this port.'}
                    </div>
                  )}
                </div>

                {/* Tags */}
                <div className="space-y-2">
                  <span className="text-xs font-semibold text-text">Tags</span>
                  <div className="flex flex-wrap items-center gap-1.5">
                    {(portDetail.port.tags || []).map((t) => (
                      <span key={t} className="px-2 py-0.5 rounded bg-surface-2 text-text text-xs border border-border">
                        {t}
                      </span>
                    ))}
                    {!isViewer && (
                      <div className="flex items-center gap-1">
                        <input
                          type="text"
                          placeholder="Add tag"
                          value={newTagInput}
                          onChange={(e) => setNewTagInput(e.target.value)}
                          onKeyDown={(e) => e.key === 'Enter' && addTag()}
                          className="px-2 py-0.5 text-xs bg-surface border border-border rounded w-20"
                        />
                        <button onClick={addTag} className="text-xs text-primary hover:underline font-bold">+</button>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* TAB 2: ROUTES */}
            {activeDrawerTab === 'routes' && (
              <div className="space-y-3">
                <div className="text-xs text-text-muted">
                  {portDetail.routes.length} domain routes configured on this port
                </div>
                <div className="divide-y divide-border border border-border rounded-lg overflow-hidden">
                  {portDetail.routes.map((r) => (
                    <div key={r.id} className="p-3 bg-surface text-xs space-y-1">
                      <div className="flex items-center justify-between font-mono font-bold text-text">
                        <span>{r.domain}{r.path}</span>
                        <ActionBadge action={r.action} />
                      </div>
                      {r.backend && (
                        <div className="text-text-muted text-[11px] font-mono">
                          Upstream: {r.backend.host}:{r.backend.port}
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* TAB 3: FEATURES (PER-PORT FEATURE SWITCHES) */}
            {activeDrawerTab === 'features' && (
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="text-xs text-text-muted">
                    Configure PortWatch behavior and monitoring probes specifically for this port.
                  </div>
                  {!isViewer && (
                    <Button variant="secondary" size="sm" onClick={handleSaveAsPreset} className="text-xs">
                      Save as Preset
                    </Button>
                  )}
                </div>

                <div className="border border-border rounded-lg divide-y divide-border">
                  {registryFeatures.map((feat) => {
                    const existingPortFeature = (portDetail.features || []).find(
                      (f: any) => f.featureKey === feat.key
                    );
                    const isEnabled = existingPortFeature !== undefined ? existingPortFeature.enabled : feat.enabled;

                    return (
                      <div key={feat.key} className="p-3.5 bg-surface space-y-2 hover:bg-surface-2/30 transition-colors">
                        <div className="flex items-center justify-between">
                          <div>
                            <div className="text-xs font-semibold text-text flex items-center gap-2">
                              <span>{feat.label}</span>
                              {!feat.globallyEnabled && (
                                <span className="text-[10px] px-1.5 py-0.2 rounded bg-surface-2 text-text-muted border border-border">
                                  Disabled Globally
                                </span>
                              )}
                            </div>
                            <div className="text-[11px] text-text-muted mt-0.5 line-clamp-2">
                              {feat.description}
                            </div>
                          </div>
                          {!isViewer && (
                            <input
                              type="checkbox"
                              aria-label={`Toggle feature ${feat.key} for port ${portDetail?.port?.port ?? ""}`}
                              checked={isEnabled}
                              onChange={(e) => handleFeatureToggle(feat.key, e.target.checked)}
                              className="w-4 h-4 rounded text-primary focus:ring-primary ml-3"
                            />
                          )}
                        </div>

                        {/* Feature Status Indicator */}
                        <div className="text-[11px] font-mono flex items-center gap-2">
                          <span className={isEnabled ? 'text-status-up' : 'text-text-muted'}>
                            Status: {isEnabled ? 'ENABLED' : 'DISABLED'}
                          </span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* TAB 4: LIFECYCLE (TIMELINE & TRANSITIONS) */}
            {activeDrawerTab === 'lifecycle' && (
              <div className="space-y-4">
                {/* Current Lifecycle Status */}
                <div className="p-3 bg-surface-2/60 border border-border rounded-lg flex items-center justify-between">
                  <div>
                    <span className="text-xs text-text-muted block">Current Lifecycle</span>
                    <span className="text-sm font-bold uppercase text-text">{portDetail.port.lifecycle}</span>
                    {portDetail.port.lifecycleReason && (
                      <div className="text-[11px] text-text-muted mt-0.5">
                        Reason: {portDetail.port.lifecycleReason}
                      </div>
                    )}
                  </div>
                  <LifecycleBadge lifecycle={portDetail.port.lifecycle} size="md" />
                </div>

                {/* Transition Quick Actions (Admin Only) */}
                {!isViewer && (
                  <div className="space-y-2">
                    <span className="text-xs font-semibold text-text uppercase tracking-wider">
                      Change Lifecycle State
                    </span>
                    <div className="grid grid-cols-2 gap-2">
                      <Button
                        variant="secondary"
                        size="sm"
                        onClick={() => changeLifecycle('active')}
                        className="text-xs justify-start"
                      >
                        <CheckCircle2 className="w-3.5 h-3.5 mr-1.5 text-status-up" />
                        Mark Active
                      </Button>
                      <Button
                        variant="secondary"
                        size="sm"
                        onClick={() => changeLifecycle('maintenance', true)}
                        className="text-xs justify-start"
                      >
                        <Clock className="w-3.5 h-3.5 mr-1.5 text-status-slow" />
                        Set Maintenance
                      </Button>
                      <Button
                        variant="secondary"
                        size="sm"
                        onClick={() => changeLifecycle('deprecated', true)}
                        className="text-xs justify-start"
                      >
                        <AlertOctagon className="w-3.5 h-3.5 mr-1.5 text-status-down" />
                        Mark Deprecated
                      </Button>
                      <Button
                        variant="secondary"
                        size="sm"
                        onClick={() => changeLifecycle('planned', true)}
                        className="text-xs justify-start"
                      >
                        <Calendar className="w-3.5 h-3.5 mr-1.5 text-status-info" />
                        Mark Planned
                      </Button>
                    </div>
                  </div>
                )}

                {/* Lifecycle Event History Timeline */}
                <div className="space-y-2">
                  <span className="text-xs font-semibold text-text uppercase tracking-wider">
                    Status Events & Lifecycle Timeline
                  </span>
                  <div className="border border-border rounded-lg divide-y divide-border max-h-56 overflow-y-auto">
                    {(portDetail.statusEvents || []).length === 0 ? (
                      <div className="p-4 text-center text-xs text-text-muted">No status events recorded yet.</div>
                    ) : (
                      portDetail.statusEvents.map((ev: any) => (
                        <div key={ev.id} className="p-3 text-xs bg-surface space-y-1">
                          <div className="flex items-center justify-between font-medium">
                            <span className="text-text">
                              Transition: <span className="uppercase text-text-muted">{ev.fromStatus}</span> → <span className="uppercase font-bold text-primary">{ev.toStatus}</span>
                            </span>
                            <span className="text-[11px] text-text-muted">
                              {new Date(ev.at).toLocaleString()}
                            </span>
                          </div>
                          {ev.details?.reason && (
                            <div className="text-[11px] text-text-muted">
                              Reason: {ev.details.reason}
                            </div>
                          )}
                        </div>
                      ))
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* TAB 5: IMPACT ASSESSMENT */}
            {activeDrawerTab === 'impact' && (
              <div className="space-y-4">
                <div className="p-3 bg-surface-2/60 border border-border rounded-lg text-xs space-y-2">
                  <div className="font-semibold text-text flex items-center justify-between">
                    <span>Dependency Blast Radius</span>
                    <span
                      className={`px-2 py-0.5 rounded text-[11px] font-bold uppercase ${
                        portImpact?.warningLevel === 'dangerous'
                          ? 'bg-status-down/20 text-status-down'
                          : portImpact?.warningLevel === 'caution'
                          ? 'bg-status-slow/20 text-status-slow'
                          : 'bg-status-up/20 text-status-up'
                      }`}
                    >
                      {portImpact?.warningLevel || 'SAFE'}
                    </span>
                  </div>
                  <div className="text-text-muted">
                    If this port goes down or is removed, {portImpact?.routesCount || 0} routes and {portImpact?.domainsCount || 0} domains lose ingress access.
                  </div>
                </div>

                <div className="border border-border rounded-lg divide-y divide-border max-h-64 overflow-y-auto text-xs">
                  {(portImpact?.routes || []).map((r: any) => (
                    <div key={r.id} className="p-3 bg-surface flex items-center justify-between">
                      <span className="font-mono text-text">{r.domain}{r.path}</span>
                      <span className="text-[11px] text-text-muted uppercase font-bold">{r.action}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* TAB 6: CHECKS HISTORY */}
            {activeDrawerTab === 'history' && (
              <div className="space-y-3">
                <div className="text-xs text-text-muted">Last 50 automated TCP/HTTP check results</div>
                <div className="divide-y divide-border border border-border rounded-lg overflow-hidden max-h-96 overflow-y-auto">
                  {portDetail.recentChecks.map((c) => (
                    <div key={c.id} className="p-2.5 bg-surface text-xs flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <StatusBadge status={c.status} size="sm" />
                        <span className="font-mono text-text-muted">{c.checkType.toUpperCase()}</span>
                      </div>
                      <div className="text-text-muted font-mono text-[11px]">
                        {c.latencyMs ? `${c.latencyMs}ms` : '—'} • {new Date(c.checkedAt).toLocaleTimeString()}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* TAB 7: ISSUES */}
            {activeDrawerTab === 'issues' && (
              <div className="space-y-3">
                <div className="text-xs text-text-muted">
                  {portDetail.issues.length} active issues linked to this port
                </div>
                {portDetail.issues.length === 0 ? (
                  <div className="p-6 text-center text-xs text-text-muted border border-border rounded-lg">
                    No active issues on this port.
                  </div>
                ) : (
                  <div className="divide-y divide-border border border-border rounded-lg overflow-hidden">
                    {portDetail.issues.map((i) => (
                      <div key={i.id} className="p-3 bg-surface space-y-1">
                        <div className="flex items-center justify-between">
                          <span className="text-xs font-bold text-text">{i.title}</span>
                          <PriorityBadge priority={i.priority} />
                        </div>
                        <p className="text-[11px] text-text-muted">{i.observed}</p>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
        )}
      </Drawer>

      {/* Add Port Stepper Dialog */}
      <AddPortDialog
        isOpen={isAddPortOpen}
        onClose={() => setIsAddPortOpen(false)}
        prefill={addPortPrefill}
      />

      {/* Remove / Archive Dialog with Impact Assessment */}
      {removePortTarget && (
        <RemovePortDialog
          portId={removePortTarget.id}
          portNumber={removePortTarget.port}
          isOpen={!!removePortTarget}
          onClose={() => setRemovePortTarget(null)}
          onArchived={handlePortArchived}
        />
      )}

      {/* Apply Preset Modal */}
      <ApplyPresetModal
        portIds={selectedIds}
        isOpen={isApplyPresetOpen}
        onClose={() => {
          setIsApplyPresetOpen(false);
          setSelectedIds([]);
        }}
      />

      {/* Trash / Archived Items Modal */}
      <TrashModal
        isOpen={isTrashOpen}
        onClose={() => setIsTrashOpen(false)}
      />
    </div>
  );
}
