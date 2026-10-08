import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Radio } from "lucide-react";
import { apiRequest } from "../../lib/api";
import { Button } from "../ui/Button";

/**
 * Login page. PortWatch previously had no authentication UI at all: the app
 * silently presented an "admin" session even when /api/auth/me returned 401.
 */
export function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const navigate = useNavigate();

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError("");
    try {
      await apiRequest("/auth/login", {
        method: "POST",
        body: JSON.stringify({ username, password }),
      });
      navigate("/", { replace: true });
    } catch (err) {
      setError((err as Error).message || "Sign-in failed");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="min-h-screen bg-bg flex items-center justify-center p-4">
      <form
        onSubmit={submit}
        className="w-full max-w-sm bg-surface border border-border rounded-xl p-6 space-y-4 shadow-sm"
      >
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-primary to-accent p-0.5 flex items-center justify-center">
            <div className="w-full h-full bg-surface rounded-[9px] flex items-center justify-center">
              <Radio className="w-4 h-4 text-primary" />
            </div>
          </div>
          <div>
            <div className="font-bold text-sm tracking-tight text-text">
              PortWatch
            </div>
            <div className="text-[11px] text-text-muted font-mono">
              leadowserver
            </div>
          </div>
        </div>

        <h1 className="text-base font-semibold text-text">Sign in</h1>

        {error && (
          <div
            role="alert"
            className="text-xs text-status-down bg-status-down/10 border border-status-down/30 rounded-md px-3 py-2"
          >
            {error}
          </div>
        )}

        <label className="block space-y-1">
          <span className="text-xs text-text-muted">Username</span>
          <input
            type="text"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            autoComplete="username"
            required
            className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-sm text-text focus:outline-none focus:border-primary"
          />
        </label>

        <label className="block space-y-1">
          <span className="text-xs text-text-muted">Password</span>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            autoComplete="current-password"
            required
            className="w-full px-3 py-2 rounded-lg bg-surface-2 border border-border-strong text-sm text-text focus:outline-none focus:border-primary"
          />
        </label>

        <Button
          type="submit"
          variant="primary"
          disabled={busy}
          className="w-full"
        >
          {busy ? "Signing in…" : "Sign in"}
        </Button>
      </form>
    </div>
  );
}

export default LoginPage;
