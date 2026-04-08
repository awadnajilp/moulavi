// Shared UI Components for Umrah Booking

import React from 'react';
import { Check, Users, Plane, Home, User, Truck, FileText, Loader2, AlertCircle, Info, CheckCircle2 } from 'lucide-react';
import { STEPS } from '@/lib/umrah/constants';
import { cn } from '@/lib/utils';

const iconMap = {
  Users,
  Plane,
  Home,
  Truck,
  User,
  FileText,
};

interface StepProgressProps {
  currentStep: number;
  completedSteps: number[];
  onStepClick: (stepId: number) => void;
  steps?: Array<{
    id: number;
    title: string;
    description: string;
    icon: string;
  }>;
}

export const StepProgress: React.FC<StepProgressProps> = ({
  currentStep,
  completedSteps,
  onStepClick,
  steps = STEPS,
}) => {
  return (
    <div className="mb-12">
      <div className="overflow-x-auto -mx-4 px-4 lg:mx-0 lg:px-0 scrollbar-hide">
        <div className="flex items-start justify-between min-w-max lg:min-w-0 relative px-2">
          {/* Background Connecting Line */}
          <div className="absolute top-6 left-0 w-full h-[2px] bg-secondary/10 z-0" />
          
          {steps.map((step, index) => {
            const Icon = iconMap[step.icon as keyof typeof iconMap];
            const isCompleted = completedSteps.includes(step.id);
            const isCurrent = currentStep === step.id;
            const isAccessible = step.id <= currentStep || completedSteps.includes(step.id);
            
            return (
              <div key={step.id} className="flex flex-col items-center relative z-10 flex-1 group">
                {/* Active Connecting Line Segment */}
                {index > 0 && (
                  <div className={cn(
                    "absolute top-6 right-1/2 w-full h-[2px] -z-10 transition-all duration-700",
                    isCompleted || isCurrent ? "bg-primary" : "bg-transparent"
                  )} />
                )}
                
                <button
                  onClick={() => onStepClick(step.id)}
                  disabled={!isAccessible}
                  className={cn(
                    "w-12 h-12 rounded-2xl flex items-center justify-center border-2 transition-all duration-500 shadow-xl",
                    isCompleted
                      ? "bg-primary border-primary text-white scale-110 shadow-primary/20"
                      : isCurrent
                      ? "bg-secondary border-secondary text-primary scale-110 shadow-secondary/30 ring-4 ring-secondary/10"
                      : isAccessible
                      ? "bg-white border-secondary/20 text-secondary hover:border-primary hover:text-primary"
                      : "bg-muted/50 border-muted text-muted-foreground cursor-not-allowed"
                  )}
                >
                  {isCompleted ? (
                    <Check className="h-6 w-6 stroke-[3px]" />
                  ) : (
                    <Icon className={cn("h-5 w-5", isCurrent ? "animate-pulse" : "")} />
                  )}
                </button>
                
                <div className="mt-4 text-center max-w-[120px]">
                  <p className={cn(
                    "text-[9px] font-black uppercase tracking-[0.2em] mb-1 transition-colors duration-500",
                    isCurrent ? "text-secondary" : isCompleted ? "text-primary" : "text-muted-foreground"
                  )}>
                    Phase 0{index + 1}
                  </p>
                  <p className={cn(
                    "text-[11px] font-black leading-tight uppercase tracking-tight transition-colors duration-500",
                    isCurrent ? "text-primary" : "text-muted-foreground group-hover:text-primary"
                  )}>
                    {step.title}
                  </p>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

interface ValidationMessageProps {
  message: string;
  type?: 'error' | 'warning' | 'info' | 'success';
}

export const ValidationMessage: React.FC<ValidationMessageProps> = ({
  message,
  type = 'error',
}) => {
  const configs = {
    error: {
      bg: 'bg-destructive/5',
      border: 'border-destructive/20',
      text: 'text-destructive',
      icon: AlertCircle
    },
    warning: {
      bg: 'bg-orange-50',
      border: 'border-orange-200',
      text: 'text-orange-700',
      icon: AlertCircle
    },
    info: {
      bg: 'bg-primary/5',
      border: 'border-primary/10',
      text: 'text-primary',
      icon: Info
    },
    success: {
      bg: 'bg-emerald-50',
      border: 'border-emerald-200',
      text: 'text-emerald-700',
      icon: CheckCircle2
    }
  };

  const config = configs[type];
  const Icon = config.icon;

  return (
    <div className={cn(
      "p-4 rounded-2xl border flex items-center gap-3 animate-in fade-in slide-in-from-top-2 duration-500",
      config.bg, config.border, config.text
    )}>
      <Icon className="h-5 w-5 flex-shrink-0" />
      <p className="text-xs font-black uppercase tracking-wide leading-tight">{message}</p>
    </div>
  );
};

interface DocumentUploadProps {
  label: string;
  required?: boolean;
  accept?: string;
  file: File | null;
  onChange: (file: File | null) => void;
  disabled?: boolean;
}

export const DocumentUpload: React.FC<DocumentUploadProps> = ({
  label,
  required = false,
  accept = 'image/*,.pdf',
  file,
  onChange,
  disabled = false,
}) => {
  return (
    <div className="space-y-3">
      <label className="text-[10px] font-black text-primary/40 uppercase tracking-[0.2em] ml-1">
        {label} {required && <span className="text-destructive">*</span>}
      </label>
      <div className={cn(
        "relative group transition-all duration-500",
        file ? "ring-2 ring-emerald-500/20" : "hover:ring-2 hover:ring-primary/10"
      )}>
        <input
          type="file"
          accept={accept}
          onChange={(e) => onChange(e.target.files?.[0] || null)}
          disabled={disabled}
          className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10 disabled:cursor-not-allowed"
        />
        <div className={cn(
          "flex items-center justify-between px-6 py-5 border-2 border-dashed rounded-3xl transition-all duration-500",
          file 
            ? "bg-emerald-50/30 border-emerald-500/30 shadow-xl shadow-emerald-500/5" 
            : "bg-gray-50/50 border-gray-200 group-hover:bg-white group-hover:border-primary/30 group-hover:shadow-2xl group-hover:shadow-primary/5"
        )}>
          <div className="flex items-center gap-4">
            <div className={cn(
              "h-12 w-12 rounded-2xl flex items-center justify-center transition-all duration-500",
              file ? "bg-emerald-500 text-white shadow-lg shadow-emerald-500/30" : "bg-white text-gray-300 group-hover:text-primary shadow-sm"
            )}>
              <FileText className="h-6 w-6" />
            </div>
            <div>
              <p className={cn(
                "text-sm font-black tracking-tight truncate max-w-[200px] uppercase",
                file ? "text-emerald-700" : "text-primary/60"
              )}>
                {file ? file.name : "Initialize Upload"}
              </p>
              <p className="text-[10px] font-bold text-muted-foreground uppercase tracking-widest mt-0.5">
                {file ? (file.size / 1024 / 1024).toFixed(2) + " MB" : "PDF / Image Map"}
              </p>
            </div>
          </div>
          <div className={cn(
            "px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-[0.2em] transition-all",
            file 
              ? "bg-white text-emerald-600 shadow-sm border border-emerald-100" 
              : "bg-primary text-white shadow-lg shadow-primary/20 group-hover:bg-secondary group-hover:text-primary group-hover:shadow-secondary/20"
          )}>
            {file ? "Replace" : "Browse"}
          </div>
        </div>
      </div>
    </div>
  );
};

interface LoadingSpinnerProps {
  message?: string;
}

export const LoadingSpinner: React.FC<LoadingSpinnerProps> = ({
  message = 'Synchronizing...',
}) => {
  return (
    <div className="min-h-screen bg-background flex flex-col items-center justify-center gap-8">
      <div className="relative">
        <div className="h-24 w-24 rounded-3xl bg-white shadow-2xl flex items-center justify-center animate-pulse">
          <Loader2 className="h-10 w-10 text-primary animate-spin" />
        </div>
        <div className="absolute -bottom-2 -right-2 h-8 w-8 rounded-xl bg-secondary flex items-center justify-center text-primary shadow-lg border-2 border-white">
          <Check className="h-4 w-4 stroke-[3px]" />
        </div>
      </div>
      <div className="text-center space-y-2">
        <p className="text-sm font-black text-primary uppercase tracking-[0.3em] animate-pulse">{message}</p>
        <div className="h-1 w-24 bg-secondary/20 rounded-full mx-auto overflow-hidden">
          <div className="h-full bg-secondary w-1/2 animate-[shimmer_2s_infinite]" />
        </div>
      </div>
    </div>
  );
};
