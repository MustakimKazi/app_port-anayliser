import React from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Calendar, CheckCircle2, Clock, AlertTriangle, ArrowRight } from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Button } from '../../components/ui/Button';
import { Port } from '../../types';

interface PlannedPortsWidgetProps {
  ports: Port[];
  onOpenPort: (portId: string) => void;
}

export function PlannedPortsWidget({ ports, onOpenPort }: PlannedPortsWidgetProps) {
  const queryClient = useQueryClient();

  const plannedPorts = ports
    .filter((p) => p.lifecycle === 'planned')
    .sort((a, b) => {
      if (!a.targetDate) return 1;
      if (!b.targetDate) return -1;
      return new Date(a.targetDate).getTime() - new Date(b.targetDate).getTime();
    });

  const now = new Date();

  // Mark Active Mutation
  const markActiveMutation = useMutation({
    mutationFn: async (portId: string) => {
      return apiRequest(`/ports/${portId}/lifecycle`, {
        method: 'POST',
        body: JSON.stringify({
          lifecycle: 'active',
          reason: 'Activated via planned ports schedule'
        })
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ports'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
    }
  });

  // Postpone Mutation (add 7 days)
  const postponeMutation = useMutation({
    mutationFn: async ({ portId, currentTarget }: { portId: string; currentTarget?: string | null }) => {
      const baseDate = currentTarget ? new Date(currentTarget) : new Date();
      baseDate.setDate(baseDate.getDate() + 7);
      return apiRequest(`/ports/${portId}/lifecycle`, {
        method: 'POST',
        body: JSON.stringify({
          lifecycle: 'planned',
          targetDate: baseDate.toISOString().split('T')[0],
          reason: 'Postponed by 7 days'
        })
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ports'] });
      queryClient.invalidateQueries({ queryKey: ['overview'] });
    }
  });

  if (plannedPorts.length === 0) return null;

  return (
    <div className="bg-surface border border-border rounded-xl p-4 space-y-3">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Calendar className="w-4 h-4 text-status-info" />
          <span className="text-xs font-semibold text-text uppercase tracking-wider">
            Planned Ports Timeline ({plannedPorts.length})
          </span>
        </div>
        <span className="text-[11px] text-text-muted">Sorted by target opening date</span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2.5">
        {plannedPorts.slice(0, 6).map((p) => {
          const isOverdue = p.targetDate && new Date(p.targetDate) < now;
          const formattedDate = p.targetDate
            ? new Date(p.targetDate).toLocaleDateString()
            : 'No date set';

          return (
            <div
              key={p.id}
              className={`p-3 rounded-lg border text-xs flex flex-col justify-between transition-colors ${
                isOverdue
                  ? 'bg-status-slow/10 border-status-slow/30'
                  : 'bg-surface-2/60 border-border hover:bg-surface-2'
              }`}
            >
              <div>
                <div className="flex items-center justify-between mb-1">
                  <button
                    onClick={() => onOpenPort(p.id)}
                    className="font-mono font-bold text-text hover:text-primary transition-colors flex items-center gap-1"
                  >
                    <span>Port :{p.port}</span>
                    <ArrowRight className="w-3 h-3 opacity-60" />
                  </button>
                  {isOverdue ? (
                    <span className="text-[10px] px-1.5 py-0.5 rounded font-bold uppercase tracking-wider bg-status-slow/20 text-status-slow border border-status-slow/40 flex items-center gap-1">
                      <AlertTriangle className="w-2.5 h-2.5" /> Overdue
                    </span>
                  ) : (
                    <span className="text-[10px] px-1.5 py-0.5 rounded font-medium bg-surface text-text-muted border border-border">
                      {formattedDate}
                    </span>
                  )}
                </div>

                <div className="text-[11px] text-text-muted line-clamp-1">
                  {p.purpose || 'No purpose'} • Owner: {p.owner || 'Unassigned'}
                </div>
              </div>

              <div className="flex items-center gap-2 mt-3 pt-2 border-t border-border/50">
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => markActiveMutation.mutate(p.id)}
                  isLoading={markActiveMutation.isPending}
                  className="flex-1 text-[11px] py-1 h-7"
                >
                  <CheckCircle2 className="w-3 h-3 mr-1 text-status-up" />
                  Mark Active
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => postponeMutation.mutate({ portId: p.id, currentTarget: p.targetDate })}
                  isLoading={postponeMutation.isPending}
                  className="text-[11px] py-1 h-7"
                  title="Postpone 7 days"
                >
                  <Clock className="w-3 h-3 mr-1" />
                  +7d
                </Button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
