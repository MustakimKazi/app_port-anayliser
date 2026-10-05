import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { FileCode, AlertCircle, CheckCircle, Search, Globe, ChevronRight } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Card } from '../../components/ui/Card';
import { ConfigFile } from '../../types';

export function ConfigFilesPage() {
  const [filter, setFilter] = useState<'all' | 'active' | 'backup'>('all');
  const [search, setSearch] = useState('');

  const { data, isLoading } = useQuery<{
    files: ConfigFile[];
    stats: { total: number; activeCount: number; backupCount: number };
  }>({
    queryKey: ['config-files'],
    queryFn: () => apiRequest('/config-files')
  });

  const files = (data?.files || []).filter((f) => {
    if (filter === 'active') return f.status === 'active';
    if (filter === 'backup') return f.status === 'backup';
    return true;
  }).filter((f) => !search || f.filename.toLowerCase().includes(search.toLowerCase()) || (f.description && f.description.toLowerCase().includes(search.toLowerCase())));

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
            <span>Nginx Configuration Files</span>
            <span className="text-xs font-mono font-medium px-2 py-0.5 rounded-full bg-surface-2 text-primary border border-border">
              {data?.stats.total ?? 48} files
            </span>
          </h1>
          <p className="text-xs text-text-muted mt-1">
            Active virtual host definitions vs. inactive backup files located in <code className="text-primary font-mono">/etc/nginx/conf.d/</code>.
          </p>
        </div>

        {/* Filter Pills */}
        <div className="flex items-center gap-1.5 p-1 rounded-lg bg-surface border border-border text-xs">
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
            Backup Unloaded ({data?.stats.backupCount ?? 10})
          </button>
        </div>
      </div>

      {/* Warning Alert for 10 Backup Files */}
      {data?.stats.backupCount && data.stats.backupCount > 0 && (
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
          return (
            <Card
              key={file.id}
              hover
              className={`space-y-3 ${
                isBackup ? 'border-status-slow/30 bg-status-slow/5' : 'border-border'
              }`}
            >
              <div className="flex items-start justify-between gap-2">
                <div className="flex items-center gap-2">
                  <FileCode
                    className={`w-4 h-4 ${isBackup ? 'text-status-slow' : 'text-primary'}`}
                  />
                  <span className="font-mono text-xs font-bold text-text truncate max-w-[200px]" title={file.filename}>
                    {file.filename}
                  </span>
                </div>
                <span
                  className={`text-[10px] uppercase font-mono font-semibold px-2 py-0.5 rounded-full ${
                    isBackup
                      ? 'bg-status-slow/15 text-status-slow border border-status-slow/30'
                      : 'bg-status-up/15 text-status-up border border-status-up/30'
                  }`}
                >
                  {isBackup ? 'Backup (Not Loaded)' : 'Active (Loaded)'}
                </span>
              </div>

              <p className="text-xs text-text-muted line-clamp-2">
                {file.description || 'Virtual host configuration'}
              </p>

              {/* Defined routes count */}
              <div className="pt-2 border-t border-border/60 flex items-center justify-between text-[11px] text-text-muted">
                <span>Defined Routes:</span>
                <span className="font-mono font-bold text-text">
                  {file.routes?.length || 0} routes
                </span>
              </div>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
