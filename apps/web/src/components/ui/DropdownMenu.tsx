import React, { useState, useRef, useEffect } from 'react';
import { MoreVertical } from 'lucide-react';

export interface DropdownMenuItem {
  label: string;
  icon?: React.ReactNode;
  onClick: () => void;
  variant?: 'default' | 'danger';
  disabled?: boolean;
}

interface DropdownMenuProps {
  items: DropdownMenuItem[];
  trigger?: React.ReactNode;
  align?: 'left' | 'right';
  className?: string;
  buttonClassName?: string;
  title?: string;
}

export function DropdownMenu({
  items,
  trigger,
  align = 'right',
  className = '',
  buttonClassName = '',
  title = 'More options'
}: DropdownMenuProps) {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }
    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') {
        setIsOpen(false);
      }
    }

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
      document.addEventListener('keydown', handleKeyDown);
    }
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [isOpen]);

  return (
    <div
      ref={containerRef}
      className={`relative inline-block text-left ${className}`}
      onClick={(e) => e.stopPropagation()}
    >
      <button
        type="button"
        title={title}
        aria-label={title}
        aria-expanded={isOpen}
        aria-haspopup="true"
        onClick={(e) => {
          e.stopPropagation();
          setIsOpen((prev) => !prev);
        }}
        className={`p-1.5 rounded-lg text-text-muted hover:text-text hover:bg-surface-2 transition-colors focus:outline-none focus:ring-1 focus:ring-primary ${buttonClassName}`}
      >
        {trigger || <MoreVertical className="w-4 h-4" />}
      </button>

      {isOpen && (
        <div
          role="menu"
          aria-orientation="vertical"
          className={`absolute ${
            align === 'right' ? 'right-0' : 'left-0'
          } mt-1 w-48 rounded-xl bg-surface border border-border shadow-2xl py-1 z-50 animate-in fade-in zoom-in-95 duration-100 divide-y divide-border/40`}
        >
          <div className="py-1">
            {items.map((item, idx) => {
              const isDanger = item.variant === 'danger';
              return (
                <button
                  key={idx}
                  type="button"
                  role="menuitem"
                  disabled={item.disabled}
                  onClick={(e) => {
                    e.stopPropagation();
                    setIsOpen(false);
                    item.onClick();
                  }}
                  className={`w-full flex items-center gap-2.5 px-3 py-2 text-xs transition-colors text-left ${
                    item.disabled
                      ? 'opacity-40 cursor-not-allowed text-text-muted'
                      : isDanger
                        ? 'text-status-down hover:bg-status-down/10'
                        : 'text-text hover:bg-surface-2 hover:text-primary'
                  }`}
                >
                  {item.icon && (
                    <span
                      className={`w-4 h-4 shrink-0 flex items-center justify-center ${
                        isDanger ? 'text-status-down' : 'text-text-muted'
                      }`}
                    >
                      {item.icon}
                    </span>
                  )}
                  <span className="truncate font-medium">{item.label}</span>
                </button>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}
