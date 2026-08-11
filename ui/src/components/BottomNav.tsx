'use client';

import React from 'react';
import { Home, QrCode, ClipboardList, Cpu, Bell } from 'lucide-react';
import { sound } from '@/lib/soundEffects';

export type BottomNavTab = 'HOME' | 'SCANNER' | 'TASKS' | 'MACHINES' | 'NOTIFICATIONS';

interface BottomNavProps {
  activeTab: BottomNavTab;
  onChangeTab: (tab: BottomNavTab) => void;
  pendingTasksCount: number;
  unreadNotificationsCount?: number;
}

export const BottomNav: React.FC<BottomNavProps> = ({
  activeTab,
  onChangeTab,
  pendingTasksCount,
  unreadNotificationsCount = 0,
}) => {
  return (
    <div className="sticky bottom-0 inset-x-0 z-30 bg-white/95 backdrop-blur-xl border-t border-slate-200/90 px-2 py-1 shadow-lg">
      <div className="w-full flex items-center justify-around">

        {/* 1. Trang Chủ */}
        <button
          onClick={() => {
            sound.playClick();
            onChangeTab('HOME');
          }}
          className={`flex flex-col items-center gap-0.5 py-1 px-2 rounded-lg transition ${
            activeTab === 'HOME'
              ? 'text-emerald-700 font-bold'
              : 'text-slate-500 hover:text-slate-900'
          }`}
        >
          <Home className={`w-5 h-5 ${activeTab === 'HOME' ? 'stroke-[2.5]' : 'stroke-2'}`} />
          <span className="text-[10px]">Trang Chủ</span>
        </button>

        {/* 2. Máy Móc */}
        <button
          onClick={() => {
            sound.playClick();
            onChangeTab('MACHINES');
          }}
          className={`flex flex-col items-center gap-0.5 py-1 px-2 rounded-lg transition ${
            activeTab === 'MACHINES'
              ? 'text-emerald-700 font-bold'
              : 'text-slate-500 hover:text-slate-900'
          }`}
        >
          <Cpu className={`w-5 h-5 ${activeTab === 'MACHINES' ? 'stroke-[2.5]' : 'stroke-2'}`} />
          <span className="text-[10px]">Máy Móc</span>
        </button>

        {/* 3. NÚT QUÉT QR NỔI BẬT Ở CHÍNH GIỮA (NÚT MÀU XANH NỔI LÊN CAO) */}
        <div className="-mt-6 relative z-20 flex flex-col items-center">
          <button
            onClick={() => {
              sound.playClick();
              onChangeTab('SCANNER');
            }}
            className="w-13 h-13 rounded-full bg-gradient-to-tr from-emerald-600 via-emerald-500 to-teal-400 text-white shadow-xl shadow-emerald-600/40 border-3 border-white flex items-center justify-center active:scale-90 hover:scale-105 transition-all duration-200 group"
            title="Quét Mã QR Thiết Bị"
          >
            <QrCode className="w-6 h-6 stroke-[2.3] text-white drop-shadow-xs group-hover:rotate-12 transition-transform duration-200" />
          </button>
          <span className="text-[10px] font-black text-emerald-700 mt-0.5 tracking-tight">
            Quét QR
          </span>
        </div>

        {/* 4. Nhiệm Vụ */}
        <button
          onClick={() => {
            sound.playClick();
            onChangeTab('TASKS');
          }}
          className={`relative flex flex-col items-center gap-0.5 py-1 px-2 rounded-lg transition ${
            activeTab === 'TASKS'
              ? 'text-emerald-700 font-bold'
              : 'text-slate-500 hover:text-slate-900'
          }`}
        >
          <ClipboardList className={`w-5 h-5 ${activeTab === 'TASKS' ? 'stroke-[2.5]' : 'stroke-2'}`} />
          <span className="text-[10px]">Nhiệm Vụ</span>
          {pendingTasksCount > 0 && (
            <span className="absolute -top-0.5 right-1 min-w-[15px] h-[15px] px-1 rounded-full bg-rose-500 text-white font-black text-[8px] flex items-center justify-center shadow-xs">
              {pendingTasksCount}
            </span>
          )}
        </button>

        {/* 5. Thông Báo (Được đẩy xuống dưới thanh điều hướng) */}
        <button
          onClick={() => {
            sound.playClick();
            onChangeTab('NOTIFICATIONS');
          }}
          className={`relative flex flex-col items-center gap-0.5 py-1 px-2 rounded-lg transition ${
            activeTab === 'NOTIFICATIONS'
              ? 'text-emerald-700 font-bold'
              : 'text-slate-500 hover:text-slate-900'
          }`}
        >
          <Bell className={`w-5 h-5 ${activeTab === 'NOTIFICATIONS' ? 'stroke-[2.5]' : 'stroke-2'}`} />
          <span className="text-[10px]">Thông Báo</span>
          {unreadNotificationsCount > 0 && (
            <span className="absolute -top-0.5 right-1 min-w-[15px] h-[15px] px-1 rounded-full bg-rose-500 text-white font-black text-[8px] flex items-center justify-center shadow-xs animate-bounce">
              {unreadNotificationsCount}
            </span>
          )}
        </button>

      </div>
    </div>
  );
};
