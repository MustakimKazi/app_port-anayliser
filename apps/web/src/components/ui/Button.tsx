import React from 'react';
import { Loader2 } from 'lucide-react';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost' | 'outline' | 'teal';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  children: React.ReactNode;
}

export function Button({
  variant = 'primary',
  size = 'md',
  isLoading = false,
  children,
  className = '',
  disabled,
  ...props
}: ButtonProps) {
  let variantStyles = 'bg-primary hover:bg-primary/90 text-on-primary shadow-sm';

  if (variant === 'secondary') {
    variantStyles = 'bg-surface-2 hover:bg-surface-2/80 text-text border border-border-strong';
  } else if (variant === 'danger') {
    variantStyles = 'bg-status-down hover:bg-status-down/90 text-on-primary shadow-sm';
  } else if (variant === 'ghost') {
    variantStyles = 'bg-transparent hover:bg-surface-2 text-text-muted hover:text-text';
  } else if (variant === 'outline') {
    variantStyles = 'bg-transparent border border-border-strong hover:bg-surface-2 text-text';
  } else if (variant === 'teal') {
    variantStyles = 'bg-accent hover:bg-accent/90 text-on-primary shadow-sm';
  }

  let sizeStyles = 'px-3 py-1.5 text-sm';
  if (size === 'sm') sizeStyles = 'px-2.5 py-1 text-xs';
  if (size === 'lg') sizeStyles = 'px-5 py-2.5 text-base';

  return (
    <button
      disabled={disabled || isLoading}
      className={`inline-flex items-center justify-center gap-2 font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-bg disabled:opacity-50 disabled:cursor-not-allowed ${variantStyles} ${sizeStyles} ${className}`}
      {...props}
    >
      {isLoading && <Loader2 className="w-4 h-4 animate-spin" />}
      {children}
    </button>
  );
}
