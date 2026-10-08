import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import {
  QueryClient,
  QueryClientProvider,
  MutationCache,
} from "@tanstack/react-query";
import { Layout } from "./components/layout/Layout";
import { ErrorBoundary } from "./components/ErrorBoundary";
import { LoginPage } from "./components/auth/LoginPage";

// Feature Pages
import { DashboardPage } from "./features/dashboard/DashboardPage";
import { PortsPage } from "./features/ports/PortsPage";
import { RoutesPage } from "./features/routes/RoutesPage";
import { BackendsPage } from "./features/backends/BackendsPage";
import { IssuesPage } from "./features/issues/IssuesPage";
import { ConfigFilesPage } from "./features/config-files/ConfigFilesPage";
import { ConfigFileDetailPage } from "./features/config-files/ConfigFileDetailPage";
import { CertificatesPage } from "./features/certificates/CertificatesPage";
import { PortMapPage } from "./features/port-map/PortMapPage";
import { HistoryPage } from "./features/history/HistoryPage";
import { SettingsPage } from "./features/settings/SettingsPage";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5000,
      retry: 1,
    },
  },
  // 25+ mutations previously had no onError: failed save/delete/archive
  // operations looked successful. Surface every failure with a toast.
  mutationCache: new MutationCache({
    onError: (error) => {
      window.dispatchEvent(
        new CustomEvent("app-toast", {
          detail: (error as Error).message || "Operation failed",
        }),
      );
    },
  }),
});

/** Minimal global toast host (no third-party toast dependency). */
function ToastHost() {
  const [toasts, setToasts] = React.useState<{ id: number; message: string }[]>(
    [],
  );
  React.useEffect(() => {
    let seq = 0;
    const handler = (e: Event) => {
      const id = ++seq;
      const message = (e as CustomEvent<string>).detail;
      setToasts((t) => [...t, { id, message }]);
      setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 5000);
    };
    window.addEventListener("app-toast", handler);
    return () => window.removeEventListener("app-toast", handler);
  }, []);

  if (toasts.length === 0) return null;
  return (
    <div className="fixed bottom-4 right-4 z-50 space-y-2">
      {toasts.map((t) => (
        <div
          key={t.id}
          role="alert"
          className="px-4 py-2.5 rounded-lg bg-status-down text-white text-xs shadow-lg max-w-sm"
        >
          {t.message}
        </div>
      ))}
    </div>
  );
}

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <ToastHost />
        <ErrorBoundary>
          <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route path="/" element={<Layout />}>
              <Route index element={<DashboardPage />} />
              <Route path="ports" element={<PortsPage />} />
              <Route path="routes" element={<RoutesPage />} />
              <Route path="backends" element={<BackendsPage />} />
              <Route path="issues" element={<IssuesPage />} />
              <Route path="config-files" element={<ConfigFilesPage />} />
              <Route path="config-files/:id" element={<ConfigFileDetailPage />} />
              <Route path="certificates" element={<CertificatesPage />} />
              <Route path="port-map" element={<PortMapPage />} />
              <Route path="history" element={<HistoryPage />} />
              <Route path="settings" element={<SettingsPage />} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Route>
          </Routes>
        </ErrorBoundary>
      </BrowserRouter>
    </QueryClientProvider>
  );
}

export default App;
