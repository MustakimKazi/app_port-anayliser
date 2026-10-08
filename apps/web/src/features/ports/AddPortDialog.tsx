import React, { useState, useEffect } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  X,
  Check,
  AlertTriangle,
  Info,
  Server,
  Layers,
  Network,
  Link as LinkIcon,
  Sliders,
  CheckCircle2,
  Plus,
  ArrowRight,
  ArrowLeft,
  Upload,
} from "lucide-react";
import { apiRequest } from "../../lib/api";
import { Button } from "../../components/ui/Button";
import { Card } from "../../components/ui/Card";
import { LifecycleBadge } from "../../components/ui/Badge";
import {
  Server as ServerType,
  Backend as BackendType,
  FeaturePreset,
  FeatureItem,
} from "../../types";

interface AddPortDialogProps {
  isOpen: boolean;
  onClose: () => void;
  prefill?: {
    port?: number;
    processName?: string;
    bindAddress?: string;
    lifecycle?: string;
  };
}

export function AddPortDialog({
  isOpen,
  onClose,
  prefill,
}: AddPortDialogProps) {
  const queryClient = useQueryClient();

  const [mode, setMode] = useState<"single" | "range" | "paste">("single");
  const [step, setStep] = useState<number>(1);

  // Form State - Basics
  const [portNum, setPortNum] = useState<string>("");
  const [layer, setLayer] = useState<"http" | "stream">("http");
  const [protocol, setProtocol] = useState<"HTTP" | "HTTPS" | "TCP" | "UDP">(
    "HTTP",
  );
  const [purpose, setPurpose] = useState<string>("");
  const [serverId, setServerId] = useState<string>("");
  const [newServerName, setNewServerName] = useState<string>("");
  const [isAddingServerInline, setIsAddingServerInline] = useState(false);
  const [lifecycle, setLifecycle] = useState<
    "active" | "planned" | "reserved" | "maintenance" | "deprecated"
  >("active");
  const [lifecycleReason, setLifecycleReason] = useState<string>("");
  const [targetDate, setTargetDate] = useState<string>("");
  const [owner, setOwner] = useState<string>("");
  const [maintenanceFrom, setMaintenanceFrom] = useState<string>("");
  const [maintenanceTo, setMaintenanceTo] = useState<string>("");

  // Form State - Network
  const [expectedBind, setExpectedBind] = useState<string>("0.0.0.0");
  const [isPublic, setIsPublic] = useState<boolean>(true);
  const [processName, setProcessName] = useState<string>("");

  // Form State - Attach (optional initial route)
  const [attachRoute, setAttachRoute] = useState<boolean>(false);
  const [routeDomain, setRouteDomain] = useState<string>("");
  const [routePath, setRoutePath] = useState<string>("/");
  const [routeAction, setRouteAction] = useState<string>("Proxy");
  const [backendHost, setBackendHost] = useState<string>("127.0.0.1");
  const [backendPort, setBackendPort] = useState<string>("");
  const [selectedBackendId, setSelectedBackendId] = useState<string>("");

  // Form State - Features
  const [selectedPresetId, setSelectedPresetId] = useState<string>("");
  const [featuresConfig, setFeaturesConfig] = useState<
    Record<string, { enabled: boolean; config?: any }>
  >({});

  // Bulk State
  const [portRange, setPortRange] = useState<string>("3000-3010");
  const [pasteText, setPasteText] = useState<string>("");
  const [bulkPreview, setBulkPreview] = useState<any>(null);

  // Conflict validation state
  const [validationResult, setValidationResult] = useState<{
    valid: boolean;
    warnings: Array<{
      code: string;
      message: string;
      severity: "error" | "warning" | "info";
      existingPortId?: string;
      suggestedPreset?: string;
    }>;
  } | null>(null);
  const [isValidating, setIsValidating] = useState(false);

  // Queries
  const { data: servers = [] } = useQuery<ServerType[]>({
    queryKey: ["servers"],
    queryFn: () => apiRequest("/servers"),
    enabled: isOpen,
  });

  const { data: backends = [] } = useQuery<BackendType[]>({
    queryKey: ["backends"],
    queryFn: () => apiRequest("/backends"),
    enabled: isOpen && attachRoute,
  });

  const { data: presets = [] } = useQuery<FeaturePreset[]>({
    queryKey: ["feature-presets"],
    queryFn: () => apiRequest("/feature-presets"),
    enabled: isOpen,
  });

  const { data: registryFeatures = [] } = useQuery<FeatureItem[]>({
    queryKey: ["features-registry"],
    queryFn: () => apiRequest("/features/registry"),
    enabled: isOpen,
  });

  // Handle prefill
  useEffect(() => {
    if (prefill) {
      if (prefill.port) setPortNum(String(prefill.port));
      if (prefill.processName) setProcessName(prefill.processName);
      if (prefill.bindAddress) {
        setExpectedBind(prefill.bindAddress);
        setIsPublic(
          prefill.bindAddress === "0.0.0.0" || prefill.bindAddress === "::",
        );
      }
      if (prefill.lifecycle) setLifecycle(prefill.lifecycle as any);
    }
  }, [prefill]);

  // Adjust layer / protocol defaults
  useEffect(() => {
    if (layer === "http") {
      if (protocol === "TCP" || protocol === "UDP") setProtocol("HTTP");
    } else {
      if (protocol === "HTTP" || protocol === "HTTPS") setProtocol("TCP");
    }
  }, [layer]);

  // When bind changes, default isPublic
  useEffect(() => {
    if (expectedBind === "127.0.0.1" || expectedBind === "localhost") {
      setIsPublic(false);
    } else if (expectedBind === "0.0.0.0" || expectedBind === "::") {
      setIsPublic(true);
    }
  }, [expectedBind]);

  // Initialize features when registry or preset is selected
  useEffect(() => {
    if (selectedPresetId) {
      const preset = presets.find((p) => p.id === selectedPresetId);
      if (preset && typeof preset.features === "object") {
        setFeaturesConfig(preset.features);
      }
    } else if (
      registryFeatures.length > 0 &&
      Object.keys(featuresConfig).length === 0
    ) {
      const initial: Record<string, { enabled: boolean; config?: any }> = {};
      for (const feat of registryFeatures) {
        const isPlanned = lifecycle === "planned" || lifecycle === "reserved";
        initial[feat.key] = {
          enabled: isPlanned ? false : feat.enabled,
          config: { ...feat.defaultConfig },
        };
      }
      setFeaturesConfig(initial);
    }
  }, [selectedPresetId, registryFeatures, presets, lifecycle]);

  // Trigger live conflict check when portNum or serverId changes
  useEffect(() => {
    const p = parseInt(portNum);
    if (!isNaN(p) && p >= 1 && p <= 65535) {
      const timer = setTimeout(async () => {
        try {
          setIsValidating(true);
          const res = await apiRequest("/ports/validate", {
            method: "POST",
            body: JSON.stringify({
              port: p,
              serverId: serverId || null,
              expectedBind,
              isPublic,
              initialRoute:
                attachRoute && backendPort
                  ? { backendPort, backendHost }
                  : null,
            }),
          });
          setValidationResult(res);
        } catch (e) {
          // Ignore
        } finally {
          setIsValidating(false);
        }
      }, 300);
      return () => clearTimeout(timer);
    } else {
      setValidationResult(null);
    }
  }, [
    portNum,
    serverId,
    expectedBind,
    isPublic,
    attachRoute,
    backendPort,
    backendHost,
  ]);

  // Toggle single feature
  const toggleFeature = (key: string, enabled: boolean) => {
    setFeaturesConfig((prev) => ({
      ...prev,
      [key]: {
        ...(prev[key] || {}),
        enabled,
      },
    }));
  };

  // Create Port Mutation
  const createPortMutation = useMutation({
    mutationFn: async (saveAndAnother: boolean = false) => {
      const payload: any = {
        port: parseInt(portNum),
        layer,
        protocol,
        purpose,
        serverId: serverId || null,
        serverName: isAddingServerInline ? newServerName : null,
        lifecycle,
        lifecycleReason: lifecycleReason || null,
        targetDate: targetDate || null,
        owner: owner || null,
        maintenanceFrom: maintenanceFrom || null,
        maintenanceTo: maintenanceTo || null,
        expectedBind,
        isPublic,
        processName: processName || null,
        features: featuresConfig,
      };

      if (attachRoute && routeDomain) {
        payload.initialRoute = {
          domain: routeDomain,
          path: routePath || "/",
          action: routeAction,
          backendId: selectedBackendId || null,
          backendHost,
          backendPort,
        };
      }

      const res = await apiRequest("/ports", {
        method: "POST",
        body: JSON.stringify(payload),
      });
      return { res, saveAndAnother };
    },
    onSuccess: ({ saveAndAnother }) => {
      queryClient.invalidateQueries({ queryKey: ["ports"] });
      queryClient.invalidateQueries({ queryKey: ["overview"] });
      if (saveAndAnother) {
        setPortNum("");
        setPurpose("");
        setStep(1);
      } else {
        onClose();
      }
    },
  });

  // Bulk Range / Paste preview
  const handleBulkPreview = async () => {
    try {
      const payload: any = {
        previewOnly: true,
        layer,
        protocol,
        purpose,
        lifecycle,
        serverId: serverId || null,
        presetId: selectedPresetId || null,
      };

      if (mode === "range") {
        payload.portRange = portRange;
      } else {
        // Parse CSV or newline lines
        const lines = pasteText
          .split("\n")
          .map((l) => l.trim())
          .filter(Boolean);
        const parsedList = lines.map((line) => {
          const parts = line.split(",").map((p) => p.trim());
          return {
            port: parts[0],
            layer: parts[1] || layer,
            protocol: parts[2] || protocol,
            purpose: parts[3] || purpose,
          };
        });
        payload.portsList = parsedList;
      }

      const res = await apiRequest("/ports/bulk", {
        method: "POST",
        body: JSON.stringify(payload),
      });
      setBulkPreview(res);
    } catch (e: any) {
      alert(e.message || "Bulk preview failed");
    }
  };

  // Bulk Commit
  const handleBulkCommit = async () => {
    try {
      const payload: any = {
        previewOnly: false,
        skipConflicts: true,
        layer,
        protocol,
        purpose,
        lifecycle,
        serverId: serverId || null,
        presetId: selectedPresetId || null,
      };

      if (mode === "range") {
        payload.portRange = portRange;
      } else {
        const lines = pasteText
          .split("\n")
          .map((l) => l.trim())
          .filter(Boolean);
        const parsedList = lines.map((line) => {
          const parts = line.split(",").map((p) => p.trim());
          return {
            port: parts[0],
            layer: parts[1] || layer,
            protocol: parts[2] || protocol,
            purpose: parts[3] || purpose,
          };
        });
        payload.portsList = parsedList;
      }

      await apiRequest("/ports/bulk", {
        method: "POST",
        body: JSON.stringify(payload),
      });

      queryClient.invalidateQueries({ queryKey: ["ports"] });
      queryClient.invalidateQueries({ queryKey: ["overview"] });
      onClose();
    } catch (e: any) {
      alert(e.message || "Bulk creation failed");
    }
  };

  // Keyboard navigation: Enter goes to next step, Ctrl+Enter saves
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (!isOpen) return;

      if ((e.ctrlKey || e.metaKey) && e.key === "Enter") {
        e.preventDefault();
        if (mode === "single" && step === 5 && validationResult?.valid) {
          createPortMutation.mutate(false);
        }
      } else if (
        e.key === "Enter" &&
        !e.shiftKey &&
        (e.target as HTMLElement).tagName !== "TEXTAREA"
      ) {
        if (mode === "single" && step < 5) {
          e.preventDefault();
          setStep((s) => s + 1);
        }
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, mode, step, validationResult, createPortMutation]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-text/40 backdrop-blur-sm animate-in fade-in">
      <div className="relative w-full max-w-2xl bg-surface border border-border-strong rounded-xl shadow-2xl flex flex-col max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="px-6 py-4 border-b border-border bg-surface-2/60 flex items-center justify-between">
          <div>
            <h2 className="text-base font-semibold text-text flex items-center gap-2">
              <Plus className="w-4 h-4 text-primary" />
              <span>Add Port to PortWatch</span>
            </h2>
            <p className="text-xs text-text-muted mt-0.5">
              Document active listener, reserve a port, or plan a future project
              deployment.
            </p>
          </div>
          <button
            onClick={onClose}
            aria-label="Close dialog"
            className="p-1 rounded-lg text-text-muted hover:text-text hover:bg-surface transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Mode Tabs: Single / Range / Paste */}
        <div className="flex border-b border-border bg-surface px-6 pt-2">
          <button
            onClick={() => {
              setMode("single");
              setStep(1);
            }}
            className={`px-4 py-2 text-xs font-medium border-b-2 transition-colors ${
              mode === "single"
                ? "border-primary text-primary font-semibold"
                : "border-transparent text-text-muted hover:text-text"
            }`}
          >
            Single Port
          </button>
          <button
            onClick={() => {
              setMode("range");
              setBulkPreview(null);
            }}
            className={`px-4 py-2 text-xs font-medium border-b-2 transition-colors ${
              mode === "range"
                ? "border-primary text-primary font-semibold"
                : "border-transparent text-text-muted hover:text-text"
            }`}
          >
            Bulk Range (e.g. 3000-3010)
          </button>
          <button
            onClick={() => {
              setMode("paste");
              setBulkPreview(null);
            }}
            className={`px-4 py-2 text-xs font-medium border-b-2 transition-colors ${
              mode === "paste"
                ? "border-primary text-primary font-semibold"
                : "border-transparent text-text-muted hover:text-text"
            }`}
          >
            Paste List / CSV
          </button>
        </div>

        {/* Modal Body */}
        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          {mode === "single" && (
            <>
              {/* Stepper Progress Bar */}
              <div className="flex items-center justify-between border-b border-border pb-4">
                {[
                  { num: 1, label: "Basics" },
                  { num: 2, label: "Network" },
                  { num: 3, label: "Attach" },
                  { num: 4, label: "Features" },
                  { num: 5, label: "Review" },
                ].map((s) => (
                  <button
                    key={s.num}
                    onClick={() => setStep(s.num)}
                    className="flex items-center gap-2 group text-left cursor-pointer"
                  >
                    <div
                      className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold transition-colors ${
                        step === s.num
                          ? "bg-primary text-on-primary"
                          : step > s.num
                            ? "bg-status-up text-on-primary"
                            : "bg-surface-2 text-text-muted border border-border"
                      }`}
                    >
                      {step > s.num ? <Check className="w-3.5 h-3.5" /> : s.num}
                    </div>
                    <span
                      className={`text-xs font-medium ${
                        step === s.num
                          ? "text-text font-bold"
                          : "text-text-muted"
                      }`}
                    >
                      {s.label}
                    </span>
                  </button>
                ))}
              </div>

              {/* STEP 1: BASICS */}
              {step === 1 && (
                <div className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-medium text-text mb-1">
                        Port Number (1–65535){" "}
                        <span className="text-status-down">*</span>
                      </label>
                      <input
                        type="number"
                        min="1"
                        max="65535"
                        placeholder="e.g. 8080"
                        value={portNum}
                        onChange={(e) => setPortNum(e.target.value)}
                        className="w-full px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text focus:outline-none focus:border-primary font-mono-numbers"
                        autoFocus
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-medium text-text mb-1">
                        Lifecycle Status
                      </label>
                      <select
                        value={lifecycle}
                        onChange={(e) => setLifecycle(e.target.value as any)}
                        className="w-full px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text focus:outline-none focus:border-primary"
                      >
                        <option value="active">
                          Active (In use now, scanned & alerted)
                        </option>
                        <option value="planned">
                          Planned (Intend to open later)
                        </option>
                        <option value="reserved">
                          Reserved (Held for project, no probe)
                        </option>
                        <option value="maintenance">
                          Maintenance (Mutes alerts)
                        </option>
                        <option value="deprecated">
                          Deprecated (To be removed)
                        </option>
                      </select>
                    </div>
                  </div>

                  {/* Planned / Reserved Extra Fields */}
                  {(lifecycle === "planned" || lifecycle === "reserved") && (
                    <div className="p-3 bg-surface-2/60 border border-border rounded-lg space-y-3">
                      <div className="text-xs font-semibold text-status-info flex items-center gap-1.5">
                        <Info className="w-3.5 h-3.5" />
                        <span>
                          Planned & Reserved ports are excluded from scanner
                          DOWN checks
                        </span>
                      </div>
                      <div className="grid grid-cols-2 gap-3">
                        <div>
                          <label className="block text-xs text-text-muted mb-1">
                            Target Opening Date
                          </label>
                          <input
                            type="date"
                            value={targetDate}
                            onChange={(e) => setTargetDate(e.target.value)}
                            className="w-full px-2.5 py-1.5 text-xs bg-surface border border-border rounded text-text"
                          />
                        </div>
                        <div>
                          <label className="block text-xs text-text-muted mb-1">
                            Owner / Team
                          </label>
                          <input
                            type="text"
                            placeholder="e.g. backend-team"
                            value={owner}
                            onChange={(e) => setOwner(e.target.value)}
                            className="w-full px-2.5 py-1.5 text-xs bg-surface border border-border rounded text-text"
                          />
                        </div>
                      </div>
                      <div>
                        <label className="block text-xs text-text-muted mb-1">
                          Reason / Project Name
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. Migration to gRPC gateway"
                          value={lifecycleReason}
                          onChange={(e) => setLifecycleReason(e.target.value)}
                          className="w-full px-2.5 py-1.5 text-xs bg-surface border border-border rounded text-text"
                        />
                      </div>
                    </div>
                  )}

                  {/* Maintenance Extra Fields */}
                  {lifecycle === "maintenance" && (
                    <div className="p-3 bg-surface-2/60 border border-border rounded-lg space-y-3">
                      <div className="text-xs font-semibold text-status-slow flex items-center gap-1.5">
                        <AlertTriangle className="w-3.5 h-3.5" />
                        <span>
                          Maintenance window: scanner runs but alerts are muted.
                          Ends automatically.
                        </span>
                      </div>
                      <div className="grid grid-cols-2 gap-3">
                        <div>
                          <label className="block text-xs text-text-muted mb-1">
                            Start Time
                          </label>
                          <input
                            type="datetime-local"
                            value={maintenanceFrom}
                            onChange={(e) => setMaintenanceFrom(e.target.value)}
                            className="w-full px-2.5 py-1.5 text-xs bg-surface border border-border rounded text-text"
                          />
                        </div>
                        <div>
                          <label className="block text-xs text-text-muted mb-1">
                            End Time
                          </label>
                          <input
                            type="datetime-local"
                            value={maintenanceTo}
                            onChange={(e) => setMaintenanceTo(e.target.value)}
                            className="w-full px-2.5 py-1.5 text-xs bg-surface border border-border rounded text-text"
                          />
                        </div>
                      </div>
                    </div>
                  )}

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-medium text-text mb-1">
                        Layer
                      </label>
                      <select
                        value={layer}
                        onChange={(e) => setLayer(e.target.value as any)}
                        className="w-full px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text focus:outline-none focus:border-primary"
                      >
                        <option value="http">HTTP Layer (Nginx Web)</option>
                        <option value="stream">
                          Stream Layer (TCP/UDP Passthrough)
                        </option>
                      </select>
                    </div>

                    <div>
                      <label className="block text-xs font-medium text-text mb-1">
                        Protocol
                      </label>
                      <select
                        value={protocol}
                        onChange={(e) => setProtocol(e.target.value as any)}
                        className="w-full px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text focus:outline-none focus:border-primary"
                      >
                        {layer === "http" ? (
                          <>
                            <option value="HTTP">HTTP</option>
                            <option value="HTTPS">HTTPS</option>
                          </>
                        ) : (
                          <>
                            <option value="TCP">TCP</option>
                            <option value="UDP">UDP</option>
                          </>
                        )}
                      </select>
                    </div>
                  </div>

                  <div>
                    <label className="block text-xs font-medium text-text mb-1">
                      Purpose / Service Label
                    </label>
                    <input
                      type="text"
                      placeholder="e.g. Customer Portal API"
                      value={purpose}
                      onChange={(e) => setPurpose(e.target.value)}
                      className="w-full px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text focus:outline-none focus:border-primary"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-medium text-text mb-1">
                      Server Host
                    </label>
                    {!isAddingServerInline ? (
                      <div className="flex gap-2">
                        <select
                          value={serverId}
                          onChange={(e) => setServerId(e.target.value)}
                          className="flex-1 px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text focus:outline-none focus:border-primary"
                        >
                          <option value="">Default Server (local host)</option>
                          {servers.map((s) => (
                            <option key={s.id} value={s.id}>
                              {s.name} ({s.host})
                            </option>
                          ))}
                        </select>
                        <Button
                          variant="secondary"
                          size="sm"
                          onClick={() => setIsAddingServerInline(true)}
                          className="text-xs"
                        >
                          <Plus className="w-3.5 h-3.5 mr-1" />
                          New Server
                        </Button>
                      </div>
                    ) : (
                      <div className="flex gap-2 items-center">
                        <input
                          type="text"
                          placeholder="New server name (e.g. prod-node-02)"
                          value={newServerName}
                          onChange={(e) => setNewServerName(e.target.value)}
                          className="flex-1 px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text focus:outline-none focus:border-primary"
                        />
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setIsAddingServerInline(false)}
                          className="text-xs"
                        >
                          Cancel
                        </Button>
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* STEP 2: NETWORK */}
              {step === 2 && (
                <div className="space-y-4">
                  <div>
                    <label className="block text-xs font-medium text-text mb-1">
                      Expected Bind Address
                    </label>
                    <select
                      value={expectedBind}
                      onChange={(e) => setExpectedBind(e.target.value)}
                      className="w-full px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text focus:outline-none focus:border-primary"
                    >
                      <option value="0.0.0.0">
                        0.0.0.0 (All public & internal interfaces)
                      </option>
                      <option value="127.0.0.1">
                        127.0.0.1 (Local loopback only - private)
                      </option>
                      <option value="::">:: (IPv6 all interfaces)</option>
                      <option value="custom">Specific IP Address...</option>
                    </select>
                    {expectedBind === "custom" && (
                      <input
                        type="text"
                        placeholder="192.168.1.50"
                        onChange={(e) => setExpectedBind(e.target.value)}
                        className="mt-2 w-full px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text"
                      />
                    )}
                  </div>

                  <div className="flex items-center justify-between p-3 bg-surface-2 rounded-lg border border-border">
                    <div>
                      <div className="text-xs font-medium text-text">
                        Public Internet Accessible
                      </div>
                      <div className="text-[11px] text-text-muted">
                        Uncheck if this port should only be reachable via VPN or
                        local network
                      </div>
                    </div>
                    <input
                      type="checkbox"
                      checked={isPublic}
                      onChange={(e) => setIsPublic(e.target.checked)}
                      className="w-4 h-4 rounded text-primary focus:ring-primary"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-medium text-text mb-1">
                      Expected Process Name (Optional)
                    </label>
                    <input
                      type="text"
                      placeholder="e.g. nginx, redis-server, postgres"
                      value={processName}
                      onChange={(e) => setProcessName(e.target.value)}
                      className="w-full px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text focus:outline-none focus:border-primary"
                    />
                    <p className="text-[11px] text-text-muted mt-1">
                      If process verification feature is enabled, PortWatch
                      alerts if a different process binds this socket.
                    </p>
                  </div>
                </div>
              )}

              {/* STEP 3: ATTACH (OPTIONAL ROUTE) */}
              {step === 3 && (
                <div className="space-y-4">
                  <div className="flex items-center justify-between p-3 bg-surface-2 rounded-lg border border-border">
                    <div>
                      <div className="text-xs font-medium text-text">
                        Create and Link Initial Route
                      </div>
                      <div className="text-[11px] text-text-muted">
                        Connect a domain route directly to this port during
                        setup
                      </div>
                    </div>
                    <input
                      type="checkbox"
                      id="attachRouteCheck"
                      aria-label="Create and Link Initial Route"
                      checked={attachRoute}
                      onChange={(e) => setAttachRoute(e.target.checked)}
                      className="w-4 h-4 rounded text-primary focus:ring-primary"
                    />
                  </div>

                  {attachRoute && (
                    <div className="space-y-3 p-3 bg-surface-2/40 border border-border rounded-lg">
                      <div className="grid grid-cols-2 gap-3">
                        <div>
                          <label className="block text-xs text-text-muted mb-1">
                            Domain Name
                          </label>
                          <input
                            type="text"
                            placeholder="api.example.com"
                            value={routeDomain}
                            onChange={(e) => setRouteDomain(e.target.value)}
                            className="w-full px-2.5 py-1.5 text-xs bg-surface border border-border rounded text-text font-mono"
                          />
                        </div>
                        <div>
                          <label className="block text-xs text-text-muted mb-1">
                            Path
                          </label>
                          <input
                            type="text"
                            value={routePath}
                            onChange={(e) => setRoutePath(e.target.value)}
                            className="w-full px-2.5 py-1.5 text-xs bg-surface border border-border rounded text-text font-mono"
                          />
                        </div>
                      </div>

                      <div className="grid grid-cols-2 gap-3">
                        <div>
                          <label className="block text-xs text-text-muted mb-1">
                            Route Action
                          </label>
                          <select
                            value={routeAction}
                            onChange={(e) => setRouteAction(e.target.value)}
                            className="w-full px-2.5 py-1.5 text-xs bg-surface border border-border rounded text-text"
                          >
                            <option value="Proxy">
                              Proxy (Reverse Proxy to Backend)
                            </option>
                            <option value="Static">
                              Static (Serve local files)
                            </option>
                            <option value="Redirect">Redirect (301/302)</option>
                          </select>
                        </div>
                        <div>
                          <label className="block text-xs text-text-muted mb-1">
                            Backend Target (Host:Port)
                          </label>
                          <div className="flex gap-2">
                            <input
                              type="text"
                              placeholder="127.0.0.1"
                              value={backendHost}
                              onChange={(e) => setBackendHost(e.target.value)}
                              className="w-2/3 px-2.5 py-1.5 text-xs bg-surface border border-border rounded text-text font-mono"
                            />
                            <input
                              type="number"
                              placeholder="8080"
                              value={backendPort}
                              onChange={(e) => setBackendPort(e.target.value)}
                              className="w-1/3 px-2.5 py-1.5 text-xs bg-surface border border-border rounded text-text font-mono"
                            />
                          </div>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* STEP 4: FEATURES */}
              {step === 4 && (
                <div className="space-y-4">
                  <div>
                    <label className="block text-xs font-medium text-text mb-1">
                      Choose Feature Preset
                    </label>
                    <select
                      value={selectedPresetId}
                      onChange={(e) => setSelectedPresetId(e.target.value)}
                      className="w-full px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text focus:outline-none focus:border-primary"
                    >
                      <option value="">Custom Configuration</option>
                      {presets.map((p) => (
                        <option key={p.id} value={p.id}>
                          {p.name} {p.isBuiltin ? "(Built-in)" : "(Custom)"}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div className="border border-border rounded-lg divide-y divide-border max-h-64 overflow-y-auto">
                    {registryFeatures.map((feat) => {
                      const isEnabled =
                        featuresConfig[feat.key]?.enabled !== false;
                      return (
                        <div
                          key={feat.key}
                          className="p-3 flex items-center justify-between hover:bg-surface-2/40 transition-colors"
                        >
                          <div className="pr-4">
                            <div className="text-xs font-medium text-text flex items-center gap-2">
                              <span>{feat.label}</span>
                              {!feat.globallyEnabled && (
                                <span className="text-[10px] px-1.5 py-0.2 rounded bg-surface-2 text-text-muted border border-border">
                                  Disabled Globally
                                </span>
                              )}
                            </div>
                            <div className="text-[11px] text-text-muted line-clamp-1">
                              {feat.description}
                            </div>
                          </div>
                          <input
                            type="checkbox"
                            checked={isEnabled}
                            onChange={(e) =>
                              toggleFeature(feat.key, e.target.checked)
                            }
                            className="w-4 h-4 rounded text-primary focus:ring-primary"
                          />
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}

              {/* STEP 5: REVIEW & SAVE */}
              {step === 5 && (
                <div className="space-y-4">
                  {/* Conflict warnings */}
                  {validationResult && validationResult.warnings.length > 0 && (
                    <div className="space-y-2">
                      {validationResult.warnings.map((w, idx) => (
                        <div
                          key={idx}
                          className={`p-3 rounded-lg border text-xs flex items-start gap-2 ${
                            w.severity === "error"
                              ? "bg-status-down/10 border-status-down/30 text-status-down"
                              : w.severity === "warning"
                                ? "bg-status-slow/10 border-status-slow/30 text-status-slow"
                                : "bg-status-info/10 border-status-info/30 text-status-info"
                          }`}
                        >
                          {w.severity === "error" ? (
                            <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5" />
                          ) : (
                            <Info className="w-4 h-4 shrink-0 mt-0.5" />
                          )}
                          <div className="flex-1">
                            <div>{w.message}</div>
                            {w.suggestedPreset && (
                              <button
                                type="button"
                                onClick={() => {
                                  const p = presets.find(
                                    (pr) => pr.name === w.suggestedPreset,
                                  );
                                  if (p) setSelectedPresetId(p.id);
                                }}
                                className="mt-1 underline text-[11px] font-semibold"
                              >
                                Apply suggested preset: {w.suggestedPreset}
                              </button>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}

                  {/* Summary Box */}
                  <div className="p-4 bg-surface-2/60 border border-border rounded-lg space-y-2 text-xs">
                    <div className="font-semibold text-text border-b border-border pb-2 flex items-center justify-between">
                      <span className="font-mono-numbers text-sm">
                        Port :{portNum}
                      </span>
                      <LifecycleBadge lifecycle={lifecycle} />
                    </div>
                    <div className="grid grid-cols-2 gap-2 pt-1 text-text-muted">
                      <div>
                        Layer:{" "}
                        <span className="text-text font-medium">
                          {layer.toUpperCase()}
                        </span>
                      </div>
                      <div>
                        Protocol:{" "}
                        <span className="text-text font-medium">
                          {protocol}
                        </span>
                      </div>
                      <div>
                        Bind:{" "}
                        <span className="text-text font-mono">
                          {expectedBind}
                        </span>
                      </div>
                      <div>
                        Access:{" "}
                        <span className="text-text font-medium">
                          {isPublic ? "Public" : "Internal"}
                        </span>
                      </div>
                      {purpose && (
                        <div className="col-span-2">
                          Purpose: <span className="text-text">{purpose}</span>
                        </div>
                      )}
                      {attachRoute && routeDomain && (
                        <div className="col-span-2">
                          Route:{" "}
                          <span className="text-text font-mono">
                            {routeDomain}
                            {routePath}
                          </span>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              )}
            </>
          )}

          {/* BULK RANGE MODE */}
          {mode === "range" && (
            <div className="space-y-4">
              <div>
                <label className="block text-xs font-medium text-text mb-1">
                  Port Range (e.g. 3000-3010)
                </label>
                <input
                  type="text"
                  value={portRange}
                  onChange={(e) => setPortRange(e.target.value)}
                  placeholder="3000-3010"
                  className="w-full px-3 py-2 text-sm bg-surface-2 border border-border rounded-lg text-text font-mono"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs text-text-muted mb-1">
                    Shared Purpose
                  </label>
                  <input
                    type="text"
                    value={purpose}
                    onChange={(e) => setPurpose(e.target.value)}
                    placeholder="e.g. Internal Microservices"
                    className="w-full px-3 py-2 text-xs bg-surface-2 border border-border rounded text-text"
                  />
                </div>
                <div>
                  <label className="block text-xs text-text-muted mb-1">
                    Shared Lifecycle
                  </label>
                  <select
                    value={lifecycle}
                    onChange={(e) => setLifecycle(e.target.value as any)}
                    className="w-full px-3 py-2 text-xs bg-surface-2 border border-border rounded text-text"
                  >
                    <option value="active">Active</option>
                    <option value="planned">Planned</option>
                    <option value="reserved">Reserved</option>
                  </select>
                </div>
              </div>

              <Button variant="secondary" size="sm" onClick={handleBulkPreview}>
                Preview Range ({portRange})
              </Button>

              {bulkPreview && (
                <div className="p-3 bg-surface-2 border border-border rounded-lg space-y-2 text-xs">
                  <div className="flex justify-between font-medium">
                    <span>Total: {bulkPreview.total} ports</span>
                    <span className="text-status-up">
                      Valid: {bulkPreview.validCount}
                    </span>
                    {bulkPreview.conflictCount > 0 && (
                      <span className="text-status-slow">
                        Conflicts (skipped): {bulkPreview.conflictCount}
                      </span>
                    )}
                  </div>
                  {bulkPreview.conflicts.length > 0 && (
                    <div className="text-[11px] text-status-slow">
                      {bulkPreview.conflicts.map((c: any, i: number) => (
                        <div key={i}>• {c.reason}</div>
                      ))}
                    </div>
                  )}
                </div>
              )}
            </div>
          )}

          {/* BULK PASTE MODE */}
          {mode === "paste" && (
            <div className="space-y-4">
              <div>
                <label className="block text-xs font-medium text-text mb-1">
                  Paste Port List (one per line: port, layer, protocol, purpose)
                </label>
                <textarea
                  rows={6}
                  value={pasteText}
                  onChange={(e) => setPasteText(e.target.value)}
                  placeholder={`3000, http, HTTP, Web App\n3001, http, HTTP, Admin API\n3002, stream, TCP, Worker`}
                  className="w-full px-3 py-2 text-xs bg-surface-2 border border-border rounded-lg text-text font-mono"
                />
              </div>

              <Button variant="secondary" size="sm" onClick={handleBulkPreview}>
                Parse & Preview
              </Button>

              {bulkPreview && (
                <div className="p-3 bg-surface-2 border border-border rounded-lg space-y-2 text-xs">
                  <div className="flex justify-between font-medium">
                    <span>Total parsed: {bulkPreview.total}</span>
                    <span className="text-status-up">
                      Valid: {bulkPreview.validCount}
                    </span>
                    {bulkPreview.conflictCount > 0 && (
                      <span className="text-status-slow">
                        Conflicts: {bulkPreview.conflictCount}
                      </span>
                    )}
                  </div>
                </div>
              )}
            </div>
          )}
        </div>

        {/* Footer Navigation */}
        <div className="px-6 py-4 border-t border-border bg-surface-2/60 flex items-center justify-between">
          {mode === "single" ? (
            <>
              <div>
                {step > 1 && (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => setStep((s) => s - 1)}
                    className="text-xs"
                  >
                    <ArrowLeft className="w-3.5 h-3.5 mr-1" />
                    Back
                  </Button>
                )}
              </div>
              <div className="flex gap-2">
                {step < 5 ? (
                  <Button
                    variant="primary"
                    size="sm"
                    onClick={() => setStep((s) => s + 1)}
                    className="text-xs"
                  >
                    Next
                    <ArrowRight className="w-3.5 h-3.5 ml-1" />
                  </Button>
                ) : (
                  <>
                    <Button
                      variant="secondary"
                      size="sm"
                      onClick={() => createPortMutation.mutate(true)}
                      isLoading={createPortMutation.isPending}
                      className="text-xs"
                    >
                      Save & Add Another
                    </Button>
                    <Button
                      variant="primary"
                      size="sm"
                      onClick={() => createPortMutation.mutate(false)}
                      isLoading={createPortMutation.isPending}
                      className="text-xs"
                    >
                      Save Port
                    </Button>
                  </>
                )}
              </div>
            </>
          ) : (
            <div className="flex justify-end gap-2 w-full">
              <Button
                variant="ghost"
                size="sm"
                onClick={onClose}
                className="text-xs"
              >
                Cancel
              </Button>
              <Button
                variant="primary"
                size="sm"
                onClick={handleBulkCommit}
                disabled={!bulkPreview || bulkPreview.validCount === 0}
                className="text-xs"
              >
                Import {bulkPreview ? `${bulkPreview.validCount} Ports` : ""}
              </Button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
