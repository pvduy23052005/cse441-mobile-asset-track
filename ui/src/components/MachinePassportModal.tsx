'use client';

import React, { useState } from 'react';
import { X, Clock, AlertTriangle, Cpu, Wrench, ChevronDown, CheckCircle2, PlusCircle, Calendar, ShieldCheck } from 'lucide-react';
import { Machine } from '../types';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';

interface MachinePassportModalProps {
  machine: Machine | null;
  isOpen: boolean;
  onClose: () => void;
  onUpdateHours: (machineId: string, newHours: number, shift: 'START_SHIFT' | 'END_SHIFT') => void;
  onOpenSOS: (machine: Machine) => void;
}

export const MachinePassportModal: React.FC<MachinePassportModalProps> = ({
  machine,
  isOpen,
  onClose,
  onUpdateHours,
  onOpenSOS,
}) => {
  const [activeTab, setActiveTab] = useState<'SPECS' | 'TROUBLESHOOT' | 'HISTORY'>('SPECS');
  const [showHoursPopup, setShowHoursPopup] = useState(false);
  const [inputHours, setInputHours] = useState('');
  const [shift, setShift] = useState<'START_SHIFT' | 'END_SHIFT'>('END_SHIFT');
  const [openTroubleshootIdx, setOpenTroubleshootIdx] = useState<number | null>(0);

  if (!isOpen || !machine) return null;

  const handleHoursSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const val = parseFloat(inputHours);
    if (!isNaN(val) && val > machine.runningHours) {
      onUpdateHours(machine.id, val, shift);
      setShowHoursPopup(false);
      setInputHours('');
    } else {
      alert(`Số giờ máy chạy phải là số dương LỚN HƠN chỉ số lần trước (${machine.runningHours}h)`);
    }
  };

  const remainingHours = machine.nextMaintenanceHours - machine.runningHours;
  const isNearMaintenance = remainingHours > 0 && remainingHours <= machine.nextMaintenanceHours * 0.1;
  const isOverdue = remainingHours <= 0;

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'ACTIVE':
        return <Badge variant="active">● Hoạt Động</Badge>;
      case 'REPAIRING':
        return <Badge variant="repairing">● Sửa Chữa (SOS)</Badge>;
      case 'MAINTENANCE':
        return <Badge variant="maintenance">● Bảo Trì PM</Badge>;
      default:
        return <Badge variant="secondary">● Ngừng</Badge>;
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-slate-900/60 backdrop-blur-sm p-0 sm:p-4">
      <div className="w-full max-w-md bg-white border border-slate-200 rounded-t-3xl sm:rounded-3xl max-h-[90vh] flex flex-col shadow-2xl animate-in slide-in-from-bottom duration-300">
        
        {/* Header */}
        <div className="p-5 border-b border-slate-100 bg-slate-50/60 flex items-start justify-between">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className="px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 font-mono text-xs font-extrabold border border-emerald-200">
                {machine.code}
              </span>
              {getStatusBadge(machine.status)}
            </div>
            <h2 className="text-lg font-extrabold text-slate-900">{machine.name}</h2>
            <p className="text-xs text-slate-500 font-medium">{machine.location}</p>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-200/60 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Running hours quick bar */}
        <div className="mx-5 my-3 p-3.5 rounded-2xl bg-gradient-to-r from-emerald-50 to-teal-50 border border-emerald-200/80 flex items-center justify-between shadow-xs">
          <div>
            <div className="text-[11px] text-slate-500 uppercase font-bold tracking-wider">Tổng Giờ Máy Chạy</div>
            <div className="text-2xl font-black font-mono text-emerald-700 flex items-baseline gap-1">
              {machine.runningHours.toFixed(1)} <span className="text-xs text-slate-500 font-normal">Giờ</span>
            </div>
          </div>
          <Button
            size="sm"
            variant="default"
            onClick={() => setShowHoursPopup(true)}
            className="h-8 rounded-xl font-bold"
          >
            <PlusCircle className="w-3.5 h-3.5" /> Nhập Ca
          </Button>
        </div>

        {/* Hours Update Popup Form (US-02, 5.G) */}
        {showHoursPopup && (
          <form onSubmit={handleHoursSubmit} className="mx-5 mb-3 p-3 rounded-2xl bg-slate-50 border border-emerald-300 space-y-2">
            <div className="text-xs font-bold text-slate-800 flex items-center justify-between">
              <span>Nhập Số Giờ Chạy Hiện Tại</span>
              <span className="text-[11px] text-slate-500 font-mono">Trước: {machine.runningHours}h</span>
            </div>

            <div className="flex gap-2">
              <input
                type="number"
                step="0.1"
                placeholder={`Chỉ số mới (> ${machine.runningHours})`}
                value={inputHours}
                onChange={(e) => setInputHours(e.target.value)}
                className="flex-1 bg-white border border-slate-300 rounded-xl px-3 py-1.5 text-xs text-slate-900 font-bold focus:outline-none focus:border-emerald-500"
                required
              />
              <Button type="submit" size="sm" variant="default">
                Lưu
              </Button>
              <Button type="button" size="sm" variant="secondary" onClick={() => setShowHoursPopup(false)}>
                Hủy
              </Button>
            </div>

            {/* Shift Selector */}
            <div className="flex items-center gap-4 text-xs pt-1">
              <span className="text-slate-600 font-medium">Thời điểm ca:</span>
              <label className="flex items-center gap-1 cursor-pointer font-bold text-slate-700">
                <input
                  type="radio"
                  name="shift"
                  checked={shift === 'START_SHIFT'}
                  onChange={() => setShift('START_SHIFT')}
                />
                Đầu Ca
              </label>
              <label className="flex items-center gap-1 cursor-pointer font-bold text-slate-700">
                <input
                  type="radio"
                  name="shift"
                  checked={shift === 'END_SHIFT'}
                  onChange={() => setShift('END_SHIFT')}
                />
                Cuối Ca
              </label>
            </div>
          </form>
        )}

        {/* Navigation Tabs */}
        <div className="px-5 border-b border-slate-100 flex gap-4">
          <button
            onClick={() => setActiveTab('SPECS')}
            className={`pb-2.5 text-xs font-extrabold border-b-2 transition ${
              activeTab === 'SPECS'
                ? 'border-emerald-600 text-emerald-700'
                : 'border-transparent text-slate-400 hover:text-slate-700'
            }`}
          >
            Thông Số Kỹ Thuật
          </button>
          <button
            onClick={() => setActiveTab('TROUBLESHOOT')}
            className={`pb-2.5 text-xs font-extrabold border-b-2 transition ${
              activeTab === 'TROUBLESHOOT'
                ? 'border-emerald-600 text-emerald-700'
                : 'border-transparent text-slate-400 hover:text-slate-700'
            }`}
          >
            Cẩm Nang Lỗi Nhanh
          </button>
          <button
            onClick={() => setActiveTab('HISTORY')}
            className={`pb-2.5 text-xs font-extrabold border-b-2 transition ${
              activeTab === 'HISTORY'
                ? 'border-emerald-600 text-emerald-700'
                : 'border-transparent text-slate-400 hover:text-slate-700'
            }`}
          >
            Lịch Sử Bảo Trì
          </button>
        </div>

        {/* Tab Contents Scrollable */}
        <div className="p-5 overflow-y-auto flex-1 space-y-3">
          
          {activeTab === 'SPECS' && (
            <div className="space-y-2.5">
              <div className="grid grid-cols-2 gap-2 text-xs">
                <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                  <span className="text-slate-500 font-medium block mb-0.5">Công Suất</span>
                  <span className="font-bold text-slate-900">{machine.specifications.power}</span>
                </div>
                <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                  <span className="text-slate-500 font-medium block mb-0.5">Điện Áp Hoạt Động</span>
                  <span className="font-bold text-slate-900">{machine.specifications.voltage}</span>
                </div>
                <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                  <span className="text-slate-500 font-medium block mb-0.5">Hãng Sản Xuất</span>
                  <span className="font-bold text-slate-900">{machine.specifications.manufacturer}</span>
                </div>
                <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                  <span className="text-slate-500 font-medium block mb-0.5">Năm Sản Xuất</span>
                  <span className="font-bold text-slate-900">{machine.specifications.year}</span>
                </div>
              </div>

              {/* Maintenance ProgressBar with Warning colors */}
              <div className={`p-3.5 rounded-xl border mt-2 ${
                isOverdue ? 'bg-rose-50 border-rose-200' :
                isNearMaintenance ? 'bg-amber-50 border-amber-200' : 'bg-slate-50 border-slate-200'
              }`}>
                <div className="flex items-center justify-between text-xs mb-1.5">
                  <span className="text-slate-700 font-bold flex items-center gap-1">
                    Mốc bảo trì kế tiếp:
                    {isNearMaintenance && <span className="text-amber-700 text-[10px] font-bold">⚠️ Sắp đến hạn (&lt;10%)</span>}
                    {isOverdue && <span className="text-rose-700 text-[10px] font-bold">🚨 Quá hạn bảo trì!</span>}
                  </span>
                  <span className="font-mono text-emerald-700 font-extrabold">{machine.nextMaintenanceHours}h</span>
                </div>
                <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden">
                  <div
                    className={`h-full rounded-full transition-all ${
                      isOverdue ? 'bg-rose-600' : isNearMaintenance ? 'bg-amber-500' : 'bg-emerald-500'
                    }`}
                    style={{ width: `${Math.min(100, (machine.runningHours / machine.nextMaintenanceHours) * 100)}%` }}
                  />
                </div>
                <div className="text-[11px] text-slate-500 mt-1">
                  Bảo trì gần nhất: {machine.lastMaintenanceDate} ({machine.lastMaintenanceHours}h)
                </div>
              </div>
            </div>
          )}

          {activeTab === 'TROUBLESHOOT' && (
            <div className="space-y-2">
              {machine.quickTroubleshooting.map((item, idx) => (
                <div
                  key={idx}
                  className="rounded-xl bg-slate-50 border border-slate-200 overflow-hidden transition"
                >
                  <button
                    onClick={() => setOpenTroubleshootIdx(openTroubleshootIdx === idx ? null : idx)}
                    className="w-full p-3 text-left text-xs font-bold text-slate-800 flex items-center justify-between hover:bg-slate-100"
                  >
                    <span className="flex items-center gap-2 text-rose-700">
                      <AlertTriangle className="w-4 h-4 shrink-0" />
                      {item.issue}
                    </span>
                    <ChevronDown
                      className={`w-4 h-4 text-slate-400 transition-transform ${
                        openTroubleshootIdx === idx ? 'rotate-180' : ''
                      }`}
                    />
                  </button>
                  {openTroubleshootIdx === idx && (
                    <div className="px-3 pb-3 pt-1 text-xs text-slate-700 border-t border-slate-200 bg-white">
                      <span className="text-emerald-700 font-bold block mb-1">Hướng khắc phục nhanh:</span>
                      {item.solution}
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}

          {activeTab === 'HISTORY' && (
            <div className="space-y-3">
              <div className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-start gap-3 text-xs">
                <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                <div>
                  <div className="font-bold text-slate-900">Thay dầu bôi trơn & Vệ sinh phin lọc</div>
                  <div className="text-slate-500 text-[11px]">Ngày: {machine.lastMaintenanceDate} • Kỹ sư: ME Trần Minh Đức</div>
                </div>
              </div>
              <div className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-start gap-3 text-xs">
                <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                <div>
                  <div className="font-bold text-slate-900">Kiểm tra định kỳ mốc 500 Giờ</div>
                  <div className="text-slate-500 text-[11px]">Ngày: 2026-04-10 • Quản Đốc đã ký nghiệm thu</div>
                </div>
              </div>
              <div className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-start gap-3 text-xs">
                <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                <div>
                  <div className="font-bold text-slate-900">Sửa chữa SOS rò rỉ van áp suất</div>
                  <div className="text-slate-500 text-[11px]">Ngày: 2026-01-15 • Đã thay cụm gioăng làm kín</div>
                </div>
              </div>
            </div>
          )}

        </div>

        {/* Footer Action: Report SOS */}
        <div className="p-4 border-t border-slate-100 bg-white">
          <Button
            variant="destructive"
            size="lg"
            className="w-full h-12 text-xs font-black animate-pulse"
            onClick={() => {
              onClose();
              onOpenSOS(machine);
            }}
          >
            <AlertTriangle className="w-4 h-4" /> BÁO LỖI SOS KHẨN CẤP
          </Button>
        </div>

      </div>
    </div>
  );
};
