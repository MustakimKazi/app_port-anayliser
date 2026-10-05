const API_BASE = '/api';

export async function apiRequest<T = any>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const url = endpoint.startsWith('/') ? `${API_BASE}${endpoint}` : `${API_BASE}/${endpoint}`;

  const defaultHeaders: Record<string, string> = {};
  if (!(options.body instanceof FormData)) {
    defaultHeaders['Content-Type'] = 'application/json';
  }

  const res = await fetch(url, {
    ...options,
    headers: {
      ...defaultHeaders,
      ...options.headers
    },
    credentials: 'include'
  });

  if (!res.ok) {
    let errMessage = `API request failed (${res.status})`;
    try {
      const json = await res.json();
      if (json.error) errMessage = typeof json.error === 'string' ? json.error : JSON.stringify(json.error);
    } catch (_) {}
    throw new Error(errMessage);
  }

  return res.json();
}
