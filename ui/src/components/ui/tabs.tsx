'use client';

import * as React from "react";
import { cn } from "@/lib/utils";

interface TabsProps {
  defaultValue: string;
  value?: string;
  onValueChange?: (value: string) => void;
  children: React.ReactNode;
  className?: string;
}

const TabsContext = React.createContext<{
  selectedValue: string;
  setSelectedValue: (val: string) => void;
}>({
  selectedValue: "",
  setSelectedValue: () => {},
});

export function Tabs({ defaultValue, value, onValueChange, children, className }: TabsProps) {
  const [selected, setSelected] = React.useState(value || defaultValue);

  const currentVal = value !== undefined ? value : selected;

  const handleSelect = (val: string) => {
    if (value === undefined) {
      setSelected(val);
    }
    if (onValueChange) {
      onValueChange(val);
    }
  };

  return (
    <TabsContext.Provider value={{ selectedValue: currentVal, setSelectedValue: handleSelect }}>
      <div className={cn("w-full", className)}>{children}</div>
    </TabsContext.Provider>
  );
}

export function TabsList({ className, children }: { className?: string; children: React.ReactNode }) {
  return (
    <div className={cn("flex bg-slate-100 p-1 rounded-2xl border border-slate-200/80", className)}>
      {children}
    </div>
  );
}

export function TabsTrigger({
  value,
  children,
  className,
}: {
  value: string;
  children: React.ReactNode;
  className?: string;
}) {
  const { selectedValue, setSelectedValue } = React.useContext(TabsContext);
  const isSelected = selectedValue === value;

  return (
    <button
      type="button"
      onClick={() => setSelectedValue(value)}
      className={cn(
        "flex-1 py-1.5 px-2 rounded-xl text-xs font-extrabold transition-all flex items-center justify-center gap-1",
        isSelected
          ? "bg-white text-emerald-700 shadow-sm border border-slate-200"
          : "text-slate-500 hover:text-slate-900",
        className
      )}
    >
      {children}
    </button>
  );
}

export function TabsContent({
  value,
  children,
  className,
}: {
  value: string;
  children: React.ReactNode;
  className?: string;
}) {
  const { selectedValue } = React.useContext(TabsContext);
  if (selectedValue !== value) return null;

  return <div className={cn("mt-2 animate-in fade-in-50 duration-150", className)}>{children}</div>;
}
