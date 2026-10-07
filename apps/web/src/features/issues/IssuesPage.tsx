import React, { useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Search,
  Send,
  MessageSquare,
  ChevronRight,
  Plus,
  Zap,
  CheckCircle2
} from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { PriorityBadge } from '../../components/ui/Badge';
import { CodeBlock } from '../../components/ui/CodeBlock';
import { Drawer } from '../../components/ui/Drawer';
import { Issue, IssueStatus } from '../../types';
import { AddPortDialog } from '../ports/AddPortDialog';

export function IssuesPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const queryClient = useQueryClient();

  const { data: currentUser } = useQuery<{ role: string; username: string }>({
    queryKey: ['auth-me'],
    queryFn: () => apiRequest('/auth/me').catch(() => ({ role: 'admin', username: 'admin' })),
    staleTime: 60000
  });
  const isViewer = currentUser?.role === 'viewer';

  const priorityFilter = searchParams.get('priority') || '';
  const statusFilter = searchParams.get('status') || '';
  const sourceFilter = searchParams.get('source') || '';
  const q = searchParams.get('q') || '';

  const [viewMode, setViewMode] = useState<'kanban' | 'table'>('kanban');
  const [selectedIssue, setSelectedIssue] = useState<Issue | null>(null);
  const [commentInput, setCommentInput] = useState('');

  // Add Port Dialog state for undocumented ports
  const [isAddPortOpen, setIsAddPortOpen] = useState(false);
  const [addPortPrefill, setAddPortPrefill] = useState<{
    port?: number;
    processName?: string;
    bindAddress?: string;
  } | undefined>(undefined);

  // Fetch issues
  const { data: issues = [] } = useQuery<Issue[]>({
    queryKey: ['issues', searchParams.toString()],
    queryFn: () => {
      const qs = searchParams.toString();
      return apiRequest(`/issues?${qs}`);
    }
  });

  const updateFilter = (key: string, value: string) => {
    const next = new URLSearchParams(searchParams);
    if (!value) next.delete(key);
    else next.set(key, value);
    setSearchParams(next);
  };

  // Status transition mutation
  const statusMutation = useMutation({
    mutationFn: ({ id, status, comment }: { id: string; status: IssueStatus; comment?: string }) =>
      apiRequest(`/issues/${id}`, {
        method: 'PATCH',
        body: JSON.stringify({ status, newComment: comment })
      }),
    onSuccess: (updated) => {
      queryClient.invalidateQueries({ queryKey: ['issues'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
      if (selectedIssue?.id === updated.id) {
        setSelectedIssue(updated);
      }
    }
  });

  const markActiveMutation = useMutation({
    mutationFn: async ({ portId, issueId }: { portId: string; issueId: string }) => {
      await apiRequest(`/ports/${portId}/lifecycle`, {
        method: 'POST',
        body: JSON.stringify({ lifecycle: 'active', reason: 'Activated from listening detection in issues' })
      });
      await apiRequest(`/issues/${issueId}`, {
        method: 'PATCH',
        body: JSON.stringify({ status: 'resolved', newComment: 'Marked active via one-click resolution' })
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['issues'] });
      queryClient.invalidateQueries({ queryKey: ['ports'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
      setSelectedIssue(null);
    }
  });

  const handleAddComment = () => {
    if (!selectedIssue || !commentInput.trim()) return;
    statusMutation.mutate({
      id: selectedIssue.id,
      status: selectedIssue.status,
      comment: commentInput.trim()
    });
    setCommentInput('');
  };

  // Kanban columns
  const COLUMNS: { id: IssueStatus; label: string; bg: string }[] = [
    { id: 'open', label: 'Open', bg: 'border-status-down/40 bg-status-down/10' },
    { id: 'acknowledged', label: 'Acknowledged', bg: 'border-status-slow/40 bg-status-slow/10' },
    { id: 'resolved', label: 'Resolved', bg: 'border-status-up/40 bg-status-up/10' },
    { id: 'ignored', label: 'Ignored', bg: 'border-border bg-surface-2/40' }
  ];

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
            <span>Issues & Health Checks</span>
            <span className="text-xs font-mono font-medium px-2 py-0.5 rounded-full bg-surface-2 text-primary border border-border">
              {issues.length} detected
            </span>
          </h1>
          <p className="text-xs text-text-muted mt-1">
            Misconfiguration warnings, duplicate ports (8080, 9000), unencrypted ports, and resolution steps.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button
            variant={viewMode === 'kanban' ? 'primary' : 'secondary'}
            size="sm"
            onClick={() => setViewMode('kanban')}
            className="text-xs"
          >
            Kanban Workflow
          </Button>
          <Button
            variant={viewMode === 'table' ? 'primary' : 'secondary'}
            size="sm"
            onClick={() => setViewMode('table')}
            className="text-xs"
          >
            Table View
          </Button>
        </div>
      </div>

      {/* Filter Bar */}
      <Card className="p-4 space-y-3">
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-3">
          <div className="relative">
            <Search className="w-4 h-4 text-text-muted absolute left-3 top-2.5" />
            <input
              type="text"
              value={q}
              onChange={(e) => updateFilter('q', e.target.value)}
              placeholder="Search title, observation, check command..."
              className="w-full pl-9 pr-3 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text placeholder-text-muted focus:outline-none focus:border-primary"
            />
          </div>

          <select
            value={priorityFilter}
            onChange={(e) => updateFilter('priority', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Priority: All</option>
            <option value="High">High</option>
            <option value="Medium">Medium</option>
            <option value="Low">Low</option>
            <option value="Info">Info</option>
          </select>

          <select
            value={statusFilter}
            onChange={(e) => updateFilter('status', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Status: All</option>
            <option value="open">Open</option>
            <option value="acknowledged">Acknowledged</option>
            <option value="resolved">Resolved</option>
            <option value="ignored">Ignored</option>
          </select>

          <select
            value={sourceFilter}
            onChange={(e) => updateFilter('source', e.target.value)}
            className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
          >
            <option value="">Source: All</option>
            <option value="imported">Imported (Sheet)</option>
            <option value="auto-detected">Auto-Detected</option>
            <option value="manual">Manual</option>
          </select>
        </div>
      </Card>

      {/* VIEW 1: KANBAN BOARD */}
      {viewMode === 'kanban' ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {COLUMNS.map((col) => {
            const colIssues = issues.filter((i) => i.status === col.id);

            return (
              <div key={col.id} className="space-y-3">
                {/* Column Header */}
                <div className="flex items-center justify-between px-3 py-2 rounded-lg bg-surface border border-border">
                  <span className="text-xs font-bold text-text uppercase tracking-wider">{col.label}</span>
                  <span className="font-mono text-xs font-bold px-2 py-0.5 rounded-full bg-surface-2 text-text border border-border">
                    {colIssues.length}
                  </span>
                </div>

                {/* Column Cards */}
                <div className="space-y-3 min-h-[450px]">
                  {colIssues.map((issue) => (
                    <div
                      key={issue.id}
                      onClick={() => setSelectedIssue(issue)}
                      className={`p-4 rounded-xl border ${col.bg} hover:border-border-strong cursor-pointer transition-all space-y-3 group shadow-sm`}
                    >
                      <div className="flex items-start justify-between gap-2">
                        <span className="text-xs font-bold text-text group-hover:text-primary transition-colors">
                          {issue.title}
                        </span>
                        <PriorityBadge priority={issue.priority} />
                      </div>

                      <p className="text-xs text-text-muted line-clamp-2">{issue.observed}</p>

                      {/* Code Block Snippet for Verification Command */}
                      <div onClick={(e) => e.stopPropagation()}>
                        <CodeBlock code={issue.recommendation} />
                      </div>

                      {/* Card Footer */}
                      <div className="flex items-center justify-between text-[11px] text-text-muted pt-1 border-t border-border">
                        <span className="font-mono">#{issue.issueNum || 'auto'}</span>
                        <div className="flex items-center gap-2">
                          {issue.source === 'auto-detected' && (
                            <span className="text-[10px] px-1.5 py-0.2 rounded bg-primary/20 text-primary border border-primary/30">
                              auto
                            </span>
                          )}
                          <span className="text-primary group-hover:translate-x-0.5 transition-transform flex items-center gap-0.5">
                            Details <ChevronRight className="w-3 h-3" />
                          </span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        /* VIEW 2: TABLE VIEW */
        <Card className="overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-text">
              <thead className="bg-surface-2 text-[11px] uppercase text-text-muted border-b border-border">
                <tr>
                  <th className="py-3 px-3">#</th>
                  <th className="py-3 px-3">Priority</th>
                  <th className="py-3 px-3">Status</th>
                  <th className="py-3 px-3">Item / Title</th>
                  <th className="py-3 px-3">What Was Seen</th>
                  <th className="py-3 px-3">Resolution Command</th>
                  <th className="py-3 px-3">Source</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border font-sans">
                {issues.map((issue) => (
                  <tr
                    key={issue.id}
                    onClick={() => setSelectedIssue(issue)}
                    className="hover:bg-surface-2 cursor-pointer transition-colors"
                  >
                    <td className="py-2.5 px-3 font-mono text-text-muted">{issue.issueNum || '—'}</td>
                    <td className="py-2.5 px-3">
                      <PriorityBadge priority={issue.priority} />
                    </td>
                    <td className="py-2.5 px-3 uppercase font-semibold text-[11px]">
                      <span
                        className={
                          issue.status === 'open'
                            ? 'text-status-down'
                            : issue.status === 'acknowledged'
                            ? 'text-status-slow'
                            : 'text-status-up'
                        }
                      >
                        {issue.status}
                      </span>
                    </td>
                    <td className="py-2.5 px-3 font-semibold text-text max-w-xs truncate">{issue.title}</td>
                    <td className="py-2.5 px-3 text-text-muted max-w-sm truncate">{issue.observed}</td>
                    <td className="py-2.5 px-3 font-mono text-primary max-w-xs truncate" onClick={(e) => e.stopPropagation()}>
                      <CodeBlock code={issue.recommendation} inline />
                    </td>
                    <td className="py-2.5 px-3 font-mono text-[11px] text-text-muted">{issue.source}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {/* Issue Detail & Workflow Drawer */}
      <Drawer
        isOpen={!!selectedIssue}
        onClose={() => setSelectedIssue(null)}
        title={
          selectedIssue ? (
            <div className="flex items-center gap-2">
              <PriorityBadge priority={selectedIssue.priority} />
              <span>{selectedIssue.title}</span>
            </div>
          ) : (
            'Issue Details'
          )
        }
        subtitle={`Status: ${selectedIssue?.status.toUpperCase()} • Source: ${selectedIssue?.source}`}
      >
        {selectedIssue && (() => {
          const isUndocumented = selectedIssue.title.toLowerCase().includes('undocumented') || selectedIssue.autoKey?.includes('auto-undocumented');
          const isPlannedListening = (selectedIssue.title.toLowerCase().includes('planned') || selectedIssue.title.toLowerCase().includes('reserved')) && (selectedIssue.title.toLowerCase().includes('listening') || selectedIssue.autoKey?.includes('auto-planned-listening'));
          const portMatch = selectedIssue.title.match(/port\s+(\d+)/i) || selectedIssue.observed.match(/port\s+(\d+)/i);
          const extractedPort = portMatch ? parseInt(portMatch[1], 10) : undefined;
          const procMatch = selectedIssue.observed.match(/process\s+'([^']+)'/i);
          const extractedProcess = procMatch ? procMatch[1] : undefined;
          const bindMatch = selectedIssue.observed.match(/\((0\.0\.0\.0|127\.0\.0\.1|[\d\.:]+)\)/);
          const extractedBind = bindMatch ? bindMatch[1] : undefined;

          return (
          <div className="space-y-6">
            {/* Planned Port Now Listening One-Click Action Banner */}
            {isPlannedListening && selectedIssue.relatedPortId && (
              <div className="p-4 rounded-xl border border-primary/40 bg-primary/10 flex items-center justify-between gap-3">
                <div>
                  <div className="text-xs font-bold text-text flex items-center gap-1.5">
                    <Zap className="w-4 h-4 text-primary" />
                    <span>Port {extractedPort} is planned and now listening!</span>
                  </div>
                  <div className="text-[11px] text-text-muted mt-0.5">
                    The background scanner found this port listening on the host. Mark it active with one click to begin automated checks and alerts.
                  </div>
                </div>
                {!isViewer && (
                  <Button
                    variant="primary"
                    size="sm"
                    className="text-xs shrink-0"
                    onClick={() =>
                      markActiveMutation.mutate({
                        portId: selectedIssue.relatedPortId!,
                        issueId: selectedIssue.id
                      })
                    }
                    isLoading={markActiveMutation.isPending}
                  >
                    Mark Active (One-Click)
                  </Button>
                )}
              </div>
            )}

            {/* Undocumented Listening Port Action Banner */}
            {isUndocumented && (
              <div className="p-4 rounded-xl border border-accent/40 bg-accent/10 flex items-center justify-between gap-3">
                <div>
                  <div className="text-xs font-bold text-text flex items-center gap-1.5">
                    <Plus className="w-4 h-4 text-accent" />
                    <span>Undocumented Port {extractedPort} Detected</span>
                  </div>
                  <div className="text-[11px] text-text-muted mt-0.5">
                    Process: <span className="font-mono text-text">{extractedProcess || 'unknown'}</span> • Bind: <span className="font-mono text-text">{extractedBind || 'unknown'}</span>. Add it to PortWatch documentation now.
                  </div>
                </div>
                {!isViewer && (
                  <Button
                    variant="primary"
                    size="sm"
                    className="text-xs shrink-0"
                    onClick={() => {
                      setAddPortPrefill({
                        port: extractedPort,
                        processName: extractedProcess,
                        bindAddress: extractedBind
                      });
                      setIsAddPortOpen(true);
                    }}
                  >
                    Add to Documentation
                  </Button>
                )}
              </div>
            )}

            {/* Status Workflow Action Buttons */}
            <div className="p-4 rounded-xl border border-border bg-surface-2/60 space-y-2">
              <span className="text-xs font-semibold text-text">Workflow Actions</span>
              <div className="flex flex-wrap items-center gap-2 pt-1">
                {selectedIssue.status !== 'acknowledged' && (
                  <Button
                    variant="secondary"
                    size="sm"
                    onClick={() =>
                      statusMutation.mutate({ id: selectedIssue.id, status: 'acknowledged' })
                    }
                  >
                    Mark Acknowledged
                  </Button>
                )}
                {selectedIssue.status !== 'resolved' && (
                  <Button
                    variant="teal"
                    size="sm"
                    onClick={() =>
                      statusMutation.mutate({ id: selectedIssue.id, status: 'resolved' })
                    }
                  >
                    Mark Resolved
                  </Button>
                )}
                {selectedIssue.status !== 'open' && (
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => statusMutation.mutate({ id: selectedIssue.id, status: 'open' })}
                  >
                    Reopen Issue
                  </Button>
                )}
                {selectedIssue.status !== 'ignored' && (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => statusMutation.mutate({ id: selectedIssue.id, status: 'ignored' })}
                  >
                    Ignore
                  </Button>
                )}
              </div>
            </div>

            {/* Observed state */}
            <div className="space-y-2">
              <span className="text-xs font-semibold text-text">Observation</span>
              <div className="p-3 rounded-lg border border-border bg-surface-2/40 text-xs text-text">
                {selectedIssue.observed}
              </div>
            </div>

            {/* Verification / Fix Command */}
            <div className="space-y-2">
              <span className="text-xs font-semibold text-text">What to check / do:</span>
              <CodeBlock code={selectedIssue.recommendation} />
            </div>

            {/* Comments Thread */}
            <div className="space-y-3">
              <span className="text-xs font-semibold text-text flex items-center gap-1.5">
                <MessageSquare className="w-4 h-4 text-primary" />
                <span>Comments & Discussion</span>
              </span>

              <div className="space-y-2 max-h-48 overflow-y-auto pr-1">
                {(!selectedIssue.comments || selectedIssue.comments.length === 0) ? (
                  <div className="text-xs text-text-muted py-3">No comments yet.</div>
                ) : (
                  selectedIssue.comments.map((c, idx) => (
                    <div key={idx} className="p-2.5 rounded bg-surface border border-border text-xs space-y-1">
                      <div className="flex items-center justify-between text-text-muted text-[11px]">
                        <span className="font-semibold text-text">{c.author}</span>
                        <span className="font-mono">{new Date(c.at).toLocaleString()}</span>
                      </div>
                      <p className="text-text">{c.text}</p>
                    </div>
                  ))
                )}
              </div>

              {/* Add comment input */}
              <div className="flex items-center gap-2 pt-2">
                <input
                  type="text"
                  placeholder="Add a comment or note..."
                  value={commentInput}
                  onChange={(e) => setCommentInput(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleAddComment()}
                  className="flex-1 px-3 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text placeholder-text-muted focus:outline-none focus:border-primary"
                />
                <Button variant="primary" size="sm" onClick={handleAddComment}>
                  <Send className="w-3.5 h-3.5" />
                </Button>
              </div>
            </div>
          </div>
          );
        })()}
      </Drawer>

      {/* Add Port Dialog for undocumented ports */}
      <AddPortDialog
        isOpen={isAddPortOpen}
        onClose={() => {
          setIsAddPortOpen(false);
          setAddPortPrefill(undefined);
        }}
        prefill={addPortPrefill}
      />
    </div>
  );
}
