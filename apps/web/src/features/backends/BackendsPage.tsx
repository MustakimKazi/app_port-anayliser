import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Server,
  Network,
  AlertTriangle,
  Globe,
  Edit2,
  Layers,
  Plus,
  Archive,
  Trash2
} from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Card, CardHeader, CardTitle } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { StatusBadge } from '../../components/ui/Badge';
import { Modal } from '../../components/ui/Modal';
import { Backend, Server as ServerType } from '../../types';
import { AddBackendDialog } from './AddBackendDialog';
import { AddServerModal, ArchiveServerModal } from './ServerModal';

export function BackendsPage() {
  const queryClient = useQueryClient();

  const { data: currentUser } = useQuery<{ role: string; username: string }>({
    queryKey: ['auth-me'],
    queryFn: () => apiRequest('/auth/me').catch(() => ({ role: 'admin', username: 'admin' })),
    staleTime: 60000
  });
  const isViewer = currentUser?.role === 'viewer';

  const [selectedBackend, setSelectedBackend] = useState<Backend | null>(null);
  const [editingServer, setEditingServer] = useState<ServerType | null>(null);
  const [serverNameInput, setServerNameInput] = useState('');
  const [activeTab, setActiveTab] = useState<'servers' | 'topology' | 'blast'>('servers');
  const [showArchived, setShowArchived] = useState(false);

  // Modals state
  const [isAddBackendOpen, setIsAddBackendOpen] = useState(false);
  const [isAddServerOpen, setIsAddServerOpen] = useState(false);
  const [serverToArchive, setServerToArchive] = useState<ServerType | null>(null);

  // Query Servers
  const { data: servers = [] } = useQuery<ServerType[]>({
    queryKey: ['servers', showArchived],
    queryFn: () => apiRequest(`/servers${showArchived ? '?showArchived=true' : ''}`)
  });

  // Query Backends
  const { data: backends = [] } = useQuery<Backend[]>({
    queryKey: ['backends', showArchived],
    queryFn: () => apiRequest(`/backends${showArchived ? '?showArchived=true' : ''}`)
  });

  // Query Topology Graph & Blast Radius
  const { data: topology } = useQuery<{
    nodes: any[];
    edges: any[];
    blastRadius: Record<string, { backend: string; affectedDomains: string[]; routeCount: number; serverName: string }>;
  }>({
    queryKey: ['topology'],
    queryFn: () => apiRequest('/topology')
  });

  // Rename server mutation
  const renameMutation = useMutation({
    mutationFn: ({ id, name }: { id: string; name: string }) =>
      apiRequest(`/servers/${id}`, {
        method: 'PATCH',
        body: JSON.stringify({ name })
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['servers'] });
      setEditingServer(null);
    }
  });

  const handleOpenRename = (server: ServerType) => {
    setEditingServer(server);
    setServerNameInput(server.name);
  };

  const handleSaveRename = () => {
    if (editingServer && serverNameInput.trim()) {
      renameMutation.mutate({ id: editingServer.id, name: serverNameInput.trim() });
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
            <span>Backends & Servers</span>
            <span className="text-xs font-mono font-medium px-2 py-0.5 rounded-full bg-surface-2 text-primary border border-border">
              5 Server Clusters
            </span>
          </h1>
          <p className="text-xs text-text-muted mt-1">
            Manage physical nodes, upstream app targets, interactive routing topology, and blast radius impact.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          {/* Action Buttons */}
          {!isViewer && (
            <div className="flex items-center gap-2">
              <Button
                variant="primary"
                size="sm"
                onClick={() => setIsAddServerOpen(true)}
                className="text-xs flex items-center gap-1.5"
              >
                <Plus className="w-3.5 h-3.5" />
                <span>Add Server</span>
              </Button>
              <Button
                variant="secondary"
                size="sm"
                onClick={() => setIsAddBackendOpen(true)}
                className="text-xs flex items-center gap-1.5"
              >
                <Plus className="w-3.5 h-3.5" />
                <span>Add Backend</span>
              </Button>
            </div>
          )}

          {/* Show Archived Toggle */}
          <label className="flex items-center gap-2 px-2.5 py-1.5 rounded-lg bg-surface border border-border text-xs text-text cursor-pointer select-none">
            <input
              type="checkbox"
              checked={showArchived}
              onChange={(e) => setShowArchived(e.target.checked)}
              className="rounded border-border text-primary focus:ring-0"
            />
            <span className="text-text-muted">Show Archived</span>
          </label>

          {/* View Switcher Tabs */}
          <div className="flex items-center gap-1.5 p-1 rounded-lg bg-surface border border-border">
            <button
              onClick={() => setActiveTab('servers')}
              className={`px-3 py-1.5 rounded-md text-xs font-medium transition-colors ${
                activeTab === 'servers'
                  ? 'bg-primary text-on-primary shadow-sm'
                  : 'text-text-muted hover:text-text hover:bg-surface-2'
              }`}
            >
              Server Clusters
            </button>
            <button
              onClick={() => setActiveTab('topology')}
              className={`px-3 py-1.5 rounded-md text-xs font-medium transition-colors ${
                activeTab === 'topology'
                  ? 'bg-primary text-on-primary shadow-sm'
                  : 'text-text-muted hover:text-text hover:bg-surface-2'
              }`}
            >
              Dependency Graph
            </button>
            <button
              onClick={() => setActiveTab('blast')}
              className={`px-3 py-1.5 rounded-md text-xs font-medium transition-colors ${
                activeTab === 'blast'
                  ? 'bg-primary text-on-primary shadow-sm'
                  : 'text-text-muted hover:text-text hover:bg-surface-2'
              }`}
            >
              Blast Radius Analysis
            </button>
          </div>
        </div>
      </div>

      {/* VIEW 1: SERVERS & BACKENDS */}
      {activeTab === 'servers' && (
        <div className="space-y-6">
          {/* Server Group Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {servers.map((server) => {
              const serverBackends = backends.filter(
                (b) => b.serverId === server.id || b.host === server.host
              );

              return (
                <Card key={server.id} hover className="flex flex-col justify-between">
                  <div>
                    <div className="flex items-center justify-between pb-3 border-b border-border">
                      <div className="flex items-center gap-2">
                        <Server className="w-5 h-5 text-primary" />
                        <div>
                          <div className="font-bold text-sm text-text flex items-center gap-2">
                            <span>{server.name}</span>
                            {!isViewer && (
                              <div className="flex items-center gap-1">
                                <button
                                  onClick={() => handleOpenRename(server)}
                                  className="text-text-muted hover:text-text transition-colors p-0.5"
                                  title="Rename server"
                                >
                                  <Edit2 className="w-3.5 h-3.5" />
                                </button>
                                <button
                                  onClick={() => setServerToArchive(server)}
                                  className="text-text-muted hover:text-status-down transition-colors p-0.5"
                                  title="Archive server (safe dependency check)"
                                >
                                  <Archive className="w-3.5 h-3.5" />
                                </button>
                              </div>
                            )}
                          </div>
                          <span className="text-[11px] font-mono text-primary">{server.host}</span>
                        </div>
                      </div>
                      <span className="text-[10px] uppercase font-semibold px-2 py-0.5 rounded bg-surface-2 text-text font-mono border border-border">
                        {server.groupLabel || server.kind}
                      </span>
                    </div>

                    <div className="mt-3 space-y-2">
                      <p className="text-xs text-text-muted italic">
                        {server.notes || 'No description provided.'}
                      </p>

                      <div className="pt-2">
                        <div className="text-[11px] uppercase tracking-wider text-text-muted font-semibold mb-2">
                          Active Endpoints ({serverBackends.length})
                        </div>
                        <div className="space-y-1.5 max-h-40 overflow-y-auto pr-1">
                          {serverBackends.length === 0 ? (
                            <div className="text-xs text-text-muted">No active ports assigned.</div>
                          ) : (
                            serverBackends.map((b) => (
                              <div
                                key={b.id}
                                className="flex items-center justify-between p-2 rounded bg-surface-2/60 border border-border text-xs font-mono"
                              >
                                <span className="font-semibold text-text">
                                  {b.host}:{b.port}
                                </span>
                                <div className="flex items-center gap-2 font-sans">
                                  <span className="text-[11px] text-text-muted">
                                    {b.routes?.length || 0} routes
                                  </span>
                                  <StatusBadge status={b.status} size="sm" />
                                </div>
                              </div>
                            ))
                          )}
                        </div>
                      </div>
                    </div>
                  </div>

                  <div className="mt-4 pt-3 border-t border-border flex items-center justify-between text-xs text-text-muted">
                    <span>Kind: {server.kind}</span>
                    <span className="font-mono text-text-muted">{serverBackends.length} ports</span>
                  </div>
                </Card>
              );
            })}
          </div>

          {/* All 34 Backends Full Table */}
          <Card>
            <CardHeader>
              <CardTitle>All Upstream Backends ({backends.length})</CardTitle>
              <span className="text-xs text-text-muted">Every host:port target proxying traffic</span>
            </CardHeader>
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs text-text">
                <thead className="bg-surface-2 text-[11px] uppercase text-text-muted border-b border-border">
                  <tr>
                    <th className="py-3 px-3">Backend Host:Port</th>
                    <th className="py-3 px-3">Server Cluster</th>
                    <th className="py-3 px-3">Status</th>
                    <th className="py-3 px-3">Latency</th>
                    <th className="py-3 px-3">Assigned Routes</th>
                    <th className="py-3 px-3">Notes</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border font-sans">
                  {backends.map((b) => (
                    <tr key={b.id} className="hover:bg-surface-2 transition-colors">
                      <td className="py-2.5 px-3 font-mono font-bold text-text">
                        {b.host}:{b.port}
                      </td>
                      <td className="py-2.5 px-3 text-text">
                        {b.server?.name || b.host}
                      </td>
                      <td className="py-2.5 px-3">
                        <StatusBadge status={b.status} size="sm" />
                      </td>
                      <td className="py-2.5 px-3 font-mono text-xs">
                        {b.latencyMs !== null ? `${b.latencyMs}ms` : '—'}
                      </td>
                      <td className="py-2.5 px-3 font-mono text-text">
                        {b.routes?.length || 0}
                      </td>
                      <td className="py-2.5 px-3 text-text-muted max-w-xs truncate">
                        {b.notes || '—'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </Card>
        </div>
      )}

      {/* VIEW 2: TOPOLOGY DEPENDENCY GRAPH */}
      {activeTab === 'topology' && (
        <Card className="p-6 space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-border">
            <div>
              <h3 className="text-base font-semibold text-text flex items-center gap-2">
                <Network className="w-5 h-5 text-primary" />
                <span>Interactive Routing Topology (Domain → Port → Backend)</span>
              </h3>
              <p className="text-xs text-text-muted mt-0.5">
                Visualizing relationships between public domains, listening ports, and target application nodes.
              </p>
            </div>
            <div className="flex items-center gap-4 text-xs font-mono">
              <span className="flex items-center gap-1.5 text-text">
                <span className="w-2.5 h-2.5 rounded-full bg-primary" /> Domain Nodes
              </span>
              <span className="flex items-center gap-1.5 text-text">
                <span className="w-2.5 h-2.5 rounded-full bg-accent" /> Port Nodes
              </span>
              <span className="flex items-center gap-1.5 text-text">
                <span className="w-2.5 h-2.5 rounded-full bg-action-return" /> Upstream Nodes
              </span>
            </div>
          </div>

          {/* Interactive Topology Visual Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 py-4">
            {/* Column 1: Public Domains */}
            <div className="space-y-3">
              <div className="text-xs uppercase font-bold text-primary tracking-wider flex items-center gap-1.5">
                <Globe className="w-4 h-4" />
                <span>Public Ingress Domains</span>
              </div>
              <div className="space-y-2 max-h-[500px] overflow-y-auto pr-2">
                {topology?.nodes.filter((n) => n.type === 'domain').slice(0, 25).map((node) => (
                  <div
                    key={node.id}
                    className="p-2.5 rounded-lg border border-primary/30 bg-primary/10 text-xs font-mono text-primary hover:border-primary transition-colors"
                  >
                    {node.data.label}
                  </div>
                ))}
              </div>
            </div>

            {/* Column 2: Ports */}
            <div className="space-y-3">
              <div className="text-xs uppercase font-bold text-accent tracking-wider flex items-center gap-1.5">
                <Layers className="w-4 h-4" />
                <span>Server Listening Ports</span>
              </div>
              <div className="space-y-2 max-h-[500px] overflow-y-auto pr-2">
                {topology?.nodes.filter((n) => n.type === 'port').map((node) => (
                  <div
                    key={node.id}
                    className="p-3 rounded-lg border border-accent/30 bg-accent/10 text-xs flex items-center justify-between hover:border-accent transition-colors"
                  >
                    <span className="font-mono font-bold text-accent">{node.data.label}</span>
                    <StatusBadge status={node.data.status} size="sm" />
                  </div>
                ))}
              </div>
            </div>

            {/* Column 3: Backend Nodes */}
            <div className="space-y-3">
              <div className="text-xs uppercase font-bold text-action-return tracking-wider flex items-center gap-1.5">
                <Server className="w-4 h-4" />
                <span>Upstream Backend Clusters</span>
              </div>
              <div className="space-y-2 max-h-[500px] overflow-y-auto pr-2">
                {topology?.nodes.filter((n) => n.type === 'backend').slice(0, 25).map((node) => (
                  <div
                    key={node.id}
                    className="p-2.5 rounded-lg border border-action-return/30 bg-action-return/10 text-xs flex items-center justify-between hover:border-action-return transition-colors"
                  >
                    <div>
                      <div className="font-mono font-semibold text-action-return">{node.data.label}</div>
                      <div className="text-[10px] text-text-muted">{node.data.server}</div>
                    </div>
                    <StatusBadge status={node.data.status} size="sm" />
                  </div>
                ))}
              </div>
            </div>
          </div>
        </Card>
      )}

      {/* VIEW 3: BLAST RADIUS CALCULATOR */}
      {activeTab === 'blast' && (
        <Card className="p-6 space-y-5">
          <div className="pb-3 border-b border-border">
            <h3 className="text-base font-semibold text-status-down flex items-center gap-2">
              <AlertTriangle className="w-5 h-5" />
              <span>Blast Radius & Dependency Impact Analysis</span>
            </h3>
            <p className="text-xs text-text-muted mt-0.5">
              Simulate server outages to see which user-facing domains and customer applications are impacted.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {topology?.blastRadius &&
              Object.values(topology.blastRadius).map((item) => (
                <div
                  key={item.backend}
                  className="p-4 rounded-xl border border-border bg-surface-2/60 space-y-3 hover:border-status-down/60 transition-colors"
                >
                  <div className="flex items-center justify-between">
                    <span className="font-mono font-bold text-sm text-text">{item.backend}</span>
                    <span className="text-[11px] font-mono px-2 py-0.5 rounded bg-status-down/20 text-status-down font-semibold border border-status-down/30">
                      {item.affectedDomains.length} domains break
                    </span>
                  </div>

                  <div className="text-xs text-text-muted">
                    Host Server: <span className="text-text font-medium">{item.serverName}</span>
                  </div>

                  <div className="space-y-1">
                    <span className="text-[11px] uppercase font-semibold text-text-muted">
                      Affected Ingress Domains:
                    </span>
                    <div className="flex flex-wrap gap-1.5 pt-1">
                      {item.affectedDomains.length === 0 ? (
                        <span className="text-xs text-text-muted">No public domains routed</span>
                      ) : (
                        item.affectedDomains.map((domain) => (
                          <span
                            key={domain}
                            className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-mono bg-surface text-text border border-border"
                          >
                            <Globe className="w-3 h-3 text-primary" />
                            <span>{domain}</span>
                          </span>
                        ))
                      )}
                    </div>
                  </div>
                </div>
              ))}
          </div>
        </Card>
      )}

      {/* Rename Server Modal */}
      <Modal
        isOpen={!!editingServer}
        onClose={() => setEditingServer(null)}
        title="Rename Server Cluster"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-xs font-medium text-text-muted mb-1">Server Name</label>
            <input
              type="text"
              value={serverNameInput}
              onChange={(e) => setServerNameInput(e.target.value)}
              className="w-full px-3 py-2 rounded-lg bg-surface border border-border-strong text-sm text-text focus:outline-none focus:border-primary"
              placeholder="e.g. App Server A"
            />
          </div>
          <div className="text-xs text-text-muted">
            Host IP:{' '}
            <span className="font-mono font-semibold text-primary">{editingServer?.host}</span>
          </div>
          <div className="flex justify-end gap-2 pt-2">
            <Button variant="ghost" size="sm" onClick={() => setEditingServer(null)}>
              Cancel
            </Button>
            <Button variant="primary" size="sm" onClick={handleSaveRename}>
              Save Name
            </Button>
          </div>
        </div>
      </Modal>

      {/* Add Backend Dialog */}
      <AddBackendDialog
        isOpen={isAddBackendOpen}
        onClose={() => setIsAddBackendOpen(false)}
      />

      {/* Add Server Modal */}
      <AddServerModal
        isOpen={isAddServerOpen}
        onClose={() => setIsAddServerOpen(false)}
      />

      {/* Archive Server Modal with Safe Dependency Check */}
      <ArchiveServerModal
        server={serverToArchive}
        onClose={() => setServerToArchive(null)}
      />
    </div>
  );
}
