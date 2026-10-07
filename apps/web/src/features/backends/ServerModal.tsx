import React, { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { AlertTriangle, Server, CheckCircle2 } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Button } from '../../components/ui/Button';
import { Modal } from '../../components/ui/Modal';
import { Server as ServerType } from '../../types';

interface AddServerModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function AddServerModal({ isOpen, onClose }: AddServerModalProps) {
  const queryClient = useQueryClient();
  const [name, setName] = useState('');
  const [host, setHost] = useState('');
  const [kind, setKind] = useState<'backend' | 'entry' | 'database'>('backend');
  const [notes, setNotes] = useState('');

  const createMutation = useMutation({
    mutationFn: (data: any) =>
      apiRequest('/servers', {
        method: 'POST',
        body: JSON.stringify(data)
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['servers'] });
      resetAndClose();
    }
  });

  const resetAndClose = () => {
    setName('');
    setHost('');
    setKind('backend');
    setNotes('');
    onClose();
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;

    createMutation.mutate({
      name: name.trim(),
      host: host.trim() || undefined,
      kind,
      notes: notes.trim()
    });
  };

  if (!isOpen) return null;

  return (
    <Modal isOpen={isOpen} onClose={resetAndClose} title="Add Server Node">
      <form onSubmit={handleSubmit} className="space-y-4 text-xs">
        <div>
          <label className="block text-text font-semibold mb-1">Server Name *</label>
          <input
            type="text"
            required
            placeholder="e.g. Primary Web Edge, Auth Worker 1"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
          />
        </div>

        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className="block text-text font-semibold mb-1">Host / IP (Optional)</label>
            <input
              type="text"
              placeholder="e.g. 10.0.0.10"
              value={host}
              onChange={(e) => setHost(e.target.value)}
              className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
            />
          </div>

          <div>
            <label className="block text-text font-semibold mb-1">Role / Kind</label>
            <select
              value={kind}
              onChange={(e) => setKind(e.target.value as any)}
              className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
            >
              <option value="backend">Backend Application</option>
              <option value="entry">Entrypoint Proxy</option>
              <option value="database">Database</option>
            </select>
          </div>
        </div>

        <div>
          <label className="block text-text font-semibold mb-1">Notes</label>
          <input
            type="text"
            placeholder="Description or location"
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
          />
        </div>

        <div className="flex justify-end gap-2 pt-3 border-t border-border">
          <Button type="button" variant="secondary" size="sm" onClick={resetAndClose}>
            Cancel
          </Button>
          <Button
            type="submit"
            variant="primary"
            size="sm"
            isLoading={createMutation.isPending}
          >
            Create Server
          </Button>
        </div>
      </form>
    </Modal>
  );
}

interface ArchiveServerModalProps {
  server: ServerType | null;
  onClose: () => void;
}

export function ArchiveServerModal({ server, onClose }: ArchiveServerModalProps) {
  const queryClient = useQueryClient();

  const { data: impact, isLoading } = useQuery<{
    isBlocked: boolean;
    activePortsCount: number;
    activeBackendsCount: number;
    message: string;
  }>({
    queryKey: ['server-impact', server?.id],
    queryFn: () => apiRequest(`/servers/${server?.id}/impact`),
    enabled: !!server
  });

  const archiveMutation = useMutation({
    mutationFn: () =>
      apiRequest(`/servers/${server?.id}/archive`, {
        method: 'POST',
        body: JSON.stringify({ reason: 'Archived from servers management' })
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['servers'] });
      onClose();
    }
  });

  if (!server) return null;

  return (
    <Modal isOpen={!!server} onClose={onClose} title={`Archive Server: ${server.name}`}>
      <div className="space-y-4 text-xs">
        {isLoading ? (
          <div className="py-6 text-center text-text-muted">Analyzing active dependencies...</div>
        ) : impact?.isBlocked ? (
          <div className="space-y-3">
            <div className="p-3 rounded-lg bg-status-down/10 border border-status-down/30 text-status-down flex items-start gap-2.5">
              <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5" />
              <div>
                <div className="font-bold">Cannot Archive Server (Active Dependencies)</div>
                <div className="mt-1 text-[11px] text-text-muted">{impact.message}</div>
              </div>
            </div>
            <p className="text-text-muted">
              Please migrate or archive all associated ports and backends before archiving this server node.
            </p>
            <div className="flex justify-end pt-2">
              <Button variant="secondary" size="sm" onClick={onClose}>
                Close
              </Button>
            </div>
          </div>
        ) : (
          <div className="space-y-3">
            <div className="p-3 rounded-lg bg-status-up/10 border border-status-up/30 text-status-up flex items-start gap-2.5">
              <CheckCircle2 className="w-4 h-4 shrink-0 mt-0.5" />
              <div>
                <div className="font-bold">Safe to Archive</div>
                <div className="mt-1 text-[11px] text-text-muted">
                  No active ports or backends are linked to this server.
                </div>
              </div>
            </div>
            <p className="text-text-muted">
              Archiving hides this server from default views while preserving historical audit logs. You can restore it later.
            </p>
            <div className="flex justify-end gap-2 pt-3 border-t border-border">
              <Button variant="secondary" size="sm" onClick={onClose}>
                Cancel
              </Button>
              <Button
                variant="primary"
                size="sm"
                onClick={() => archiveMutation.mutate()}
                isLoading={archiveMutation.isPending}
              >
                Confirm Archive Server
              </Button>
            </div>
          </div>
        )}
      </div>
    </Modal>
  );
}
