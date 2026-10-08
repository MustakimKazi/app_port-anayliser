import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  Server,
  CheckCircle2,
  AlertOctagon,
  Clock,
  AlertTriangle,
  Globe,
  Network,
  ShieldAlert,
  ArrowRight,
  Activity
} from 'lucide-react';
import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Tooltip,
  BarChart,
  Bar,
  XAxis,
  YAxis
} from 'recharts';
import { apiRequest } from '../../lib/api';
import { Card, CardHeader, CardTitle } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { StatusBadge, PriorityBadge } from '../../components/ui/Badge';
import { OverviewData } from '../../types';

export function DashboardPage() {
  const navigate = useNavigate();

  const { data, isLoading, isError, refetch } = useQuery<OverviewData>({
    queryKey: ['overview'],
    queryFn: () => apiRequest('/overview'),
    refetchInterval: 15000
  });

  // A failed overview request used to leave the page in the loading skeleton
  // forever (because of `!data`); show a real error with a retry action.
  if (isError) {
    return (
      <div className="max-w-lg border border-status-down/30 bg-status-down/10 rounded-xl p-6 space-y-3">
        <h2 className="font-semibold text-text">Dashboard failed to load</h2>
        <p className="text-xs text-text-muted">
          The overview API returned an error. Check that the API is reachable and
          that you are signed in, then retry.
        </p>
        <Button variant="secondary" size="sm" className="text-xs" onClick={() => refetch()}>
          Retry
        </Button>
      </div>
    );
  }

  if (isLoading || !data) {
    return (
      <div className="space-y-6 animate-pulse">
        <div className="h-8 bg-surface-2 rounded w-64" />
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="h-28 bg-surface-2 rounded-xl" />
          ))}
        </div>
      </div>
    );
  }

  const { kpis, charts, attention, recentEvents } = data;

  // Chart colors from tokens
  const DONUT_COLORS = [
    'var(--chart-1)',
    'var(--chart-2)',
    'var(--chart-3)',
    'var(--chart-4)',
    'var(--chart-5)',
    'var(--chart-6)',
    'var(--chart-7)',
    'var(--chart-8)'
  ];
  const ACTION_COLORS: Record<string, string> = {
    Proxy: 'var(--action-proxy)',
    Static: 'var(--action-static)',
    Redirect: 'var(--action-redirect)',
    Return: 'var(--action-return)',
    Status: 'var(--action-status)'
  };

  return (
    <div className="space-y-6">
      {/* Page Title & Breadcrumb */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
            <span>Server Overview</span>
            <span className="text-xs font-mono font-normal px-2.5 py-0.5 rounded-full bg-surface-2 text-primary border border-border">
              leadowserver
            </span>
          </h1>
          <p className="text-xs text-text-muted mt-1">
            Real-time port listening states, proxy forwarding topology, and configuration health.
          </p>
        </div>
        <Button variant="primary" size="sm" onClick={() => navigate('/ports')}>
          <span>View All Ports</span>
          <ArrowRight className="w-3.5 h-3.5" />
        </Button>
      </div>

      {/* KPI Cards Row 1 */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
        {/* Total Ports */}
        <div
          onClick={() => navigate('/ports')}
          className="p-4 rounded-xl border border-border bg-surface hover:border-border-strong hover:bg-surface-2 cursor-pointer transition-all group"
        >
          <div className="flex items-center justify-between text-text-muted">
            <span className="text-xs font-medium uppercase tracking-wider">Total Ports</span>
            <Server className="w-4 h-4 text-primary group-hover:scale-110 transition-transform" />
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="text-2xl font-bold font-mono-numbers text-text">{kpis.totalPorts}</span>
            <span className="text-[11px] text-text-muted">configured</span>
          </div>
        </div>

        {/* Listening / UP */}
        <div
          onClick={() => navigate('/ports?status=up')}
          className="p-4 rounded-xl border border-status-up/30 bg-surface hover:border-status-up/60 hover:bg-surface-2 cursor-pointer transition-all group"
        >
          <div className="flex items-center justify-between text-text-muted">
            <span className="text-xs font-medium uppercase tracking-wider text-status-up">Listening / UP</span>
            <CheckCircle2 className="w-4 h-4 text-status-up group-hover:scale-110 transition-transform" />
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="text-2xl font-bold font-mono-numbers text-status-up">{kpis.upPorts}</span>
            <span className="text-[11px] text-text-muted">sockets active</span>
          </div>
        </div>

        {/* DOWN */}
        <div
          onClick={() => navigate('/ports?status=down')}
          className="p-4 rounded-xl border border-status-down/30 bg-surface hover:border-status-down/60 hover:bg-surface-2 cursor-pointer transition-all group"
        >
          <div className="flex items-center justify-between text-text-muted">
            <span className="text-xs font-medium uppercase tracking-wider text-status-down">Down / Closed</span>
            <AlertOctagon className="w-4 h-4 text-status-down group-hover:scale-110 transition-transform" />
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="text-2xl font-bold font-mono-numbers text-status-down">{kpis.downPorts}</span>
            <span className="text-[11px] text-text-muted">unreachable</span>
          </div>
        </div>

        {/* Slow / Unknown */}
        <div
          onClick={() => navigate('/ports?status=slow')}
          className="p-4 rounded-xl border border-status-slow/30 bg-surface hover:border-status-slow/60 hover:bg-surface-2 cursor-pointer transition-all group"
        >
          <div className="flex items-center justify-between text-text-muted">
            <span className="text-xs font-medium uppercase tracking-wider text-status-slow">Slow (&gt;1.5s)</span>
            <Clock className="w-4 h-4 text-status-slow group-hover:scale-110 transition-transform" />
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="text-2xl font-bold font-mono-numbers text-status-slow">{kpis.slowPorts}</span>
            <span className="text-[11px] text-text-muted">high latency</span>
          </div>
        </div>

        {/* Open Issues */}
        <div
          onClick={() => navigate('/issues')}
          className="p-4 rounded-xl border border-border bg-surface hover:border-border-strong hover:bg-surface-2 cursor-pointer transition-all group"
        >
          <div className="flex items-center justify-between text-text-muted">
            <span className="text-xs font-medium uppercase tracking-wider">Open Issues</span>
            <AlertTriangle className="w-4 h-4 text-priority-high group-hover:scale-110 transition-transform" />
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="text-2xl font-bold font-mono-numbers text-text">{kpis.openIssues.total}</span>
            <span className="text-[11px] text-priority-high font-semibold">{kpis.openIssues.high} High</span>
          </div>
        </div>
      </div>

      {/* KPI Cards Row 2 (Domains, Backends, Certs) */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div
          onClick={() => navigate('/routes')}
          className="p-4 rounded-xl border border-border bg-surface hover:border-border-strong hover:bg-surface-2 cursor-pointer transition-all flex items-center justify-between"
        >
          <div>
            <div className="text-xs text-text-muted font-medium">Documented Domains</div>
            <div className="text-2xl font-bold font-mono-numbers text-text mt-1">{kpis.totalDomains}</div>
            <div className="text-[11px] text-primary mt-0.5">Across 106 routes</div>
          </div>
          <div className="p-3 rounded-lg bg-primary/10 text-primary">
            <Globe className="w-6 h-6" />
          </div>
        </div>

        <div
          onClick={() => navigate('/backends')}
          className="p-4 rounded-xl border border-border bg-surface hover:border-border-strong hover:bg-surface-2 cursor-pointer transition-all flex items-center justify-between"
        >
          <div>
            <div className="text-xs text-text-muted font-medium">Upstream Backends</div>
            <div className="text-2xl font-bold font-mono-numbers text-text mt-1">{kpis.totalBackends}</div>
            <div className="text-[11px] text-accent mt-0.5">5 Server clusters</div>
          </div>
          <div className="p-3 rounded-lg bg-accent/10 text-accent">
            <Network className="w-6 h-6" />
          </div>
        </div>

        <div
          onClick={() => navigate('/certificates')}
          className="p-4 rounded-xl border border-border bg-surface hover:border-border-strong hover:bg-surface-2 cursor-pointer transition-all flex items-center justify-between"
        >
          <div>
            <div className="text-xs text-text-muted font-medium">Certs Expiring Soon</div>
            <div className="text-2xl font-bold font-mono-numbers text-text mt-1">{kpis.certsExpiringSoon}</div>
            <div className="text-[11px] text-status-slow mt-0.5">&lt; 30 days remaining</div>
          </div>
          <div className="p-3 rounded-lg bg-status-slow/10 text-status-slow">
            <ShieldAlert className="w-6 h-6" />
          </div>
        </div>
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Layer / Protocol Donut */}
        <Card>
          <CardHeader>
            <CardTitle>Ports by Layer & Protocol</CardTitle>
            <span className="text-xs text-text-muted">HTTP vs Stream TCP</span>
          </CardHeader>
          <div className="h-64 flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={charts.layerDonut}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={85}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {charts.layerDonut.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={DONUT_COLORS[index % DONUT_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border-strong)', borderRadius: '8px', color: 'var(--text)' }}
                  itemStyle={{ color: 'var(--text)' }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex flex-wrap justify-center gap-4 mt-2">
            {charts.layerDonut.map((item, idx) => (
              <div key={item.name} className="flex items-center gap-2 text-xs">
                <span
                  className="w-2.5 h-2.5 rounded-full"
                  style={{ backgroundColor: DONUT_COLORS[idx % DONUT_COLORS.length] }}
                />
                <span className="text-text">{item.name}</span>
                <span className="font-mono text-text-muted font-bold">({item.value})</span>
              </div>
            ))}
          </div>
        </Card>

        {/* Routes by Action Bar Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Routes by Action</CardTitle>
            <span className="text-xs text-text-muted">Proxy, Static, Redirect, etc.</span>
          </CardHeader>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={charts.actionChart} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <XAxis dataKey="name" stroke="var(--border)" tick={{ fill: 'var(--text-muted)' }} fontSize={11} tickLine={false} />
                <YAxis stroke="var(--border)" tick={{ fill: 'var(--text-muted)' }} fontSize={11} tickLine={false} />
                <Tooltip
                  contentStyle={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border-strong)', borderRadius: '8px', color: 'var(--text)' }}
                  itemStyle={{ color: 'var(--text)' }}
                />
                <Bar dataKey="value" radius={[6, 6, 0, 0]}>
                  {charts.actionChart.map((entry) => (
                    <Cell key={`action-${entry.name}`} fill={ACTION_COLORS[entry.name] || 'var(--primary)'} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>
      </div>

      {/* Top 10 Ports & Recent Status Trend */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top 10 Ports by Domains */}
        <Card>
          <CardHeader>
            <CardTitle>Top Ports by Number of Domains</CardTitle>
            <span className="text-xs text-text-muted">Highest multiplexing</span>
          </CardHeader>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart
                layout="vertical"
                data={charts.topPorts}
                margin={{ top: 5, right: 20, left: 30, bottom: 5 }}
              >
                <XAxis type="number" stroke="var(--border)" tick={{ fill: 'var(--text-muted)' }} fontSize={11} tickLine={false} />
                <YAxis dataKey="port" type="category" stroke="var(--border)" tick={{ fill: 'var(--text-muted)' }} fontSize={11} tickLine={false} />
                <Tooltip
                  contentStyle={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border-strong)', borderRadius: '8px', color: 'var(--text)' }}
                  itemStyle={{ color: 'var(--text)' }}
                />
                <Bar dataKey="count" fill="var(--chart-1)" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>

        {/* Needs Attention Panel */}
        <Card>
          <CardHeader>
            <CardTitle className="text-priority-high flex items-center gap-2">
              <AlertTriangle className="w-4 h-4" />
              <span>Needs Attention</span>
            </CardTitle>
            <Button variant="ghost" size="sm" onClick={() => navigate('/issues')} className="text-xs">
              View All
            </Button>
          </CardHeader>
          <div className="space-y-3 overflow-y-auto max-h-64 pr-1">
            {attention.highIssues.length === 0 && attention.downPorts.length === 0 ? (
              <div className="text-center py-8 text-text-muted text-xs">
                No high priority issues or unexpected downtime.
              </div>
            ) : (
              <>
                {attention.highIssues.map((issue) => (
                  <div
                    key={issue.id}
                    onClick={() => navigate('/issues')}
                    className="p-2.5 rounded-lg border border-priority-high/30 bg-priority-high/10 hover:bg-priority-high/20 transition-colors cursor-pointer flex items-start justify-between gap-3"
                  >
                    <div>
                      <div className="text-xs font-semibold text-priority-high">{issue.title}</div>
                      <div className="text-[11px] text-text-muted line-clamp-1 mt-0.5">{issue.observed}</div>
                    </div>
                    <PriorityBadge priority={issue.priority} />
                  </div>
                ))}

                {attention.downPorts.map((port) => (
                  <div
                    key={port.id}
                    onClick={() => navigate(`/ports?portMin=${port.port}&portMax=${port.port}`)}
                    className="p-2.5 rounded-lg border border-border bg-surface-2/60 hover:bg-surface-2 transition-colors cursor-pointer flex items-center justify-between gap-3"
                  >
                    <div className="flex items-center gap-2 font-mono text-xs">
                      <span className="font-bold text-text">Port {port.port}</span>
                      <span className="text-text-muted truncate max-w-xs">{port.purpose}</span>
                    </div>
                    <StatusBadge status="down" size="sm" />
                  </div>
                ))}
              </>
            )}
          </div>
        </Card>
      </div>

      {/* Live Activity Feed */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity className="w-4 h-4 text-primary" />
            <span>Recent Status Events</span>
          </CardTitle>
          <span className="text-xs text-text-muted">Real-time status transitions</span>
        </CardHeader>
        <div className="divide-y divide-border">
          {recentEvents.length === 0 ? (
            <div className="py-6 text-center text-xs text-text-muted">
              No recent status events recorded yet. The system is scanning every 30 seconds.
            </div>
          ) : (
            recentEvents.map((evt) => (
              <div key={evt.id} className="py-2.5 flex items-center justify-between text-xs">
                <div className="flex items-center gap-3">
                  <span className="font-mono font-medium text-text">{evt.targetName}</span>
                  <div className="flex items-center gap-1.5 font-mono-numbers">
                    <span className="text-text-muted">{evt.fromStatus.toUpperCase()}</span>
                    <span className="text-text-muted">→</span>
                    <span
                      className={`font-semibold ${
                        evt.toStatus === 'up'
                          ? 'text-status-up'
                          : evt.toStatus === 'down'
                          ? 'text-status-down'
                          : 'text-status-slow'
                      }`}
                    >
                      {evt.toStatus.toUpperCase()}
                    </span>
                  </div>
                </div>
                <div className="text-text-muted text-[11px] font-mono">
                  {new Date(evt.at).toLocaleTimeString()}
                </div>
              </div>
            ))
          )}
        </div>
      </Card>
    </div>
  );
}
                  {new Date(evt.at).toLocaleTimeString()}
                </div>
              </div>
            ))
          )}
        </div>
      </Card>
    </div>
  );
}
