import React, { useMemo, useState, useRef } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  ArrowLeft,
  FileCode,
  Copy,
  Check,
  Download,
  Pencil,
  Server,
  Globe,
  Map as MapIcon,
  Layers,
  ChevronRight,
  AlertTriangle,
  ClipboardPaste,
  Trash2,
  Archive,
  RotateCcw
} from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { parseNginx, tokenizeNginxLine, TOKEN_CLASS, NginxBlock } from '../../lib/nginx';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Modal } from '../../components/ui/Modal';
import { DropdownMenu } from '../../components/ui/DropdownMenu';
import { ActionBadge } from '../../components/ui/Badge';
import { ConfigFile } from '../../types';

function notify(message: string) {
  window.dispatchEvent(new CustomEvent('app-toast', { detail: message }));
}

export function ConfigFileDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const { data: currentUser } = useQuery<{ role: string; username: string }>({
    queryKey: ['auth-me'],
    queryFn: () => apiRequest('/auth/me').catch(() => ({ role: 'viewer', username: 'guest' })),
    staleTime: 60000
  });
  const isViewer = currentUser?.role === 'viewer';

  const { data: file, isLoading, isError, refetch } = useQuery<ConfigFile>({
    queryKey: ['config-file', id],
    queryFn: () => apiRequest(`/config-files/${id}`),
    enabled: !!id
  });

  const [isEditorOpen, setIsEditorOpen] = useState(false);
  const [draft, setDraft] = useState('');
  const [selectedBlock, setSelectedBlock] = useState<NginxBlock | null>(null);
  const [copiedAll, setCopiedAll] = useState(false);
  const codeRef = useRef<HTMLDivElement>(null);

  const content = file?.content || '';
  const parse = useMemo(() => (content ? parseNginx(content) : null), [content]);
  const lines = useMemo(() => content.split('\n'), [content]);
  const tokenized = useMemo(() => lines.map(tokenizeNginxLine), [lines]);

  const saveMutation = useMutation({
    mutationFn: (newContent: string) =>
      apiRequest(`/config-files/${id}`, {
        method: 'PATCH',
        body: JSON.stringify({ content: newContent })
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-file', id] });
      queryClient.invalidateQueries({ queryKey: ['config-files'] });
      notify('Configuration saved');
      setIsEditorOpen(false);
      setSelectedBlock(null);
    }
  });

  const [confirmModal, setConfirmModal] = useState<'archive' | 'delete' | null>(null);

  const archiveMutation = useMutation({
    mutationFn: () => apiRequest(`/config-files/${id}/archive`, { method: 'POST' }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-file', id] });
      queryClient.invalidateQueries({ queryKey: ['config-files'] });
      notify('Config file archived (marked for delete later)');
      setConfirmModal(null);
    }
  });

  const restoreMutation = useMutation({
    mutationFn: () => apiRequest(`/config-files/${id}/restore`, { method: 'POST' }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-file', id] });
      queryClient.invalidateQueries({ queryKey: ['config-files'] });
      notify('Config file restored to active');
      setConfirmModal(null);
    }
  });

  const deleteMutation = useMutation({
    mutationFn: () => apiRequest(`/config-files/${id}?permanent=true`, { method: 'DELETE' }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-files'] });
      queryClient.invalidateQueries({ queryKey: ['trash-overview'] });
      notify('Config file permanently deleted (snapshot saved to Trash)');
      navigate('/config-files');
    }
  });

  const openEditor = () => {
    setDraft(content);
    setIsEditorOpen(true);
  };

  const handleDownload = () => {
    if (!file) return;
    const blob = new Blob([content], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = file.filename.endsWith('.conf') ? file.filename : `${file.filename}.conf`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
  };

  const handleCopyAll = () => {
    navigator.clipboard.writeText(content);
    setCopiedAll(true);
    setTimeout(() => setCopiedAll(false), 2000);
  };

  const selectBlock = (block: NginxBlock) => {
    setSelectedBlock(block);
    requestAnimationFrame(() => {
      const el = codeRef.current?.querySelector(`[data-line="${block.startLine}"]`);
      el?.scrollIntoView({ block: 'center', behavior: 'smooth' });
    });
  };

  if (isLoading) {
    return (
      <div className="space-y-4 animate-pulse" data-testid="config-loading">
        <div className="h-8 w-1/3 rounded bg-surface-2" />
        <div className="h-96 rounded-xl bg-surface-2" />
      </div>
    );
  }

  if (isError || !file) {
    return (
      <div className="p-6 rounded-xl border border-status-down/30 bg-status-down/10 text-sm text-text space-y-2" data-testid="config-error">
        <div className="font-semibold text-status-down">Failed to load config file</div>
        <Button variant="secondary" size="sm" className="text-xs" onClick={() => refetch()}>
          <span>Retry</span>
        </Button>
        <div>
          <Link to="/config-files" className="text-primary underline text-xs">
            Back to Config Files
          </Link>
        </div>
      </div>
    );
  }

  const isBackup = file.status === 'backup';
  const isArchived = file.status === 'archived';
  const servers = parse?.blocks.filter((b) => b.type === 'server') || [];
  const upstreams = parse?.blocks.filter((b) => b.type === 'upstream') || [];
  const maps = parse?.blocks.filter((b) => b.type === 'map') || [];
  const others = parse?.blocks.filter((b) => ['http', 'stream', 'events', 'other'].includes(b.type)) || [];

  const sidebarButton = (block: NginxBlock, icon: React.ReactNode, depth = 0) => (
    <button
      key={`${block.startLine}-${block.endLine}-${block.label}`}
      onClick={() => selectBlock(block)}
      className={`w-full text-left px-2.5 py-1.5 rounded-md text-[11px] font-mono flex items-center gap-1.5 transition-colors border ${
        selectedBlock && selectedBlock.startLine === block.startLine && selectedBlock.endLine === block.endLine
          ? 'bg-primary/15 border-primary/40 text-primary'
          : 'border-transparent text-text-muted hover:bg-surface-2 hover:text-text'
      }`}
      style={{ paddingLeft: `${10 + depth * 14}px` }}
      data-testid="partition-item"
      title={`Lines ${block.startLine}–${block.endLine}`}
    >
      {icon}
      <span className="truncate">{block.label}</span>
      <span className="ml-auto text-[9px] opacity-60 shrink-0">
        {block.startLine}–{block.endLine}
      </span>
    </button>
  );

  return (
    <div className="space-y-5" data-testid="config-detail-page">
      {/* Header */}
      <div className="flex flex-col lg:flex-row lg:items-start justify-between gap-4">
        <div className="min-w-0">
          <button
            onClick={() => navigate('/config-files')}
            className="flex items-center gap-1.5 text-xs text-text-muted hover:text-text transition-colors mb-2"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Back to Config Files</span>
          </button>
          <h1 className="text-xl font-bold tracking-tight text-text flex items-center gap-2.5 flex-wrap">
            <FileCode
              className={`w-5 h-5 ${
                isArchived ? 'text-text-muted' : isBackup ? 'text-status-slow' : 'text-primary'
              }`}
            />
            <span className="font-mono break-all">{file.filename}</span>
            <span
              className={`text-[10px] uppercase font-mono font-semibold px-2 py-0.5 rounded-full ${
                isArchived
                  ? 'bg-surface-2 text-text-muted border border-border'
                  : isBackup
                    ? 'bg-status-slow/15 text-status-slow border border-status-slow/30'
                    : 'bg-status-up/15 text-status-up border border-status-up/30'
              }`}
            >
              {isArchived ? 'Archived (Delete Later)' : isBackup ? 'Backup (Not Loaded)' : 'Active (Loaded)'}
            </span>
          </h1>
          <p className="text-xs text-text-muted mt-1">{file.description || 'Virtual host configuration'}</p>
          <div className="flex flex-wrap items-center gap-3 mt-2 text-[11px] text-text-muted">
            {content ? (
              <>
                <span className="font-mono">{lines.length} lines</span>
                <span className="font-mono">{new Blob([content]).size} bytes</span>
                {parse && <span className="font-mono">{servers.length} servers</span>}
                {file.updatedAt && <span>updated {new Date(file.updatedAt).toLocaleString()}</span>}
              </>
            ) : (
              <span className="text-status-slow">No configuration stored yet</span>
            )}
          </div>
        </div>

        <div className="flex items-center gap-2 shrink-0 flex-wrap">
          {content && (
            <>
              <Button variant="secondary" size="sm" className="text-xs flex items-center gap-1.5" onClick={handleCopyAll}>
                {copiedAll ? <Check className="w-3.5 h-3.5 text-status-up" /> : <Copy className="w-3.5 h-3.5" />}
                <span>{copiedAll ? 'Copied' : 'Copy All'}</span>
              </Button>
              <Button variant="secondary" size="sm" className="text-xs flex items-center gap-1.5" onClick={handleDownload}>
                <Download className="w-3.5 h-3.5" />
                <span>Download</span>
              </Button>
            </>
          )}
          {!isViewer && (
            <>
              <Button variant="primary" size="sm" className="text-xs flex items-center gap-1.5" onClick={openEditor}>
                <Pencil className="w-3.5 h-3.5" />
                <span>{content ? 'Edit Config' : 'Paste Config'}</span>
              </Button>
              <DropdownMenu
                title="Config file options"
                items={
                  isArchived
                    ? [
                        {
                          label: 'Restore to Active',
                          icon: <RotateCcw className="w-3.5 h-3.5" />,
                          onClick: () => restoreMutation.mutate()
                        },
                        {
                          label: 'Delete Permanently',
                          icon: <Trash2 className="w-3.5 h-3.5" />,
                          variant: 'danger',
                          onClick: () => setConfirmModal('delete')
                        }
                      ]
                    : [
                        {
                          label: 'Archive (Delete Later)',
                          icon: <Archive className="w-3.5 h-3.5 text-status-slow" />,
                          onClick: () => setConfirmModal('archive')
                        },
                        {
                          label: 'Delete Permanently',
                          icon: <Trash2 className="w-3.5 h-3.5" />,
                          variant: 'danger',
                          onClick: () => setConfirmModal('delete')
                        }
                      ]
                }
              />
            </>
          )}
        </div>
      </div>

      {/* Archived banner */}
      {isArchived && (
        <div className="p-4 rounded-xl border border-border bg-surface-2/40 flex items-center justify-between gap-4 text-xs">
          <div className="flex items-center gap-2.5">
            <Archive className="w-5 h-5 text-status-slow shrink-0" />
            <div>
              <span className="font-bold text-text">This config file is archived (marked for delete later)</span>
              <p className="text-text-muted">It is currently unloaded and inactive. You can restore it to active anytime or delete it permanently.</p>
            </div>
          </div>
          {!isViewer && (
            <Button
              variant="secondary"
              size="sm"
              className="text-xs flex items-center gap-1.5 shrink-0"
              onClick={() => restoreMutation.mutate()}
              isLoading={restoreMutation.isPending}
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span>Restore to Active</span>
            </Button>
          )}
        </div>
      )}

      {parse && parse.errors.length > 0 && (
        <div className="p-3 rounded-lg border border-status-slow/30 bg-status-slow/10 text-xs text-status-slow flex items-start gap-2" data-testid="parse-warnings">
          <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5" />
          <div>
            <span className="font-semibold">Parser warnings: </span>
            {parse.errors.slice(0, 3).join('; ')}
          </div>
        </div>
      )}

      {/* Empty state */}
      {!content ? (
        <Card className="py-14 text-center space-y-4" data-testid="config-empty">
          <ClipboardPaste className="w-10 h-10 text-text-muted mx-auto" />
          <div>
            <div className="text-sm font-semibold text-text">No configuration stored for {file.filename}</div>
            <p className="text-xs text-text-muted mt-1 max-w-md mx-auto">
              Paste the full nginx config text for this file. PortWatch will parse it and partition the view into
              upstreams, server blocks, and locations.
            </p>
          </div>
          {!isViewer ? (
            <Button variant="primary" size="sm" className="text-xs" onClick={openEditor}>
              <ClipboardPaste className="w-3.5 h-3.5" />
              <span>Paste your nginx config</span>
            </Button>
          ) : (
            <span className="text-xs text-text-muted">Ask an administrator to paste the configuration.</span>
          )}
        </Card>
      ) : (
        /* Viewer: partition sidebar + raw config */
        <div className="grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-4 items-start">
          {/* Partition sidebar */}
          <Card className="p-3 space-y-4 max-h-[70vh] overflow-y-auto" data-testid="partition-sidebar">
            <div className="text-[10px] uppercase tracking-wider font-bold text-text-muted px-1">
              Partitions ({servers.length + upstreams.length + maps.length + others.length})
            </div>

            {upstreams.length > 0 && (
              <div className="space-y-1">
                <div className="text-[10px] font-semibold text-primary flex items-center gap-1.5 px-1">
                  <Server className="w-3 h-3" /> Upstreams ({upstreams.length})
                </div>
                {upstreams.map((b) => sidebarButton(b, <ChevronRight className="w-3 h-3 shrink-0" />))}
              </div>
            )}

            {servers.length > 0 && (
              <div className="space-y-1">
                <div className="text-[10px] font-semibold text-primary flex items-center gap-1.5 px-1">
                  <Globe className="w-3 h-3" /> Servers ({servers.length})
                </div>
                {servers.map((b) => (
                  <div key={`srv-${b.startLine}`} className="space-y-0.5">
                    {sidebarButton(b, <Globe className="w-3 h-3 shrink-0" />)}
                    {b.children
                      .filter((c) => c.type === 'location' || c.type === 'if')
                      .map((c) => sidebarButton(c, <ChevronRight className="w-3 h-3 shrink-0" />, 1))}
                  </div>
                ))}
              </div>
            )}

            {maps.length > 0 && (
              <div className="space-y-1">
                <div className="text-[10px] font-semibold text-primary flex items-center gap-1.5 px-1">
                  <MapIcon className="w-3 h-3" /> Maps ({maps.length})
                </div>
                {maps.map((b) => sidebarButton(b, <ChevronRight className="w-3 h-3 shrink-0" />))}
              </div>
            )}

            {others.length > 0 && (
              <div className="space-y-1">
                <div className="text-[10px] font-semibold text-primary flex items-center gap-1.5 px-1">
                  <Layers className="w-3 h-3" /> Other Blocks ({others.length})
                </div>
                {others.map((b) => sidebarButton(b, <ChevronRight className="w-3 h-3 shrink-0" />))}
              </div>
            )}
          </Card>

          {/* Raw config with line numbers + syntax highlight */}
          <Card className="overflow-hidden">
            <div className="flex items-center justify-between px-4 py-2.5 border-b border-border bg-surface-2/60">
              <span className="text-[11px] font-mono text-text-muted">{file.filename}</span>
              {selectedBlock && (
                <span className="text-[10px] font-mono text-primary">
                  {selectedBlock.type} · lines {selectedBlock.startLine}–{selectedBlock.endLine}
                </span>
              )}
            </div>
            <div
              ref={codeRef}
              className="overflow-auto max-h-[70vh] font-mono text-[11px] leading-5"
              tabIndex={0}
              role="region"
              aria-label="Nginx config content"
              data-testid="config-code"
            >
              {tokenized.map((tokens, idx) => {
                const lineNo = idx + 1;
                const inRange =
                  selectedBlock && lineNo >= selectedBlock.startLine && lineNo <= selectedBlock.endLine;
                return (
                  <div
                    key={lineNo}
                    data-line={lineNo}
                    className={`flex border-l-2 ${inRange ? 'bg-primary/10 border-primary' : 'border-transparent'}`}
                  >
                    <span className="w-12 shrink-0 select-none text-right pr-3 text-text-muted/50 bg-surface-2/40">
                      {lineNo}
                    </span>
                    <code className="pl-3 pr-4 whitespace-pre min-w-full">
                      {tokens.length === 0 ? (
                        ' '
                      ) : (
                        tokens.map((t, i) => (
                          <span key={i} className={TOKEN_CLASS[t.cls] || 'text-text'}>
                            {t.text}
                          </span>
                        ))
                      )}
                    </code>
                  </div>
                );
              })}
            </div>
          </Card>
        </div>
      )}

      {/* Attached routes */}
      {file.routes && file.routes.length > 0 && (
        <Card className="overflow-hidden" data-testid="config-routes">
          <div className="px-4 py-3 border-b border-border flex items-center justify-between">
            <span className="text-xs font-semibold text-text">
              Routes Defined in this File ({file.routes.length})
            </span>
            <Link to="/routes" className="text-[11px] text-primary hover:underline">
              View in Domains & Routes
            </Link>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-surface-2 text-[10px] uppercase text-text-muted border-b border-border">
                <tr>
                  <th className="py-2.5 px-4">Domain</th>
                  <th className="py-2.5 px-4">Path</th>
                  <th className="py-2.5 px-4">Port</th>
                  <th className="py-2.5 px-4">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {file.routes.map((r) => (
                  <tr key={r.id}>
                    <td className="py-2.5 px-4 font-mono font-bold text-text">{r.domain}</td>
                    <td className="py-2.5 px-4 font-mono text-text-muted">{r.path}</td>
                    <td className="py-2.5 px-4 font-mono text-text-muted">
                      {r.portNum ? `:${r.portNum}` : '—'}
                    </td>
                    <td className="py-2.5 px-4">
                      <ActionBadge action={r.action as any} />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {/* Paste / Edit modal */}
      <Modal
        isOpen={isEditorOpen}
        onClose={() => setIsEditorOpen(false)}
        title={content ? `Edit ${file.filename}` : `Paste nginx config — ${file.filename}`}
        maxWidth="max-w-4xl"
      >
        <div className="space-y-3">
          <p className="text-xs text-text-muted">
            Paste the complete nginx configuration for this file. Saving updates the stored content and re-parses the
            partitions.
          </p>
          <textarea
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            spellCheck={false}
            placeholder={'server {\n    listen 443 ssl;\n    server_name example.com;\n    ...\n}'}
            aria-label="Nginx configuration content"
            className="w-full h-[55vh] p-4 rounded-lg bg-surface border border-border font-mono text-xs text-text placeholder-text-muted focus:outline-none focus:border-primary resize-y"
            data-testid="config-editor"
          />
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-mono text-text-muted">
              {draft ? `${draft.split('\n').length} lines · ${new Blob([draft]).size} bytes` : 'empty'}
            </span>
            <div className="flex items-center gap-2">
              <Button variant="secondary" size="sm" className="text-xs" onClick={() => setIsEditorOpen(false)}>
                <span>Cancel</span>
              </Button>
              <Button
                variant="primary"
                size="sm"
                className="text-xs"
                onClick={() => saveMutation.mutate(draft)}
                isLoading={saveMutation.isPending}
              >
                <span>Save Config</span>
              </Button>
            </div>
          </div>
        </div>
      </Modal>

      {/* Confirmation Modal */}
      <Modal
        isOpen={!!confirmModal}
        onClose={() => setConfirmModal(null)}
        title={
          confirmModal === 'archive'
            ? 'Archive Config File (Delete Later)'
            : 'Permanently Delete Config File'
        }
        footer={
          <div className="flex items-center justify-end gap-2">
            <Button variant="secondary" size="sm" onClick={() => setConfirmModal(null)}>
              Cancel
            </Button>
            {confirmModal === 'archive' ? (
              <Button
                variant="primary"
                size="sm"
                isLoading={archiveMutation.isPending}
                onClick={() => archiveMutation.mutate()}
              >
                Archive (Delete Later)
              </Button>
            ) : (
              <div className="flex items-center gap-2">
                {!isArchived && (
                  <Button
                    variant="secondary"
                    size="sm"
                    isLoading={archiveMutation.isPending}
                    onClick={() => archiveMutation.mutate()}
                  >
                    Archive Instead
                  </Button>
                )}
                <Button
                  variant="danger"
                  size="sm"
                  isLoading={deleteMutation.isPending}
                  onClick={() => deleteMutation.mutate()}
                >
                  Delete Permanently
                </Button>
              </div>
            )}
          </div>
        }
      >
        <div className="space-y-4 text-xs text-text">
          <div
            className={`p-3 rounded-lg border ${
              confirmModal === 'delete'
                ? 'bg-status-down/10 border-status-down/30 text-status-down'
                : 'bg-status-slow/10 border-status-slow/30 text-status-slow'
            }`}
          >
            <div className="flex items-center gap-2 font-semibold mb-1">
              <AlertTriangle className="w-4 h-4 shrink-0" />
              <span>
                {confirmModal === 'delete'
                  ? 'Permanently delete this configuration file?'
                  : 'Move configuration file to Archive?'}
              </span>
            </div>
            <p className="text-text font-mono font-medium">Filename: {file.filename}</p>
          </div>

          {confirmModal === 'delete' ? (
            <p className="text-text-muted leading-relaxed">
              This will remove <code className="font-mono text-text">{file.filename}</code> from PortWatch. A snapshot will be saved to Trash so you can restore it if necessary. Attached routes will be safely unlinked.
            </p>
          ) : (
            <p className="text-text-muted leading-relaxed">
              Archiving marks this file as <span className="font-semibold text-text">Archived (Delete Later)</span>. It will be excluded from active virtual host audits while keeping your configuration text safe. You can restore it anytime.
            </p>
          )}
        </div>
      </Modal>
    </div>
  );
}
