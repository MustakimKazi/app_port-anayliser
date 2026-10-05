import React, { useState } from 'react';
import { Copy, Check } from 'lucide-react';

interface CodeBlockProps {
  code: string;
  language?: string;
  inline?: boolean;
}

export function CodeBlock({ code, inline = false }: CodeBlockProps) {
  const [copied, setCopied] = useState(false);

  const handleCopy = (e: React.MouseEvent) => {
    e.stopPropagation();
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  if (inline) {
    return (
      <code className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded bg-surface-2 text-primary font-mono text-xs border border-border">
        <span>{code}</span>
        <button
          onClick={handleCopy}
          className="hover:text-text transition-colors"
          title="Copy to clipboard"
          aria-label="Copy to clipboard"
        >
          {copied ? <Check className="w-3 h-3 text-status-up" /> : <Copy className="w-3 h-3 opacity-60" />}
        </button>
      </code>
    );
  }

  return (
    <div className="relative group rounded-lg bg-surface-2 border border-border p-3 font-mono text-xs text-text overflow-x-auto">
      <div className="flex items-center justify-between gap-2 mb-1 border-b border-border pb-1.5">
        <span className="text-[10px] uppercase font-semibold text-text-muted">Terminal Command</span>
        <button
          onClick={handleCopy}
          className="flex items-center gap-1 px-2 py-0.5 rounded bg-surface hover:bg-surface-2 text-text-muted hover:text-text border border-border text-[11px] transition-colors"
          title="Copy command"
        >
          {copied ? (
            <>
              <Check className="w-3.5 h-3.5 text-status-up" />
              <span className="text-status-up">Copied</span>
            </>
          ) : (
            <>
              <Copy className="w-3.5 h-3.5" />
              <span>Copy</span>
            </>
          )}
        </button>
      </div>
      <pre className="text-primary whitespace-pre-wrap break-all select-all font-mono">
        {code}
      </pre>
    </div>
  );
}
