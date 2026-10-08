import React, { useState, useEffect } from "react";
import {
  Search,
  RefreshCw,
  Sun,
  Moon,
  Plus,
  LogOut,
  Menu,
  Monitor,
} from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { Button } from "../ui/Button";
import { apiRequest } from "../../lib/api";
import { useSSE } from "../../hooks/useSSE";

interface HeaderProps {
  onOpenPalette: () => void;
  onOpenAddPort?: () => void;
  onToggleMobileNav?: () => void;
}

type ThemeMode = "dark" | "light" | "system";

export function Header({
  onOpenPalette,
  onOpenAddPort,
  onToggleMobileNav,
}: HeaderProps) {
  const { data: currentUser } = useQuery<{ role: string; username: string }>({
    queryKey: ["auth-me"],
    queryFn: () =>
      apiRequest("/auth/me").catch(() => ({
        role: "viewer",
        username: "guest",
      })),
    staleTime: 60000,
  });
  const isViewer = currentUser?.role === "viewer";
  const { isConnected, scanProgress } = useSSE();
  const [isScanning, setIsScanning] = useState(false);
  const [theme, setTheme] = useState<ThemeMode>(() => {
    if (typeof window !== "undefined") {
      return (localStorage.getItem("theme") as ThemeMode) || "dark";
    }
    return "dark";
  });

  const applyTheme = React.useCallback((mode: ThemeMode) => {
    const prefersLight =
      typeof window !== "undefined" &&
      window.matchMedia("(prefers-color-scheme: light)").matches;
    const isDark = mode === "system" ? !prefersLight : mode === "dark";
    document.documentElement.classList.toggle("dark", isDark);
    localStorage.setItem("theme", mode);
    const bg = getComputedStyle(document.documentElement)
      .getPropertyValue("--bg")
      .trim();
    const meta = document.getElementById("meta-theme-color");
    if (meta && bg) meta.setAttribute("content", bg);
  }, []);

  // System mode must follow live OS changes
  React.useEffect(() => {
    const mq = window.matchMedia("(prefers-color-scheme: light)");
    const handler = () => {
      if (theme === "system") applyTheme("system");
    };
    mq.addEventListener("change", handler);
    return () => mq.removeEventListener("change", handler);
  }, [theme, applyTheme]);
  const [countdown, setCountdown] = useState(30);

  // Scan countdown timer
  useEffect(() => {
    const timer = setInterval(() => {
      setCountdown((prev) => (prev <= 1 ? 30 : prev - 1));
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const handleScanNow = async () => {
    try {
      setIsScanning(true);
      await apiRequest("/scan", { method: "POST" });
      setCountdown(30);
    } catch (err) {
      console.error("Scan error:", err);
    } finally {
      setTimeout(() => setIsScanning(false), 2000);
    }
  };

  const toggleTheme = () => {
    const next: ThemeMode =
      theme === "dark" ? "light" : theme === "light" ? "system" : "dark";
    setTheme(next);
    applyTheme(next);
  };

  return (
    <header className="h-16 border-b border-border bg-surface/80 backdrop-blur-md sticky top-0 z-30 px-3 sm:px-6 flex items-center justify-between">
      <div className="flex items-center gap-3">
        {/* Mobile nav toggle (sidebar is off-canvas below lg) */}
        {onToggleMobileNav && (
          <button
            onClick={onToggleMobileNav}
            className="lg:hidden p-2 rounded-lg text-text-muted hover:text-text hover:bg-surface-2 transition-colors"
            aria-label="Open navigation menu"
          >
            <Menu className="w-4 h-4" />
          </button>
        )}
        <button
          onClick={onOpenPalette}
          className="hidden lg:flex items-center gap-3 px-3.5 py-1.5 rounded-lg bg-surface-2 hover:bg-surface border border-border text-text-muted hover:text-text text-xs transition-colors w-72 justify-between"
        >
          <span className="flex items-center gap-2">
            <Search className="w-3.5 h-3.5" />
            <span>Quick jump to port, domain...</span>
          </span>
          <kbd className="px-1.5 py-0.5 text-[10px] font-mono bg-surface text-text-muted rounded border border-border-strong">
            ⌘K
          </kbd>
        </button>
      </div>

      {/* Right control items */}
      <div className="flex items-center gap-2 sm:gap-4 min-w-0">
        {/* Realtime Live Pulse */}
        <div className="hidden lg:flex items-center gap-2 px-2.5 py-1 rounded-full bg-surface-2 border border-border text-xs">
          <span className="relative flex h-2 w-2">
            <span
              className={`animate-ping absolute inline-flex h-full w-full rounded-full ${
                isConnected
                  ? "bg-status-up opacity-75"
                  : "bg-status-slow opacity-75"
              }`}
            />
            <span
              className={`relative inline-flex rounded-full h-2 w-2 ${
                isConnected ? "bg-status-up" : "bg-status-slow"
              }`}
            />
          </span>
          <span className="text-[11px] text-text font-medium">
            {isConnected ? "Live SSE" : "Connecting"}
          </span>
          <span className="text-text-muted text-[10px] font-mono">
            ({countdown}s)
          </span>
        </div>

        {/* Quick Add Port Button */}
        {!isViewer && onOpenAddPort && (
          <Button
            variant="primary"
            size="sm"
            onClick={onOpenAddPort}
            className="text-xs flex items-center gap-1.5"
            title="Add a new or planned port (Ctrl+K -> Add port)"
          >
            <Plus className="w-3.5 h-3.5" />
            <span className="hidden sm:inline">Add Port</span>
          </Button>
        )}

        {/* Scan Now Button */}
        <Button
          variant="secondary"
          size="sm"
          onClick={handleScanNow}
          isLoading={isScanning || !!scanProgress}
          className="text-xs"
        >
          <RefreshCw
            className={`w-3.5 h-3.5 ${isScanning ? "animate-spin" : ""}`}
          />
          <span className="hidden lg:inline">
            {scanProgress ? `Scanning ${scanProgress.progress}%` : "Scan Now"}
          </span>
        </Button>

        {/* Theme Toggle */}
        <button
          onClick={toggleTheme}
          className="p-2 rounded-lg text-text-muted hover:text-text hover:bg-surface-2 transition-colors"
          title={`Theme: ${theme} — click to cycle dark → light → system`}
          aria-label={`Theme is set to ${theme}. Click to change.`}
        >
          {theme === "dark" ? (
            <Sun className="w-4 h-4" />
          ) : theme === "light" ? (
            <Moon className="w-4 h-4" />
          ) : (
            <Monitor className="w-4 h-4" />
          )}
        </button>

        {/* User Pill (real session identity, with sign-out) */}
        <div className="flex items-center gap-2 pl-2 border-l border-border">
          <div className="w-7 h-7 rounded-full bg-primary/20 text-primary border border-primary/30 flex items-center justify-center font-bold text-xs">
            {(currentUser?.username || "g").charAt(0).toUpperCase()}
          </div>
          <span className="hidden sm:inline text-xs font-medium text-text">
            {currentUser?.username || "guest"}
          </span>
          <button
            onClick={async () => {
              try {
                await apiRequest("/auth/logout", { method: "POST" });
              } finally {
                window.location.href = "/login";
              }
            }}
            className="p-1.5 rounded-md text-text-muted hover:text-status-down hover:bg-surface-2 transition-colors"
            title="Sign out"
            aria-label="Sign out"
          >
            <LogOut className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>
    </header>
  );
}
