import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  FileCode,
  AlertCircle,
  Search,
  ChevronRight,
  ClipboardPaste,
  Trash2,
  Archive,
  RotateCcw,
  AlertTriangle
} from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Modal } from '../../components/ui/Modal';
import { DropdownMenu } from '../../components/ui/DropdownMenu';
import { ConfigFile } from '../../types';

function notify(message: string) {
  window.dispatchEvent(new CustomEvent('app-toast', { detail: message }));
}

export function ConfigFilesPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [filter, setFilter] = useState<'all' | 'active' | 'backup' | 'archived'>('all');
  const [search, setSearch] = useState('');
  const [targetFile, setTargetFile] = useState<{
    file: ConfigFile;
    action: 'archive' | 'delete';
  } | null>(null);

  const { data: currentUser } = useQuery<{ role: string; username: string }>({
    queryKey: ['auth-me'],
    queryFn: () => apiRequest('/auth/me').catch(() => ({ role: 'viewer', username: 'guest' })),
    staleTime: 60000
  });
  const isViewer = currentUser?.role === 'viewer';

  const { data, isLoading } = useQuery<{
    files: ConfigFile[];
    stats: { total: number; activeCount: number; backupCount: number; archivedCount: number };
  }>({
    queryKey: ['config-files'],
    queryFn: () => apiRequest('/config-files')
  });

  const archiveMutation = useMutation({
    mutationFn: (fileId: string) =>
      apiRequest(`/config-files/${fileId}/archive`, { method: 'POST' }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-files'] });
      notify('Config file archived (marked for delete later)');
      setTargetFile(null);
    }
  });

  const restoreMutation = useMutation({
    mutationFn: (fileId: string) =>
      apiRequest(`/config-files/${fileId}/restore`, { method: 'POST' }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-files'] });
      notify('Config file restored to active');
      setTargetFile(null);
    }
  });

  const deleteMutation = useMutation({
    mutationFn: (fileId: string) =>
      apiRequest(`/config-files/${fileId}?permanent=true`, { method: 'DELETE' }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-files'] });
      queryClient.invalidateQueries({ queryKey: ['trash-overview'] });
      notify('Config file permanently deleted (snapshot saved to Trash)');
      setTargetFile(null);
    }
  });

  const files = (data?.files || [])
    .filter((f) => {
      if (filter === 'active') return f.status === 'active';
      if (filter === 'backup') return f.status === 'backup';
      if (filter === 'archived') return f.status === 'archived';
      return true;
    })
    .filter(
      (f) =>
        !search ||
        f.filename.toLowerCase().includes(search.toLowerCase()) ||
        (f.description && f.description.toLowerCase().includes(search.toLowerCase()))
    );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
            <span>Nginx Configuration Files</span>
            <span className="text-xs font-mono font-medium px-2 py-0.5 rounded-full bg-surface-2 text-primary border border-border">
              {data?.stats.total ?? 0} files
            </span>
          </h1>
          <p className="text-xs text-text-muted mt-1">
            Active virtual host definitions, inactive backups, and archived configs in{' '}
            <code className="text-primary font-mono">/etc/nginx/conf.d/</code>.
          </p>
        </div>

        {/* Filter Pills */}
        <div className="flex items-center gap-1.5 p-1 rounded-lg bg-surface border border-border text-xs flex-wrap">
          <button
            onClick={() => setFilter('all')}
            className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
              filter === 'all' ? 'bg-primary text-on-primary' : 'text-text-muted hover:text-text'
            }`}
          >
            All Files ({data?.stats.total ?? 0})
          </button>
          <button
            onClick={() => setFilter('active')}
            className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
              filter === 'active' ? 'bg-status-up text-on-primary' : 'text-text-muted hover:text-text'
            }`}
          >
            Active Loaded ({data?.stats.activeCount ?? 0})
          </button>
          <button
            onClick={() => setFilter('backup')}
            className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
              filter === 'backup' ? 'bg-status-slow text-on-primary' : 'text-text-muted hover:text-text'
            }`}
          >
            Backup Unloaded ({data?.stats.backupCount ?? 0})
          </button>
          <button
            onClick={() => setFilter('archived')}
            className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
              filter === 'archived' ? 'bg-status-slow text-on-primary' : 'text-text-muted hover:text-text'
            }`}
          >
            Archived / Delete Later ({data?.stats.archivedCount ?? 0})
          </button>
        </div>
      </div>

      {/* Warning Alert for Backup Files */}
      {data?.stats.backupCount && data.stats.backupCount > 0 && filter !== 'archived' && (
        <div className="p-4 rounded-xl border border-status-slow/30 bg-status-slow/10 flex items-start gap-3 text-xs text-status-slow">
          <AlertCircle className="w-5 h-5 text-status-slow shrink-0 mt-0.5" />
          <div className="space-y-1">
            <span className="font-bold text-status-slow">
              {data.stats.backupCount} Backup Configuration Files Detected in conf.d
            </span>
            <p className="text-text-muted">
              Files with extensions like <code className="font-mono text-text bg-surface-2 px-1 rounded">.bak</code> or <code className="font-mono text-text bg-surface-2 px-1 rounded">.save</code> are not loaded by Nginx. Moving them to an archive directory avoids naming confusion and stale audit alerts.
            </p>
          </div>
        </div>
      )}

      {/* Info Alert if viewing Archived files */}
      {filter === 'archived' && (
        <div className="p-4 rounded-xl border border-border bg-surface-2/40 flex items-start gap-3 text-xs text-text">
          <Archive className="w-5 h-5 text-status-slow shrink-0 mt-0.5" />
          <div className="space-y-1">
            <span className="font-bold text-text">Archived Config Files (Delete Later)</span>
            <p className="text-text-muted">
              These configuration files are queued for later deletion or safekeeping. They are not active in production. You can restore them to active status or permanently remove them at any time.
            </p>
          </div>
        </div>
      )}

      {/* Search Input */}
      <div className="relative">
        <Search className="w-4 h-4 text-text-muted absolute left-3.5 top-3" />
        <input
          type="text"
          placeholder="Filter config files by filename or domain purpose..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full pl-10 pr-4 py-2 rounded-xl bg-surface border border-border text-xs text-text placeholder-text-muted focus:outline-none focus:border-primary"
        />
      </div>

      {/* Config Files Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {files.map((file) => {
          const isBackup = file.status === 'backup';
          const isArchived = file.status === 'archived';

          return (
            <Card
              key={file.id}
              hover
              onClick={() => navigate(`/config-files/${file.id}`)}
              data-testid="config-card"
              className={`space-y-3 cursor-pointer ${
                isArchived
                  ? 'border-border/80 bg-surface-2/30 opacity-90'
                  : isBackup
                    ? 'border-status-slow/30 bg-status-slow/5'
                    : 'border-border'
              }`}
            >
              <div className="flex items-start justify-between gap-2">
                <div className="flex items-center gap-2 min-w-0">
                  <FileCode
                    className={`w-4 h-4 shrink-0 ${
                      isArchived ? 'text-text-muted' : isBackup ? 'text-status-slow' : 'text-primary'
                    }`}
                  />
                  <span className="font-mono text-xs font-bold text-text truncate" title={file.filename}>
                    {file.filename}
                  </span>
                </div>
                <div className="flex items-center gap-1.5 shrink-0">
                  <span
                    className={`text-[10px] uppercase font-mono font-semibold px-2 py-0.5 rounded-full shrink-0 ${
                      isArchived
                        ? 'bg-surface-2 text-text-muted border border-border'
                        : isBackup
                          ? 'bg-status-slow/15 text-status-slow border border-status-slow/30'
                          : 'bg-status-up/15 text-status-up border border-status-up/30'
                    }`}
                  >
                    {isArchived ? 'Archived (Delete Later)' : isBackup ? 'Backup (Not Loaded)' : 'Active (Loaded)'}
                  </span>
                  {!isViewer && (
                    <DropdownMenu
                      title="Config file actions"
                      items={
                        isArchived
                          ? [
                              {
                                label: 'Open Config Details',
                                icon: <FileCode className="w-3.5 h-3.5" />,
                                onClick: () => navigate(`/config-files/${file.id}`)
                              },
                              {
                                label: 'Restore to Active',
                                icon: <RotateCcw className="w-3.5 h-3.5" />,
                                onClick: () => restoreMutation.mutate(file.id)
                              },
                              {
                                label: 'Delete Permanently',
                                icon: <Trash2 className="w-3.5 h-3.5" />,
                                variant: 'danger',
                                onClick: () => setTargetFile({ file, action: 'delete' })
                              }
                            ]
                          : [
                              {
                                label: 'Open Config Details',
                                icon: <FileCode className="w-3.5 h-3.5" />,
                                onClick: () => navigate(`/config-files/${file.id}`)
                              },
                              {
                                label: 'Archive (Delete Later)',
                                icon: <Archive className="w-3.5 h-3.5 text-status-slow" />,
                                onClick: () => setTargetFile({ file, action: 'archive' })
                              },
                              {
                                label: 'Delete Permanently',
                                icon: <Trash2 className="w-3.5 h-3.5" />,
                                variant: 'danger',
                                onClick: () => setTargetFile({ file, action: 'delete' })
                              }
                            ]
                      }
                    />
                  )}
                </div>
              </div>

              <p className="text-xs text-text-muted line-clamp-2">
                {file.description || 'Virtual host configuration'}
              </p>

              {/* Defined routes count + content indicator */}
              <div className="pt-2 border-t border-border/60 flex items-center justify-between text-[11px] text-text-muted">
                <span>Defined Routes:</span>
                <span className="font-mono font-bold text-text">
                  {file.routes?.length || 0} routes
                </span>
              </div>
              <div className="flex items-center justify-between text-[11px]">
                {file.hasContent ? (
                  <span className="flex items-center gap-1 text-status-up">
                    <FileCode className="w-3 h-3" />
                    <span>Config stored</span>
                  </span>
                ) : (
                  <span className="flex items-center gap-1 text-status-slow">
                    <ClipboardPaste className="w-3 h-3" />
                    <span>No config yet</span>
                  </span>
                )}
                <span className="flex items-center gap-0.5 text-primary">
                  <span>Open</span>
                  <ChevronRight className="w-3 h-3" />
                </span>
              </div>
            </Card>
          );
        })}
      </div>

      {files.length === 0 && !isLoading && (
        <div className="py-12 text-center text-text-muted text-xs">
          No configuration files found matching the selected filter.
        </div>
      )}

      {/* Confirmation Modal */}
      <Modal
        isOpen={!!targetFile}
        onClose={() => setTargetFile(null)}
        title={
          targetFile?.action === 'archive'
            ? 'Archive Config File (Delete Later)'
            : 'Permanently Delete Config File'
        }
        footer={
          <div className="flex items-center justify-end gap-2">
            <Button variant="secondary" size="sm" onClick={() => setTargetFile(null)}>
              Cancel
            </Button>
            {targetFile?.action === 'archive' ? (
              <Button
                variant="primary"
                size="sm"
                isLoading={archiveMutation.isPending}
                onClick={() => {
                  if (targetFile) archiveMutation.mutate(targetFile.file.id);
                }}
              >
                Archive (Delete Later)
              </Button>
            ) : (
              <div className="flex items-center gap-2">
                <Button
                  variant="secondary"
                  size="sm"
                  isLoading={archiveMutation.isPending}
                  onClick={() => {
                    if (targetFile) archiveMutation.mutate(targetFile.file.id);
                  }}
                >
                  Archive Instead
                </Button>
                <Button
                  variant="danger"
                  size="sm"
                  isLoading={deleteMutation.isPending}
                  onClick={() => {
                    if (targetFile) deleteMutation.mutate(targetFile.file.id);
                  }}
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
              targetFile?.action === 'delete'
                ? 'bg-status-down/10 border-status-down/30 text-status-down'
                : 'bg-status-slow/10 border-status-slow/30 text-status-slow'
            }`}
          >
            <div className="flex items-center gap-2 font-semibold mb-1">
              <AlertTriangle className="w-4 h-4 shrink-0" />
              <span>
                {targetFile?.action === 'delete'
                  ? 'Permanently remove configuration file?'
                  : 'Move configuration file to Archive?'}
              </span>
            </div>
            <p className="text-text font-mono font-medium">
              Filename: {targetFile?.file.filename}
            </p>
          </div>

          {targetFile?.action === 'delete' ? (
            <p className="text-text-muted leading-relaxed">
              This will permanently delete <code className="font-mono text-text">{targetFile?.file.filename}</code> from PortWatch. A safety snapshot will be preserved in the Trash bin so you can restore it if needed. Any attached routes will be detached without deleting them.
            </p>
          ) : (
            <p className="text-text-muted leading-relaxed">
              Archiving marks this file as <span className="font-semibold text-text">Archived (Delete Later)</span>. It will be excluded from active Nginx audits while retaining its content and configuration details. You can review or restore it at any time from the "Archived / Delete Later" tab.
            </p>
          )}
        </div>
      </Modal>
    </div>
  );
}
