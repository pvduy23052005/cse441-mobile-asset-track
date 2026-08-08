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
    <div className="sticky bottom-0 inset-x-0 z-30 bg-white/95 backdrop-blur-lg border-t border-slate-200/90 px-3 py-1.5 shadow-lg">
      <div className="w-full flex items-center justify-around">

        {/* Home Tab */}
        <button
          onClick={() => onChangeTab('HOME')}
          className={`flex flex-col items-center gap-0.5 transition ${activeTab === 'HOME' ? 'text-emerald-600 font-bold' : 'text-slate-400 hover:text-slate-700'
            }`}
        >
          <Home className="w-4 h-4" />
          <span className="text-[9px]">Trang Chủ</span>
        </button>

        {/* Machines Tab */}
        <button
          onClick={() => onChangeTab('MACHINES')}
          className={`flex flex-col items-center gap-0.5 transition ${activeTab === 'MACHINES' ? 'text-emerald-600 font-bold' : 'text-slate-400 hover:text-slate-700'
            }`}
        >
          <Cpu className="w-4 h-4" />
          <span className="text-[9px]">Máy Móc</span>
        </button>

        {/* QR Scanner Tab */}
        <button
          onClick={() => onChangeTab('SCANNER')}
          className={`flex flex-col items-center gap-0.5 transition ${
            activeTab === 'SCANNER' ? 'text-emerald-600 font-bold' : 'text-slate-400 hover:text-slate-700'
          }`}
        >
          <QrCode className="w-4 h-4" />
          <span className="text-[9px]">Quét QR</span>
        </button>

        {/* Tasks Tab */}
        <button
          onClick={() => onChangeTab('TASKS')}
          className={`relative flex flex-col items-center gap-0.5 transition ${activeTab === 'TASKS' ? 'text-emerald-600 font-bold' : 'text-slate-400 hover:text-slate-700'
            }`}
        >
          <ClipboardList className="w-4 h-4" />
          <span className="text-[9px]">Nhiệm Vụ</span>
          {pendingTasksCount > 0 && (
            <span className="absolute -top-1 right-1 w-3.5 h-3.5 rounded-full bg-rose-500 text-white font-bold text-[8px] flex items-center justify-center shadow-xs">
              {pendingTasksCount}
            </span>
          )}
        </button>

      </div>
    </div>
  );
};
