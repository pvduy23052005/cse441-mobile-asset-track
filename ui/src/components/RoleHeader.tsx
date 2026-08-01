'use client';

import React, { useState } from 'react';
import { Bell, QrCode, ShieldCheck, Wrench, HardHat, LogIn, User } from 'lucide-react';
import { UserRole, SystemNotification } from '../types';

interface RoleHeaderProps {
  currentRole: UserRole;
  onChangeRole: (role: UserRole) => void;
  notifications: SystemNotification[];
  onOpenQR: () => void;
  onOpenLogin?: () => void;
  currentUserEmail?: string;
}

export const RoleHeader: React.FC<RoleHeaderProps> = ({
  currentRole,
  onChangeRole,
  notifications,
  onOpenQR,
  onOpenLogin,
  currentUserEmail,
}) => {
  const [showNotifications, setShowNotifications] = useState(false);
  const unreadCount = notifications.filter((n) => !n.read).length;

  return (
    <div className="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-slate-200/80 p-2 shadow-xs">
      {/* Top Header Row */}
      <div className="flex items-center justify-between mb-1.5">
        <div className="flex items-center gap-2">
          <div className="w-7 h-7 rounded bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center text-white font-black text-xs shadow-xs">
            AT
          </div>
          <div>
            <h1 className="text-xs font-extrabold text-slate-900 tracking-tight leading-none">AssetTrack Mobile</h1>
            <p className="text-[10px] text-slate-500 font-medium leading-tight mt-0.5">Hệ Thống Lý Lịch & Bảo Trì Máy</p>
          </div>
        </div>

        {/* Quick QR, Login & Notification Bell */}
        <div className="flex items-center gap-1.5">
          {onOpenLogin && (
            <button
              onClick={onOpenLogin}
              className="px-2 py-1 rounded bg-amber-50 hover:bg-amber-100 text-amber-800 border border-amber-200 transition flex items-center gap-1 text-[10px] font-extrabold shadow-xs"
              title="Đăng Nhập / Chuyển Tài Khoản"
            >
              <LogIn className="w-3.5 h-3.5 text-amber-600" />
              <span>{currentUserEmail ? currentUserEmail.split('@')[0] : 'Đăng Nhập'}</span>
            </button>
          )}

          <button
            onClick={onOpenQR}
            className="px-2.5 py-1 rounded bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border border-emerald-200/80 transition flex items-center gap-1 text-[11px] font-bold shadow-xs"
          >
            <QrCode className="w-3.5 h-3.5 text-emerald-600" />
            <span>Quét QR</span>
          </button>

          <div className="relative">
            <button
              onClick={() => setShowNotifications(!showNotifications)}
              className="relative p-1.5 rounded bg-slate-100 hover:bg-slate-200/80 text-slate-700 border border-slate-200 transition"
            >
              <Bell className="w-3.5 h-3.5" />
              {unreadCount > 0 && (
                <span className="absolute -top-1 -right-1 w-3.5 h-3.5 rounded-full bg-rose-500 text-white font-bold text-[8px] flex items-center justify-center animate-bounce shadow-xs">
                  {unreadCount}
                </span>
              )}
            </button>

            {/* Notification Dropdown */}
            {showNotifications && (
              <div className="absolute right-0 mt-2 w-72 bg-white border border-slate-200 rounded-md shadow-xl p-3 z-50 animate-in fade-in duration-150">
                <div className="flex items-center justify-between border-b border-slate-100 pb-1.5 mb-1.5">
                  <span className="text-[11px] font-bold text-slate-800">Thông Báo Thời Gian Thực</span>
                  <span className="text-[9px] text-emerald-600 font-mono font-bold bg-emerald-50 px-1.5 py-0.5 rounded">Realtime</span>
                </div>
                <div className="space-y-1.5 max-h-60 overflow-y-auto">
                  {notifications.map((n) => (
                    <div key={n.id} className="p-2 rounded bg-slate-50 border border-slate-150 text-[11px]">
                      <div className="flex items-center justify-between mb-0.5">
                        <span className="font-bold text-rose-600 text-[10px]">{n.title}</span>
                        <span className="text-[9px] text-slate-400">{n.timestamp}</span>
                      </div>
                      <p className="text-slate-600 text-[10px] leading-snug">{n.message}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* User Role Profile Bar when Logged In */}
      {currentUserEmail ? (
        <div className="flex items-center justify-between bg-slate-50 p-1.5 px-2.5 rounded-lg border border-slate-200 text-xs font-bold">
          <div className="flex items-center gap-2">
            {currentRole === 'OPERATOR' && (
              <span className="inline-flex items-center gap-1 text-emerald-800 font-extrabold text-[11px]">
                <HardHat className="w-3.5 h-3.5 text-emerald-600" />
                <span>Công Nhân Vận Hành:</span>
              </span>
            )}
            {currentRole === 'ME_ENGINEER' && (
              <span className="inline-flex items-center gap-1 text-sky-800 font-extrabold text-[11px]">
                <Wrench className="w-3.5 h-3.5 text-sky-600" />
                <span>Kỹ Sư Cơ Điện (ME):</span>
              </span>
            )}
            {currentRole === 'SUPERVISOR' && (
              <span className="inline-flex items-center gap-1 text-amber-800 font-extrabold text-[11px]">
                <ShieldCheck className="w-3.5 h-3.5 text-amber-600" />
                <span>Quản Đốc Phân Xưởng:</span>
              </span>
            )}
            <span className="text-slate-900 font-mono text-[11px] font-bold">{currentUserEmail}</span>
          </div>

          {onOpenLogin && (
            <button
              onClick={onOpenLogin}
              className="text-[10px] text-slate-500 hover:text-rose-600 underline font-semibold transition"
            >
              [Đổi Tài Khoản]
            </button>
          )}
        </div>
      ) : (
        /* Demo Role Switcher (Chỉ hiện khi chưa đăng nhập) */
        <div className="flex bg-slate-100 p-0.5 rounded-md border border-slate-200/80">
          {(['OPERATOR', 'ME_ENGINEER', 'SUPERVISOR'] as UserRole[]).map((r) => {
            const isSelected = currentRole === r;
            let label = 'Công Nhân';
            if (r === 'ME_ENGINEER') label = 'Kỹ Sư ME';
            if (r === 'SUPERVISOR') label = 'Quản Đốc';

            return (
              <button
                key={r}
                onClick={() => onChangeRole(r)}
                className={`flex-1 py-1 px-1.5 rounded text-[11px] font-extrabold transition flex items-center justify-center gap-1 ${
                  isSelected
                    ? 'bg-white text-emerald-700 shadow-xs border border-slate-200'
                    : 'text-slate-500 hover:text-slate-900'
                }`}
              >
                {label}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
};
