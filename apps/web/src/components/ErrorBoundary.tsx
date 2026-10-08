import React from 'react';

interface ErrorBoundaryProps {
  children: React.ReactNode;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

/**
 * Catches render-time crashes anywhere in the routed page tree. Without it a
 * single broken component unmounts the whole React tree and leaves a blank
 * white page with no diagnostics.
 */
export class ErrorBoundary extends React.Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    console.error('ErrorBoundary caught:', error, info.componentStack);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="max-w-lg m-8 border border-status-down/30 bg-status-down/10 rounded-xl p-6 space-y-3">
          <h2 className="font-semibold text-text">Something went wrong</h2>
          <p className="text-xs text-text-muted font-mono break-all">
            {this.state.error?.message || 'Unknown render error'}
          </p>
          <button
            className="px-3 py-1.5 rounded-md bg-surface-2 border border-border text-xs text-text hover:bg-surface"
            onClick={() => {
              this.setState({ hasError: false, error: null });
              window.location.href = '/';
            }}
          >
            Reload dashboard
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}

export default ErrorBoundary;
