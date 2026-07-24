import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded text-xs font-bold transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 disabled:pointer-events-none disabled:opacity-50 active:scale-95 shadow-xs",
  {
    variants: {
      variant: {
        default:
          "bg-emerald-600 text-white hover:bg-emerald-700 shadow-emerald-600/20",
        destructive:
          "bg-rose-600 text-white hover:bg-rose-700 shadow-rose-600/20",
        outline:
          "border border-slate-200 bg-white text-slate-800 hover:bg-slate-100 hover:text-slate-900",
        secondary:
          "bg-slate-100 text-slate-900 hover:bg-slate-200/80 border border-slate-200/80",
        amber:
          "bg-amber-500 text-white hover:bg-amber-600 shadow-amber-500/20",
        cyan:
          "bg-cyan-600 text-white hover:bg-cyan-700 shadow-cyan-600/20",
        ghost: "hover:bg-slate-100 text-slate-700 hover:text-slate-900",
        link: "text-emerald-700 underline-offset-4 hover:underline p-0 shadow-none",
      },
      size: {
        default: "h-9 px-4 py-2",
        sm: "h-8 rounded-sm px-3 text-[11px]",
        lg: "h-11 rounded-md px-6 text-sm",
        icon: "h-9 w-9 p-0 rounded",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);
Button.displayName = "Button";

export { Button, buttonVariants };
