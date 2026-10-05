import React from 'react';
import { StatusType, ActionType, PriorityType } from '../../types';

interface StatusBadgeProps {
  status: StatusType | string;
  size?: 'sm' | 'md';
}

export function StatusBadge({ status, size = 'md' }: StatusBadgeProps) {
  const s = (status || 'unknown').toLowerCase();

  let badgeClass = 'badge-status-unknown';
  let dotBg = 'bg-status-unknown';
  let label = 'UNKNOWN';
  let isPulse = false;

  if (s === 'up') {
    badgeClass = 'badge-status-up';
    dotBg = 'bg-status-up';
    label = 'UP';
    isPulse = true;
  } else if (s === 'down') {
    badgeClass = 'badge-status-down';
    dotBg = 'bg-status-down';
    label = 'DOWN';
  } else if (s === 'slow') {
    badgeClass = 'badge-status-slow';
    dotBg = 'bg-status-slow';
    label = 'SLOW';
  } else if (s === 'info') {
    badgeClass = 'badge-status-info';
    dotBg = 'bg-status-info';
    label = 'INFO';
  }

  const px = size === 'sm' ? 'px-2 py-0.5 text-xs' : 'px-2.5 py-1 text-xs';

  return (
    <span className={`inline-flex items-center gap-1.5 font-medium rounded-full border ${badgeClass} ${px}`}>
      <span className={`h-1.5 w-1.5 rounded-full ${dotBg} ${isPulse ? 'animate-pulse' : ''}`} />
      <span className="font-mono-numbers">{label}</span>
    </span>
  );
}

interface ActionBadgeProps {
  action: ActionType | string;
}

export function ActionBadge({ action }: ActionBadgeProps) {
  const a = (action || '').toLowerCase();

  let badgeClass = 'badge-action-proxy';
  if (a === 'proxy') {
    badgeClass = 'badge-action-proxy';
  } else if (a === 'static') {
    badgeClass = 'badge-action-static';
  } else if (a === 'redirect') {
    badgeClass = 'badge-action-redirect';
  } else if (a === 'return') {
    badgeClass = 'badge-action-return';
  } else if (a === 'status') {
    badgeClass = 'badge-action-status';
  }

  return (
    <span className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-semibold uppercase tracking-wider border ${badgeClass}`}>
      {action}
    </span>
  );
}

interface PriorityBadgeProps {
  priority: PriorityType | string;
}

export function PriorityBadge({ priority }: PriorityBadgeProps) {
  const p = (priority || 'medium').toLowerCase();

  let badgeClass = 'badge-priority-medium';
  if (p === 'high') {
    badgeClass = 'badge-priority-high';
  } else if (p === 'medium') {
    badgeClass = 'badge-priority-medium';
  } else if (p === 'low') {
    badgeClass = 'badge-priority-low';
  } else if (p === 'info') {
    badgeClass = 'badge-priority-info';
  }

  return (
    <span className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium border ${badgeClass}`}>
      {priority}
    </span>
  );
}

export function UnresolvedBadge({ type }: { type: string }) {
  return (
    <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium border badge-unresolved">
      Unresolved ({type})
    </span>
  );
}
