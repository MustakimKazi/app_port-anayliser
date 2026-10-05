import React from 'react';

interface CardProps {
  children: React.ReactNode;
  className?: string;
  hover?: boolean;
}

export function Card({ children, className = '', hover = false }: CardProps) {
  return (
    <div
      className={`rounded-xl border border-border bg-surface backdrop-blur-md shadow-sm p-5 text-text ${
        hover ? 'hover:border-border-strong hover:bg-surface-2 transition-all duration-200' : ''
      } ${className}`}
    >
      {children}
    </div>
  );
}

export function CardHeader({ children, className = '' }: { children: React.ReactNode; className?: string }) {
  return (
    <div className={`flex items-center justify-between pb-3 mb-4 border-b border-border ${className}`}>
      {children}
    </div>
  );
}

export function CardTitle({ children, className = '' }: { children: React.ReactNode; className?: string }) {
  return (
    <h3 className={`text-base font-semibold text-text tracking-tight ${className}`}>
      {children}
    </h3>
  );
}
