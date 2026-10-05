import React from 'react';

interface Tab {
  id: string;
  label: string;
  badge?: number | string;
}

interface TabsProps {
  tabs: Tab[];
  activeTab: string;
  onChange: (id: string) => void;
  className?: string;
}

export function Tabs({ tabs, activeTab, onChange, className = '' }: TabsProps) {
  return (
    <div className={`flex items-center gap-1 border-b border-border ${className}`}>
      {tabs.map((tab) => {
        const isActive = tab.id === activeTab;
        return (
          <button
            key={tab.id}
            onClick={() => onChange(tab.id)}
            className={`relative py-2.5 px-3.5 text-xs font-medium transition-colors flex items-center gap-1.5 focus:outline-none ${
              isActive
                ? 'text-primary border-b-2 border-primary font-semibold'
                : 'text-text-muted hover:text-text hover:bg-surface-2 rounded-t'
            }`}
          >
            <span>{tab.label}</span>
            {tab.badge !== undefined && (
              <span
                className={`px-1.5 py-0.2 rounded-full text-[10px] font-mono-numbers ${
                  isActive ? 'bg-primary/10 text-primary' : 'bg-surface-2 text-text-muted'
                }`}
              >
                {tab.badge}
              </span>
            )}
          </button>
        );
      })}
    </div>
  );
}
