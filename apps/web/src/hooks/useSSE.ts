import { useEffect, useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';

export interface ScanProgress {
  stage: string;
  progress: number;
}

export function useSSE() {
  const queryClient = useQueryClient();
  const [isConnected, setIsConnected] = useState(false);
  const [scanProgress, setScanProgress] = useState<ScanProgress | null>(null);
  const [lastEvent, setLastEvent] = useState<any>(null);

  useEffect(() => {
    const eventSource = new EventSource('/api/stream');

    eventSource.onopen = () => {
      setIsConnected(true);
    };

    eventSource.onerror = () => {
      setIsConnected(false);
    };

    eventSource.addEventListener('connected', () => {
      setIsConnected(true);
    });

    eventSource.addEventListener('status_change', (event: MessageEvent) => {
      try {
        const data = JSON.parse(event.data);
        setLastEvent({ type: 'status_change', ...data });
        // Invalidate queries so tables & dashboard refresh live
        queryClient.invalidateQueries({ queryKey: ['overview'] });
        queryClient.invalidateQueries({ queryKey: ['ports'] });
        queryClient.invalidateQueries({ queryKey: ['backends'] });
        queryClient.invalidateQueries({ queryKey: ['history'] });
      } catch (err) {}
    });

    eventSource.addEventListener('scan_progress', (event: MessageEvent) => {
      try {
        const data = JSON.parse(event.data);
        setScanProgress(data);
      } catch (err) {}
    });

    eventSource.addEventListener('scan_complete', (event: MessageEvent) => {
      try {
        setScanProgress(null);
        queryClient.invalidateQueries({ queryKey: ['overview'] });
        queryClient.invalidateQueries({ queryKey: ['ports'] });
        queryClient.invalidateQueries({ queryKey: ['backends'] });
        queryClient.invalidateQueries({ queryKey: ['issues'] });
        queryClient.invalidateQueries({ queryKey: ['certificates'] });
      } catch (err) {}
    });

    return () => {
      eventSource.close();
    };
  }, [queryClient]);

  return { isConnected, scanProgress, lastEvent };
}
