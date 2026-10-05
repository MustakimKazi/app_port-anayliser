import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Settings,
  Bell,
  Sliders,
  Plus,
  Send,
  Download,
  Upload,
  Shield,
  Trash2,
  CheckCircle2,
  FileSpreadsheet
} from 'lucide-react';
import { apiRequest } from '../../lib/api';
import { Card, CardHeader, CardTitle } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Modal } from '../../components/ui/Modal';
import { CustomField } from '../../types';

export function SettingsPage() {
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<'scanner' | 'alerts' | 'custom-fields' | 'import-export' | 'audit'>('scanner');

  // Scanner settings state
  const { data: settings } = useQuery<any>({
    queryKey: ['settings'],
    queryFn: () => apiRequest('/settings')
  });

  const [scanInterval, setScanInterval] = useState(30);
  const [tcpTimeout, setTcpTimeout] = useState(3000);
  const [slowThreshold, setSlowThreshold] = useState(1500);
  const [retentionDays, setRetentionDays] = useState(90);

  React.useEffect(() => {
    if (settings) {
      setScanInterval(settings.scanIntervalSec || 30);
      setTcpTimeout(settings.tcpTimeoutMs || 3000);
      setSlowThreshold(settings.slowThresholdMs || 1500);
      setRetentionDays(settings.retentionDays || 90);
    }
  }, [settings]);

  const saveSettingsMutation = useMutation({
    mutationFn: (data: any) =>
      apiRequest('/settings', {
        method: 'PATCH',
        body: JSON.stringify(data)
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings'] });
      alert('Scanner settings updated successfully.');
    }
  });

  // Alert Rules & Logs
  const { data: alertRules = [] } = useQuery<any[]>({
    queryKey: ['alert-rules'],
    queryFn: () => apiRequest('/alerts/rules')
  });

  const [testChannel, setTestChannel] = useState('webhook');
  const [testResult, setTestResult] = useState<string | null>(null);

  const testAlertMutation = useMutation({
    mutationFn: () =>
      apiRequest('/alerts/test', {
        method: 'POST',
        body: JSON.stringify({ channel: testChannel })
      }),
    onSuccess: (res) => {
      setTestResult(res.message);
      setTimeout(() => setTestResult(null), 4000);
    }
  });

  // Custom Fields
  const { data: customFields = [] } = useQuery<CustomField[]>({
    queryKey: ['custom-fields'],
    queryFn: () => apiRequest('/custom-fields')
  });

  const [isFieldModalOpen, setIsFieldModalOpen] = useState(false);
  const [fieldName, setFieldName] = useState('');
  const [fieldKey, setFieldKey] = useState('');
  const [fieldEntity, setFieldEntity] = useState<'port' | 'route' | 'backend' | 'server'>('port');
  const [fieldType, setFieldType] = useState<any>('text');

  const addFieldMutation = useMutation({
    mutationFn: (data: any) =>
      apiRequest('/custom-fields', {
        method: 'POST',
        body: JSON.stringify(data)
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['custom-fields'] });
      setIsFieldModalOpen(false);
      setFieldName('');
      setFieldKey('');
    }
  });

  const deleteFieldMutation = useMutation({
    mutationFn: (id: string) =>
      apiRequest(`/custom-fields/${id}`, { method: 'DELETE' }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['custom-fields'] })
  });

  // Import / Export
  const [uploadFile, setUploadFile] = useState<File | null>(null);
  const [importStatus, setImportStatus] = useState<string | null>(null);

  const handleUpload = async () => {
    if (!uploadFile) return;
    const formData = new FormData();
    formData.append('file', uploadFile);

    try {
      setImportStatus('Uploading and parsing workbook...');
      const res = await apiRequest('/import', {
        method: 'POST',
        body: formData
      });
      setImportStatus(`Success! Imported ${res.result.routesCount} routes, ${res.result.portsCount} ports, and ${res.result.issuesCount} issues.`);
      queryClient.invalidateQueries();
    } catch (err: any) {
      setImportStatus(`Import Error: ${err.message}`);
    }
  };

  // Audit Logs
  const { data: auditLogs = [] } = useQuery<any[]>({
    queryKey: ['audit-log'],
    queryFn: () => apiRequest('/audit-log'),
    enabled: activeTab === 'audit'
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text flex items-center gap-2.5">
            <span>Settings & Administration</span>
          </h1>
          <p className="text-xs text-text-muted mt-1">
            Configure scan frequencies, notification rules, custom schema attributes, and database backups.
          </p>
        </div>

        {/* Tab Switcher */}
        <div className="flex flex-wrap items-center gap-1.5 p-1 rounded-lg bg-surface border border-border text-xs">
          <button
            onClick={() => setActiveTab('scanner')}
            className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
              activeTab === 'scanner' ? 'bg-primary text-on-primary' : 'text-text-muted hover:text-text'
            }`}
          >
            Scanner Config
          </button>
          <button
            onClick={() => setActiveTab('alerts')}
            className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
              activeTab === 'alerts' ? 'bg-primary text-on-primary' : 'text-text-muted hover:text-text'
            }`}
          >
            Alerts & Channels
          </button>
          <button
            onClick={() => setActiveTab('custom-fields')}
            className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
              activeTab === 'custom-fields' ? 'bg-primary text-on-primary' : 'text-text-muted hover:text-text'
            }`}
          >
            Custom Fields
          </button>
          <button
            onClick={() => setActiveTab('import-export')}
            className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
              activeTab === 'import-export' ? 'bg-primary text-on-primary' : 'text-text-muted hover:text-text'
            }`}
          >
            Import / Export / Backup
          </button>
          <button
            onClick={() => setActiveTab('audit')}
            className={`px-3 py-1.5 rounded-md font-medium transition-colors ${
              activeTab === 'audit' ? 'bg-primary text-on-primary' : 'text-text-muted hover:text-text'
            }`}
          >
            Audit Trail
          </button>
        </div>
      </div>

      {/* TAB 1: SCANNER CONFIG */}
      {activeTab === 'scanner' && (
        <Card className="p-6 space-y-6 max-w-3xl">
          <div className="pb-3 border-b border-border">
            <h3 className="text-base font-semibold text-text flex items-center gap-2">
              <Sliders className="w-5 h-5 text-primary" />
              <span>Background Scanner Engine Parameters</span>
            </h3>
            <p className="text-xs text-text-muted mt-0.5">
              Controls probe rates, socket timeouts, latency classification, and time-series retention.
            </p>
          </div>

          <div className="space-y-4 text-xs">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-text font-semibold mb-1">Scan Interval (Seconds)</label>
                <input
                  type="number"
                  value={scanInterval}
                  onChange={(e) => setScanInterval(parseInt(e.target.value))}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-sm text-text focus:outline-none focus:border-primary"
                />
                <span className="text-[11px] text-text-muted mt-1 block">Default: 30 seconds</span>
              </div>

              <div>
                <label className="block text-text font-semibold mb-1">TCP Connect Timeout (ms)</label>
                <input
                  type="number"
                  value={tcpTimeout}
                  onChange={(e) => setTcpTimeout(parseInt(e.target.value))}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-sm text-text focus:outline-none focus:border-primary"
                />
                <span className="text-[11px] text-text-muted mt-1 block">Default: 3000 ms</span>
              </div>

              <div>
                <label className="block text-text font-semibold mb-1">Slow Response Threshold (ms)</label>
                <input
                  type="number"
                  value={slowThreshold}
                  onChange={(e) => setSlowThreshold(parseInt(e.target.value))}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-sm text-text focus:outline-none focus:border-primary"
                />
                <span className="text-[11px] text-text-muted mt-1 block">Marks port as SLOW above this limit</span>
              </div>

              <div>
                <label className="block text-text font-semibold mb-1">Retention Period (Days)</label>
                <input
                  type="number"
                  value={retentionDays}
                  onChange={(e) => setRetentionDays(parseInt(e.target.value))}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-sm text-text focus:outline-none focus:border-primary"
                />
                <span className="text-[11px] text-text-muted mt-1 block">Auto-purges checks older than this</span>
              </div>
            </div>

            <div className="pt-4 border-t border-border flex justify-end">
              <Button
                variant="primary"
                onClick={() =>
                  saveSettingsMutation.mutate({
                    scanIntervalSec: scanInterval,
                    tcpTimeoutMs: tcpTimeout,
                    slowThresholdMs: slowThreshold,
                    retentionDays: retentionDays
                  })
                }
              >
                Save Scanner Settings
              </Button>
            </div>
          </div>
        </Card>
      )}

      {/* TAB 2: ALERTS & NOTIFICATIONS */}
      {activeTab === 'alerts' && (
        <div className="space-y-6 max-w-4xl">
          {/* Send Test Alert Card */}
          <Card className="p-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 bg-surface-2 border-border">
            <div>
              <div className="text-sm font-bold text-text flex items-center gap-2">
                <Bell className="w-4 h-4 text-primary" />
                <span>Simulate & Test Alert Notification</span>
              </div>
              <p className="text-xs text-text-muted mt-0.5">
                Send a sample dispatch event across configured channels.
              </p>
            </div>

            <div className="flex items-center gap-2">
              <select
                value={testChannel}
                onChange={(e) => setTestChannel(e.target.value)}
                className="px-2.5 py-1.5 rounded-lg bg-surface border border-border-strong text-xs text-text focus:outline-none focus:border-primary"
              >
                <option value="webhook">Generic Webhook</option>
                <option value="slack">Slack / Discord</option>
                <option value="telegram">Telegram Bot</option>
                <option value="smtp">Email (SMTP)</option>
              </select>
              <Button
                variant="primary"
                size="sm"
                onClick={() => testAlertMutation.mutate()}
                isLoading={testAlertMutation.isPending}
              >
                <Send className="w-3.5 h-3.5" />
                <span>Send Test</span>
              </Button>
            </div>
          </Card>

          {testResult && (
            <div className="p-3 rounded-lg bg-status-up/15 border border-status-up/30 text-xs text-status-up flex items-center gap-2">
              <CheckCircle2 className="w-4 h-4 text-status-up" />
              <span>{testResult}</span>
            </div>
          )}

          {/* Active Rules List */}
          <Card>
            <CardHeader>
              <CardTitle>Configured Alert Rules</CardTitle>
            </CardHeader>
            <div className="divide-y divide-border text-xs">
              {alertRules.map((rule) => (
                <div key={rule.id} className="py-3 px-2 flex items-center justify-between">
                  <div>
                    <div className="font-semibold text-text">{rule.name}</div>
                    <div className="text-text-muted font-mono text-[11px] mt-0.5">
                      Event: {rule.eventType} • Threshold: {rule.threshold ?? 'instant'}
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="font-mono text-[11px] px-2 py-0.5 rounded bg-surface-2 border border-border text-text">
                      {rule.channels.join(', ')}
                    </span>
                    <span
                      className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                        rule.isEnabled
                          ? 'bg-status-up/15 text-status-up border border-status-up/30'
                          : 'bg-surface-2 text-text-muted border border-border'
                      }`}
                    >
                      {rule.isEnabled ? 'ACTIVE' : 'DISABLED'}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </Card>
        </div>
      )}

      {/* TAB 3: CUSTOM FIELDS MANAGER */}
      {activeTab === 'custom-fields' && (
        <div className="space-y-4 max-w-4xl">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-base font-semibold text-text">Dynamic Custom Fields</h3>
              <p className="text-xs text-text-muted">
                Add metadata columns to Ports, Routes, Backends, or Servers with zero code modifications.
              </p>
            </div>
            <Button variant="primary" size="sm" onClick={() => setIsFieldModalOpen(true)}>
              <Plus className="w-3.5 h-3.5" />
              <span>Add Custom Field</span>
            </Button>
          </div>

          <Card className="overflow-hidden">
            <table className="w-full text-left text-xs text-text">
              <thead className="bg-surface-2 text-[11px] uppercase text-text-muted border-b border-border">
                <tr>
                  <th className="py-2.5 px-4">Entity</th>
                  <th className="py-2.5 px-4">Field Name</th>
                  <th className="py-2.5 px-4">Key</th>
                  <th className="py-2.5 px-4">Type</th>
                  <th className="py-2.5 px-4 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border/60 font-sans">
                {customFields.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="py-8 text-center text-text-muted">
                      No custom fields added yet. Click &quot;Add Custom Field&quot; to create one.
                    </td>
                  </tr>
                ) : (
                  customFields.map((f) => (
                    <tr key={f.id} className="hover:bg-surface-2/60 transition-colors">
                      <td className="py-2.5 px-4 font-mono uppercase text-primary text-[11px]">
                        {f.entityType}
                      </td>
                      <td className="py-2.5 px-4 font-semibold text-text">{f.name}</td>
                      <td className="py-2.5 px-4 font-mono text-text-muted">{f.key}</td>
                      <td className="py-2.5 px-4 uppercase text-[10px] text-text-muted">{f.fieldType}</td>
                      <td className="py-2.5 px-4 text-right">
                        <button
                          onClick={() => deleteFieldMutation.mutate(f.id)}
                          className="p-1 rounded text-text-muted hover:text-status-down transition-colors"
                          title="Delete field"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </Card>

          {/* Add Field Modal */}
          <Modal
            isOpen={isFieldModalOpen}
            onClose={() => setIsFieldModalOpen(false)}
            title="Create Custom Field"
          >
            <div className="space-y-4 text-xs">
              <div>
                <label className="block text-text-muted font-semibold mb-1">Target Entity</label>
                <select
                  value={fieldEntity}
                  onChange={(e) => setFieldEntity(e.target.value as any)}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
                >
                  <option value="port">Port</option>
                  <option value="route">Route</option>
                  <option value="backend">Backend</option>
                  <option value="server">Server</option>
                </select>
              </div>

              <div>
                <label className="block text-text-muted font-semibold mb-1">Field Label / Name</label>
                <input
                  type="text"
                  placeholder="e.g. Compliance Tier"
                  value={fieldName}
                  onChange={(e) => {
                    setFieldName(e.target.value);
                    setFieldKey(e.target.value.toLowerCase().replace(/[^a-z0-9]/g, '_'));
                  }}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
                />
              </div>

              <div>
                <label className="block text-text-muted font-semibold mb-1">Field Key (JSON property)</label>
                <input
                  type="text"
                  value={fieldKey}
                  onChange={(e) => setFieldKey(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text font-mono focus:outline-none focus:border-primary"
                />
              </div>

              <div>
                <label className="block text-text-muted font-semibold mb-1">Field Data Type</label>
                <select
                  value={fieldType}
                  onChange={(e) => setFieldType(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-text focus:outline-none focus:border-primary"
                >
                  <option value="text">Text</option>
                  <option value="number">Number</option>
                  <option value="select">Dropdown Select</option>
                  <option value="boolean">Boolean (Yes/No)</option>
                  <option value="date">Date</option>
                  <option value="url">URL Link</option>
                </select>
              </div>

              <div className="pt-3 flex justify-end gap-2">
                <Button variant="ghost" size="sm" onClick={() => setIsFieldModalOpen(false)}>
                  Cancel
                </Button>
                <Button
                  variant="primary"
                  size="sm"
                  onClick={() =>
                    addFieldMutation.mutate({
                      entityType: fieldEntity,
                      name: fieldName,
                      key: fieldKey,
                      fieldType: fieldType
                    })
                  }
                >
                  Create Field
                </Button>
              </div>
            </div>
          </Modal>
        </div>
      )}

      {/* TAB 4: IMPORT / EXPORT / BACKUP */}
      {activeTab === 'import-export' && (
        <div className="space-y-6 max-w-4xl">
          {/* Upload Workbook Card */}
          <Card className="p-6 space-y-4">
            <h3 className="text-base font-bold text-text flex items-center gap-2">
              <Upload className="w-5 h-5 text-primary" />
              <span>Import Documentation Spreadsheet (.xlsx or .csv)</span>
            </h3>
            <p className="text-xs text-text-muted">
              Upload a generated <code className="font-mono text-text bg-surface-2 px-1 rounded">nginx_documentation.xlsx</code> workbook to update ports, routes, backends, and config files with idempotent upserts.
            </p>

            <div className="flex flex-col sm:flex-row items-start sm:items-center gap-3 pt-2">
              <input
                type="file"
                accept=".xlsx,.csv"
                onChange={(e) => setUploadFile(e.target.files?.[0] || null)}
                className="text-xs text-text file:mr-3 file:py-2 file:px-3 file:rounded-lg file:border-0 file:bg-surface-2 file:text-text hover:file:bg-border"
              />
              <Button
                variant="primary"
                size="sm"
                onClick={handleUpload}
                disabled={!uploadFile}
              >
                Upload & Process
              </Button>
            </div>

            {importStatus && (
              <div className="p-3 rounded-lg bg-surface-2 border border-border text-xs font-mono text-text">
                {importStatus}
              </div>
            )}
          </Card>

          {/* Download Backup */}
          <Card className="p-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div>
              <h3 className="text-base font-bold text-text flex items-center gap-2">
                <Download className="w-5 h-5 text-primary" />
                <span>Full System Database Backup</span>
              </h3>
              <p className="text-xs text-text-muted mt-0.5">
                Download a complete JSON snapshot containing all servers, ports, routes, backends, and custom field values.
              </p>
            </div>
            <a href="/api/backup" target="_blank" rel="noreferrer">
              <Button variant="primary" size="sm">
                <Download className="w-3.5 h-3.5" />
                <span>Download Backup (JSON)</span>
              </Button>
            </a>
          </Card>
        </div>
      )}

      {/* TAB 5: AUDIT LOG */}
      {activeTab === 'audit' && (
        <Card className="overflow-hidden max-w-5xl">
          <CardHeader>
            <CardTitle>System Audit Trail</CardTitle>
            <span className="text-xs text-text-muted">All entity creations, edits, and deletions</span>
          </CardHeader>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-text">
              <thead className="bg-surface-2 text-[11px] uppercase text-text-muted border-b border-border">
                <tr>
                  <th className="py-2.5 px-4">Timestamp</th>
                  <th className="py-2.5 px-4">User</th>
                  <th className="py-2.5 px-4">Action</th>
                  <th className="py-2.5 px-4">Entity</th>
                  <th className="py-2.5 px-4">Entity ID</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border/60 font-sans">
                {auditLogs.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="py-8 text-center text-text-muted">
                      No audit events recorded yet.
                    </td>
                  </tr>
                ) : (
                  auditLogs.map((log) => (
                    <tr key={log.id} className="hover:bg-surface-2/60 transition-colors">
                      <td className="py-2.5 px-4 font-mono text-text-muted">
                        {new Date(log.createdAt).toLocaleString()}
                      </td>
                      <td className="py-2.5 px-4 font-semibold text-text">{log.username}</td>
                      <td className="py-2.5 px-4 uppercase text-[11px] font-bold text-primary">
                        {log.action}
                      </td>
                      <td className="py-2.5 px-4 text-text">{log.entity}</td>
                      <td className="py-2.5 px-4 font-mono text-text-muted text-[11px]">
                        {log.entityId || '—'}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </Card>
      )}
    </div>
  );
}
