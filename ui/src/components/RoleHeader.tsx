'use client';

import React from 'react';
import { ShieldCheck, Wrench, HardHat, LogIn } from 'lucide-react';
import { UserRole, SystemNotification } from '../types';

interface RoleHeaderProps {
  currentRole: UserRole;
  onChangeRole: (role: UserRole) => void;
  notifications?: SystemNotification[];
  onOpenQR?: () => void;
  onOpenLogin?: () => void;
  currentUserEmail?: string;
}

export const RoleHeader: React.FC<RoleHeaderProps> = ({
  currentRole,
  onChangeRole,
  onOpenLogin,
  currentUserEmail,
}) => {
  return (
    <div className="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-slate-200/80 p-2 shadow-xs">
      {/* Top Header Row: Clean Logo & User Account Button */}
      <div className="flex items-center justify-between mb-1.5">
        <div className="flex items-center gap-2">
          <div className="w-7 h-7 rounded-lg bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center text-white font-black text-xs shadow-xs">
            AT
          </div>
          <div>
            <h1 className="text-xs font-extrabold text-slate-900 tracking-tight leading-none">AssetTrack Mobile</h1>
            <p className="text-[10px] text-slate-500 font-medium leading-tight mt-0.5">Hệ Thống Lý Lịch & Bảo Trì Máy</p>
          </div>
        </div>

        {/* User Account / Login Button */}
        <div className="flex items-center gap-1.5">
          {onOpenLogin && (
            <button
              onClick={onOpenLogin}
              className="px-2.5 py-1 rounded-lg bg-amber-50 hover:bg-amber-100 text-amber-800 border border-amber-200 transition flex items-center gap-1 text-[11px] font-extrabold shadow-xs"
              title="Đăng Nhập / Chuyển Tài Khoản"
            >
              <LogIn className="w-3.5 h-3.5 text-amber-600" />
              <span>{currentUserEmail ? currentUserEmail.split('@')[0] : 'Đăng Nhập'}</span>
            </button>
          )}
        </div>
      </div>

      {/* User Role Profile Bar when Logged In */}
      {currentUserEmail ? (
        <div className="flex items-center justify-between gap-1.5 bg-slate-50 p-1.5 px-2 rounded-lg border border-slate-200 text-xs font-bold min-w-0">
          <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden">
            {currentRole === 'OPERATOR' && (
              <span className="inline-flex items-center gap-1 text-emerald-800 font-extrabold text-[11px] shrink-0">
                <HardHat className="w-3.5 h-3.5 text-emerald-600" />
                <span>Công Nhân:</span>
              </span>
            )}
            {currentRole === 'ME_ENGINEER' && (
              <span className="inline-flex items-center gap-1 text-sky-800 font-extrabold text-[11px] shrink-0">
                <Wrench className="w-3.5 h-3.5 text-sky-600" />
                <span>Kỹ Sư ME:</span>
              </span>
            )}
            {currentRole === 'SUPERVISOR' && (
              <span className="inline-flex items-center gap-1 text-amber-800 font-extrabold text-[11px] shrink-0">
                <ShieldCheck className="w-3.5 h-3.5 text-amber-600" />
                <span>Quản Đốc Phân Xưởng:</span>
              </span>
            )}
            <span className="text-slate-900 font-mono text-[11px] font-bold truncate flex-1 min-w-0" title={currentUserEmail}>
              {currentUserEmail}
            </span>
          </div>

          {onOpenLogin && (
            <button
              onClick={onOpenLogin}
              className="text-[10px] text-slate-500 hover:text-rose-600 underline font-semibold transition shrink-0 ml-1"
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
