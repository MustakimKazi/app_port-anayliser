import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Layout } from './components/layout/Layout';

// Feature Pages
import { DashboardPage } from './features/dashboard/DashboardPage';
import { PortsPage } from './features/ports/PortsPage';
import { RoutesPage } from './features/routes/RoutesPage';
import { BackendsPage } from './features/backends/BackendsPage';
import { IssuesPage } from './features/issues/IssuesPage';
import { ConfigFilesPage } from './features/config-files/ConfigFilesPage';
import { CertificatesPage } from './features/certificates/CertificatesPage';
import { PortMapPage } from './features/port-map/PortMapPage';
import { HistoryPage } from './features/history/HistoryPage';
import { SettingsPage } from './features/settings/SettingsPage';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5000,
      retry: 1
    }
  }
});

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<DashboardPage />} />
            <Route path="ports" element={<PortsPage />} />
            <Route path="routes" element={<RoutesPage />} />
            <Route path="backends" element={<BackendsPage />} />
            <Route path="issues" element={<IssuesPage />} />
            <Route path="config-files" element={<ConfigFilesPage />} />
            <Route path="certificates" element={<CertificatesPage />} />
            <Route path="port-map" element={<PortMapPage />} />
            <Route path="history" element={<HistoryPage />} />
            <Route path="settings" element={<SettingsPage />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  );
}

export default App;
