'use client';

import React, { useState } from 'react';
import { X, Lock, Mail, LogIn, Phone, CheckSquare, Square, ShieldCheck, HardHat, Wrench, Shield } from 'lucide-react';
import { UserRole } from '../types';

interface LoginModalProps {
  isOpen: boolean;
  onClose: () => void;
  onLoginSuccess: (role: UserRole, userEmail: string) => void;
}

export const LoginModal: React.FC<LoginModalProps> = ({
  isOpen,
  onClose,
  onLoginSuccess,
}) => {
  const [email, setEmail] = useState('supervisor.a@factory.com');
  const [password, setPassword] = useState('12345678');
  const [rememberMe, setRememberMe] = useState(true);

  if (!isOpen) return null;

  // Auto detect role based on email input
  const detectRoleFromEmail = (inputEmail: string): UserRole => {
    const lower = inputEmail.toLowerCase();
    if (lower.includes('me') || lower.includes('engineer') || lower.includes('ky-su')) {
      return 'ME_ENGINEER';
    }
    if (lower.includes('operator') || lower.includes('cong-nhan') || lower.includes('worker')) {
      return 'OPERATOR';
    }
    return 'SUPERVISOR'; // Default / Supervisor
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim() || !password.trim()) {
      alert('Vui lòng nhập đầy đủ Email/Mã nhân viên và Mật khẩu!');
      return;
    }

    const detectedRole = detectRoleFromEmail(email);
    onLoginSuccess(detectedRole, email.trim());
    onClose();
  };

  const handleSelectQuickAccount = (quickEmail: string) => {
    setEmail(quickEmail);
    setPassword('12345678');
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/70 backdrop-blur-sm p-4 animate-in fade-in duration-200">
      <div className="w-full max-w-sm bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">

        {/* Top Header Branding (Wireframe K) */}
        <div className="p-6 bg-gradient-to-br from-emerald-600 via-teal-700 to-slate-900 text-white text-center relative">
          <button
            onClick={onClose}
            className="absolute top-3 right-3 p-1.5 rounded-full text-emerald-100 hover:text-white hover:bg-white/20 transition"
          >
            <X className="w-5 h-5" />
          </button>

          <div className="w-12 h-12 rounded-2xl bg-white/20 backdrop-blur-md mx-auto mb-2 flex items-center justify-center text-white font-black text-xl border border-white/30 shadow-md">
            AT
          </div>
          <h1 className="text-xl font-black tracking-wider uppercase text-white">ASSETTRACK</h1>
          <p className="text-xs text-emerald-100 font-medium leading-snug mt-1 max-w-[240px] mx-auto">
            Hệ thống Quản lý Lý lịch & Bảo trì Nhà máy
          </p>
        </div>

        {/* Login Form (Wireframe K) */}
        <form onSubmit={handleSubmit} className="p-5 space-y-4">

          {/* Email / Employee ID Field */}
          <div>
            <label className="text-xs font-bold text-slate-800 block mb-1.5">
              Email / Mã nhân viên
            </label>
            <div className="relative">
              <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
              <input
                type="text"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="supervisor.a@factory.com"
                className="w-full bg-slate-50 border border-slate-300 rounded-xl pl-9 pr-3 py-2.5 text-xs font-bold text-slate-900 focus:outline-none focus:border-emerald-600 focus:bg-white transition"
                required
              />
            </div>
          </div>

          {/* Password Field */}
          <div>
            <label className="text-xs font-bold text-slate-800 block mb-1.5">
              Mật khẩu
            </label>
            <div className="relative">
              <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••"
                className="w-full bg-slate-50 border border-slate-300 rounded-xl pl-9 pr-3 py-2.5 text-xs font-bold text-slate-900 focus:outline-none focus:border-emerald-600 focus:bg-white transition"
                required
              />
            </div>
          </div>

          {/* Checkbox Remember Me (Wireframe K) */}
          <div className="flex items-center justify-between text-xs pt-0.5">
            <button
              type="button"
              onClick={() => setRememberMe(!rememberMe)}
              className="flex items-center gap-2 text-slate-700 hover:text-slate-900 select-none font-medium"
            >
              {rememberMe ? (
                <CheckSquare className="w-4 h-4 text-emerald-600" />
              ) : (
                <Square className="w-4 h-4 text-slate-400" />
              )}
              <span>Ghi nhớ đăng nhập</span>
            </button>
            <span className="text-[10px] text-slate-400 font-mono">v1.2.0</span>
          </div>

          {/* Login Submit Button (Wireframe K) */}
          <button
            type="submit"
            className="w-full py-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-black uppercase tracking-wider shadow-lg shadow-emerald-600/30 transition flex items-center justify-center gap-2"
          >
            <LogIn className="w-4 h-4" /> ĐĂNG NHẬP
          </button>

          {/* Quick Account Shortcuts for Demo */}
          <div className="pt-2 border-t border-slate-100">
            <span className="text-[10px] font-bold text-slate-400 uppercase block text-center mb-2">
              Chọn nhanh tài khoản test demo:
            </span>
            <div className="grid grid-cols-3 gap-1.5">
              <button
                type="button"
                onClick={() => handleSelectQuickAccount('operator.an@factory.com')}
                className="p-1.5 rounded-lg bg-slate-100 hover:bg-emerald-50 hover:text-emerald-700 text-slate-700 text-[10px] font-bold border border-slate-200 transition flex items-center justify-center gap-1"
              >
                <HardHat className="w-3 h-3 text-emerald-600" /> Công Nhân
              </button>
              <button
                type="button"
                onClick={() => handleSelectQuickAccount('me.duc@factory.com')}
                className="p-1.5 rounded-lg bg-slate-100 hover:bg-sky-50 hover:text-sky-700 text-slate-700 text-[10px] font-bold border border-slate-200 transition flex items-center justify-center gap-1"
              >
                <Wrench className="w-3 h-3 text-sky-600" /> Kỹ Sư ME
              </button>
              <button
                type="button"
                onClick={() => handleSelectQuickAccount('supervisor.a@factory.com')}
                className="p-1.5 rounded-lg bg-slate-100 hover:bg-amber-50 hover:text-amber-700 text-slate-700 text-[10px] font-bold border border-slate-200 transition flex items-center justify-center gap-1"
              >
                <ShieldCheck className="w-3 h-3 text-amber-600" /> Quản Đốc
              </button>
            </div>
          </div>

        </form>

        {/* Technical Support Footer (Wireframe K) */}
        <div className="p-3 bg-slate-50 border-t border-slate-200 text-center text-[11px] text-slate-500 font-medium flex items-center justify-center gap-1.5">
          <Phone className="w-3.5 h-3.5 text-slate-400" />
          <span>Hỗ trợ kỹ thuật: <strong className="text-slate-800 font-bold">1900-8888</strong></span>
        </div>

      </div>
    </div>
  );
};
