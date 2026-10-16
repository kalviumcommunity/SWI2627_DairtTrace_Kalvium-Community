import type { ReactNode } from "react";

export type ReusableWidgetTone = "default" | "success" | "warning" | "danger";

export type ReusableWidgetProps = {
  title?: string;
  description?: string;
  actions?: ReactNode;
  children: ReactNode;
  className?: string;
  tone?: ReusableWidgetTone;
};

const toneClasses: Record<ReusableWidgetTone, string> = {
  default: "border-slate-200 bg-white",
  success: "border-emerald-200 bg-emerald-50",
  warning: "border-amber-200 bg-amber-50",
  danger: "border-rose-200 bg-rose-50",
};

export function ReusableWidget({
  title,
  description,
  actions,
  children,
  className = "",
  tone = "default",
}: ReusableWidgetProps) {
  return (
    <section
      data-testid="reusable-widget"
      className={`rounded-xl border p-5 shadow-sm ${toneClasses[tone]} ${className}`.trim()}
    >
      {(title || description || actions) && (
        <header className="mb-4 flex items-start justify-between gap-4">
          <div>
            {title && (
              <h2 className="text-lg font-semibold text-slate-900">{title}</h2>
            )}
            {description && (
              <p className="mt-1 text-sm text-slate-600">{description}</p>
            )}
          </div>
          {actions && <div className="shrink-0">{actions}</div>}
        </header>
      )}
      <div>{children}</div>
    </section>
  );
}
