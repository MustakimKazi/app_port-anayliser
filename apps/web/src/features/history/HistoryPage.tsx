import React from "react";
import { useQuery } from "@tanstack/react-query";
import {
  History as HistoryIcon,
  Clock,
  AlertTriangle,
  CheckCircle2,
  Activity,
} from "lucide-react";
import { apiRequest } from "../../lib/api";
import { Card, CardHeader, CardTitle } from "../../components/ui/Card";
import { StatusBadge } from "../../components/ui/Badge";

export function HistoryPage() {
  const { data } = useQuery<{
    uptime: { last24h: number; last7d: number; last30d: number };
    downtimeIncidents: Array<{
      targetName: string;
      targetType: string;
      startedAt: string;
      resolvedAt: string | null;
      durationMinutes: number | null;
    }>;
    timeline: Array<{
      id: string;
      targetName: string;
      fromStatus: string;
      toStatus: string;
      at: string;
    }>;
  }>({
    queryKey: ["history"],
    queryFn: () => apiRequest("/history"),
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
          <span>History & Uptime Timeline</span>
        </h1>
        <p className="text-xs text-text-muted mt-1">
          Historical service availability calculations, downtime incident
          duration, and state transition logs.
        </p>
      </div>

      {/* Uptime % KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="p-4 rounded-xl border border-border bg-surface">
          <span className="text-xs text-text-muted font-medium">
            Last 24 Hours Uptime
          </span>
          <div className="text-2xl font-bold font-mono text-status-up mt-1">
            {data?.uptime.last24h ?? 100}%
          </div>
          <span className="text-[11px] text-text-muted">
            Continuous check checks
          </span>
        </div>

        <div className="p-4 rounded-xl border border-border bg-surface">
          <span className="text-xs text-text-muted font-medium">
            Last 7 Days Uptime
          </span>
          <div className="text-2xl font-bold font-mono text-status-up mt-1">
            {data?.uptime.last7d ?? 99.9}%
          </div>
          <span className="text-[11px] text-text-muted">
            Weekly rolling average
          </span>
        </div>

        <div className="p-4 rounded-xl border border-border bg-surface">
          <span className="text-xs text-text-muted font-medium">
            Last 30 Days Uptime
          </span>
          <div className="text-2xl font-bold font-mono text-status-up mt-1">
            {data?.uptime.last30d ?? 99.8}%
          </div>
          <span className="text-[11px] text-text-muted">
            Monthly service SLA
          </span>
        </div>
      </div>

      {/* Downtime Incidents Table */}
      <Card>
        <CardHeader>
          <CardTitle className="text-status-down flex items-center gap-2">
            <AlertTriangle className="w-4 h-4" />
            <span>Downtime Incident Log</span>
          </CardTitle>
          <span className="text-xs text-text-muted">
            Recorded outage durations
          </span>
        </CardHeader>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-text">
            <thead className="bg-surface-2 text-[11px] uppercase text-text-muted border-b border-border">
              <tr>
                <th className="py-2.5 px-4">Target</th>
                <th className="py-2.5 px-4">Type</th>
                <th className="py-2.5 px-4">Started At</th>
                <th className="py-2.5 px-4">Recovered At</th>
                <th className="py-2.5 px-4">Duration</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border/60 font-sans">
              {!data?.downtimeIncidents ||
              data.downtimeIncidents.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-8 text-center text-text-muted">
                    No downtime incidents recorded.
                  </td>
                </tr>
              ) : (
                data.downtimeIncidents.map((inc, i) => (
                  <tr
                    key={i}
                    className="hover:bg-surface-2/60 transition-colors"
                  >
                    <td className="py-2.5 px-4 font-mono font-bold text-text">
                      {inc.targetName}
                    </td>
                    <td className="py-2.5 px-4 uppercase text-[10px] text-text-muted">
                      {inc.targetType}
                    </td>
                    <td className="py-2.5 px-4 font-mono text-text-muted">
                      {new Date(inc.startedAt).toLocaleString()}
                    </td>
                    <td className="py-2.5 px-4 font-mono text-text-muted">
                      {inc.resolvedAt
                        ? new Date(inc.resolvedAt).toLocaleString()
                        : "Ongoing Outage"}
                    </td>
                    <td className="py-2.5 px-4 font-mono font-semibold text-status-down">
                      {inc.durationMinutes !== null
                        ? `${inc.durationMinutes} min`
                        : "Active"}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Global Status Events Stream */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity className="w-4 h-4 text-primary" />
            <span>Complete State Change Stream</span>
          </CardTitle>
          <span className="text-xs text-text-muted">
            Last 100 transition records
          </span>
        </CardHeader>
        <div className="divide-y divide-border/60 max-h-96 overflow-y-auto">
          {!data?.timeline || data.timeline.length === 0 ? (
            <div className="py-8 text-center text-text-muted text-xs">
              No status events yet.
            </div>
          ) : (
            data.timeline.map((evt) => (
              <div
                key={evt.id}
                className="py-2.5 px-4 flex items-center justify-between text-xs"
              >
                <div className="flex items-center gap-3">
                  <span className="font-mono font-bold text-text">
                    {evt.targetName}
                  </span>
                  <div className="flex items-center gap-1.5 font-mono text-xs">
                    <span className="text-text-muted uppercase">
                      {evt.fromStatus}
                    </span>
                    <span className="text-text-muted">→</span>
                    <span
                      className={`font-semibold uppercase ${
                        evt.toStatus === "up"
                          ? "text-status-up"
                          : evt.toStatus === "down"
                            ? "text-status-down"
                            : "text-status-slow"
                      }`}
                    >
                      {evt.toStatus}
                    </span>
                  </div>
                </div>
                <span className="font-mono text-[11px] text-text-muted">
                  {new Date(evt.at).toLocaleString()}
                </span>
              </div>
            ))
          )}
        </div>
      </Card>
    </div>
  );
}
