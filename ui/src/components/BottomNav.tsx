'use client';

import React from 'react';
import { Home, QrCode, ClipboardList, Cpu } from 'lucide-react';

interface BottomNavProps {
  activeTab: 'HOME' | 'SCANNER' | 'TASKS' | 'MACHINES';
  onChangeTab: (tab: 'HOME' | 'SCANNER' | 'TASKS' | 'MACHINES') => void;
  pendingTasksCount: number;
}

export const BottomNav: React.FC<BottomNavProps> = ({
  activeTab,
  onChangeTab,
  pendingTasksCount,
}) => {
  return (
    <div className="fixed bottom-0 inset-x-0 z-40 bg-white/95 backdrop-blur-lg border-t border-slate-200/90 px-4 py-2 shadow-lg">
      <div className="max-w-md mx-auto flex items-center justify-around">
        
        {/* Home Tab */}
        <button
          onClick={() => onChangeTab('HOME')}
          className={`flex flex-col items-center gap-1 transition ${
            activeTab === 'HOME' ? 'text-emerald-600 font-bold' : 'text-slate-400 hover:text-slate-700'
          }`}
        >
          <Home className="w-5 h-5" />
          <span className="text-[10px]">Trang Chủ</span>
        </button>

        {/* Machines Tab */}
        <button
          onClick={() => onChangeTab('MACHINES')}
          className={`flex flex-col items-center gap-1 transition ${
            activeTab === 'MACHINES' ? 'text-emerald-600 font-bold' : 'text-slate-400 hover:text-slate-700'
          }`}
        >
          <Cpu className="w-5 h-5" />
          <span className="text-[10px]">Máy Móc</span>
        </button>

        {/* Floating QR Scanner Button */}
        <button
          onClick={() => onChangeTab('SCANNER')}
          className="relative -top-4 w-12 h-12 rounded-full bg-gradient-to-tr from-emerald-500 to-teal-600 text-white flex items-center justify-center shadow-lg shadow-emerald-500/30 hover:scale-105 active:scale-95 transition"
        >
          <QrCode className="w-6 h-6 stroke-[2.5]" />
        </button>

        {/* Tasks Tab */}
        <button
          onClick={() => onChangeTab('TASKS')}
          className={`relative flex flex-col items-center gap-1 transition ${
            activeTab === 'TASKS' ? 'text-emerald-600 font-bold' : 'text-slate-400 hover:text-slate-700'
          }`}
        >
          <ClipboardList className="w-5 h-5" />
          <span className="text-[10px]">Nhiệm Vụ</span>
          {pendingTasksCount > 0 && (
            <span className="absolute -top-1 right-1 w-4 h-4 rounded-full bg-rose-500 text-white font-bold text-[9px] flex items-center justify-center shadow-xs">
              {pendingTasksCount}
            </span>
          )}
        </button>

      </div>
    </div>
  );
};
