'use client';

import React, { useState } from 'react';
import {
  FileSignature,
  DollarSign,
  Cpu,
  Clock,
  TrendingUp,
  AlertTriangle,
  CheckCircle2,
  Sliders,
  Users,
  PlusCircle,
  Eye,
  CheckCircle,
  XCircle,
  X,
  Activity,
  Layers,
} from 'lucide-react';
import { Machine, WorkOrder, PMChecklist, SparePartRequest, SystemThresholdConfig } from '@/types';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { sound } from '@/lib/soundEffects';

interface SupervisorMobileViewProps {
  machines: Machine[];
  workOrders: WorkOrder[];
  checklists: PMChecklist[];
  sparePartRequests: SparePartRequest[];
  thresholdConfig: SystemThresholdConfig;
  onOpenSignoff: (itemCode: string, title: string, subtitle: string) => void;
  onOpenThresholdConfig: () => void;
  onOpenUserManagement?: () => void;
  onOpenAddMachine?: () => void;
  onApproveSparePart: (requestId: string) => void;
  onRejectSparePart: (requestId: string, reason: string) => void;
  onOpenMachinePassport?: (machine: Machine) => void;
}

export const SupervisorMobileView: React.FC<SupervisorMobileViewProps> = ({
  machines,
  workOrders,
  checklists,
  sparePartRequests,
  thresholdConfig,
  onOpenSignoff,
  onOpenThresholdConfig,
  onOpenUserManagement,
  onOpenAddMachine,
  onApproveSparePart,
  onRejectSparePart,
  onOpenMachinePassport,
}) => {
  const [mobileTab, setMobileTab] = useState<'OVERVIEW' | 'SIGNOFF' | 'SPARE_PARTS' | 'MACHINES'>('OVERVIEW');
  const [timeFilter, setTimeFilter] = useState<'TODAY' | '7DAYS' | '30DAYS'>('TODAY');
  const [rejectModalPart, setRejectModalPart] = useState<SparePartRequest | null>(null);
  const [rejectionReasonInput, setRejectionReasonInput] = useState('');

  // Statistics
  const totalMachines = machines.length || 1;
  const activeCount = machines.filter((m) => m.status === 'ACTIVE').length;
  const repairingCount = machines.filter((m) => m.status === 'REPAIRING').length;
  const maintenanceCount = machines.filter((m) => m.status === 'MAINTENANCE').length;
  const activePercent = Math.round((activeCount / totalMachines) * 100);
  const repairingPercent = Math.round((repairingCount / totalMachines) * 100);
  const maintenancePercent = Math.round((maintenanceCount / totalMachines) * 100);

  const pendingApprovalsWO = workOrders.filter((wo) => wo.status === 'COMPLETED');
  const pendingApprovalsPM = checklists.filter((pm) => pm.status === 'COMPLETED');
  const pendingSpareParts = sparePartRequests.filter((spr) => spr.status === 'PENDING');
  const totalPendingSignoffs = pendingApprovalsWO.length + pendingApprovalsPM.length;

  const handleConfirmRejectPart = (e: React.FormEvent) => {
    e.preventDefault();
    if (!rejectModalPart) return;
    if (!rejectionReasonInput.trim()) {
      alert('Vui lòng nhập lý do từ chối!');
      return;
    }
    sound.playClick();
    onRejectSparePart(rejectModalPart.id, rejectionReasonInput.trim());
    setRejectModalPart(null);
    setRejectionReasonInput('');
  };

  return (
    <div className="w-full space-y-2.5 pb-20 font-sans select-none overflow-x-hidden">
      
      {/* ========================================================================= */}
      {/* 1. COMPACT NATIVE MOBILE SUPERVISOR BAR */}
      {/* ========================================================================= */}
      <div className="bg-white rounded-xl p-2.5 border border-slate-200 shadow-xs space-y-2">
        
        {/* Row 1: Profile & Action Buttons */}
        <div className="flex items-center justify-between gap-2 min-w-0">
          <div className="flex items-center gap-2 min-w-0 flex-1">
            <div className="w-8 h-8 rounded-lg bg-amber-500 text-white flex items-center justify-center font-black text-[11px] shrink-0 shadow-xs">
              QĐ
            </div>
            <div className="min-w-0 flex-1">
              <div className="flex items-center gap-1.5">
                <span className="text-xs font-black text-slate-900 truncate">Quản Đốc Lê Hoàng</span>
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 shrink-0" />
              </div>
              <p className="text-[10px] text-slate-500 font-medium truncate">
                {thresholdConfig.workshopName || 'WS-01'} • Ngưỡng: <strong className="text-emerald-700 font-mono">{(thresholdConfig.costApprovalThreshold).toLocaleString('vi-VN')}đ</strong>
              </p>
            </div>
          </div>

          {/* Quick Action Icons */}
          <div className="flex items-center gap-1 shrink-0">
            {onOpenAddMachine && (
              <button
                onClick={() => {
                  sound.playClick();
                  onOpenAddMachine();
                }}
                className="p-1.5 rounded-lg bg-emerald-50 text-emerald-800 border border-emerald-200 hover:bg-emerald-100 transition"
                title="Thêm máy mới"
              >
                <PlusCircle className="w-4 h-4 text-emerald-600" />
              </button>
            )}

            {onOpenUserManagement && (
              <button
                onClick={() => {
                  sound.playClick();
                  onOpenUserManagement();
                }}
                className="p-1.5 rounded-lg bg-amber-50 text-amber-800 border border-amber-200 hover:bg-amber-100 transition"
                title="Nhân sự"
              >
                <Users className="w-4 h-4 text-amber-600" />
              </button>
            )}

            <button
              onClick={() => {
                sound.playClick();
                onOpenThresholdConfig();
              }}
              className="p-1.5 rounded-lg bg-slate-50 text-slate-700 border border-slate-200 hover:bg-slate-100 transition"
              title="Cấu hình ngưỡng"
            >
              <Sliders className="w-4 h-4 text-slate-600" />
            </button>
          </div>
        </div>

        {/* Row 2: Time Filter Tabs */}
        <div className="flex items-center justify-between pt-1 border-t border-slate-100 text-xs">
          <span className="text-[10px] font-bold text-slate-400 uppercase shrink-0">Khung giờ:</span>
          <div className="flex bg-slate-100 p-0.5 rounded-lg border border-slate-200 gap-0.5">
            <button
              onClick={() => {
                setTimeFilter('TODAY');
                sound.playClick();
              }}
              className={`px-2 py-0.5 rounded-md text-[10px] font-bold transition ${
                timeFilter === 'TODAY'
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'text-slate-600'
              }`}
            >
              Hôm nay
            </button>
            <button
              onClick={() => {
                setTimeFilter('7DAYS');
                sound.playClick();
              }}
              className={`px-2 py-0.5 rounded-md text-[10px] font-bold transition ${
                timeFilter === '7DAYS'
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'text-slate-600'
              }`}
            >
              7 ngày
            </button>
            <button
              onClick={() => {
                setTimeFilter('30DAYS');
                sound.playClick();
              }}
              className={`px-2 py-0.5 rounded-md text-[10px] font-bold transition ${
                timeFilter === '30DAYS'
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'text-slate-600'
              }`}
            >
              30 ngày
            </button>
          </div>
        </div>

      </div>

      {/* ========================================================================= */}
      {/* 2. MOBILE KPI CARDS (1 FULL ROW PER METRIC - KHÔNG BỊ ÉP) */}
      {/* ========================================================================= */}
      <div className="space-y-2">
        
        {/* KPI 1: OEE Card */}
        <div className="p-2.5 rounded-xl bg-white border border-emerald-200 shadow-xs flex items-center justify-between gap-2">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-9 h-9 rounded-lg bg-emerald-50 text-emerald-700 flex items-center justify-center font-black border border-emerald-200 shrink-0">
              <TrendingUp className="w-4 h-4" />
            </div>
            <div className="min-w-0">
              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block truncate">
                Hiệu Suất OEE Toàn Xưởng
              </span>
              <p className="text-[11px] text-slate-600 font-medium truncate">
                Chuẩn thế giới (&gt;90%) • <strong className="text-emerald-700">+1.8%</strong>
              </p>
            </div>
          </div>
          <div className="text-right shrink-0">
            <span className="text-xl font-black font-mono text-slate-900 block leading-none">
              94.2%
            </span>
            <span className="text-[8px] font-extrabold text-emerald-700 bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-200 mt-1 inline-block">
              ĐẠT CHUẨN
            </span>
          </div>
        </div>

        {/* KPI 2: Active Machines */}
        <div className="p-2.5 rounded-xl bg-white border border-teal-200 shadow-xs flex items-center justify-between gap-2">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-9 h-9 rounded-lg bg-teal-50 text-teal-700 flex items-center justify-center font-black border border-teal-200 shrink-0">
              <Cpu className="w-4 h-4" />
            </div>
            <div className="min-w-0">
              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block truncate">
                Tình Trạng Thiết Bị
              </span>
              <p className="text-[11px] text-slate-600 font-medium truncate">
                {repairingCount} Sửa SOS • {maintenanceCount} Bảo trì PM
              </p>
            </div>
          </div>
          <div className="text-right shrink-0">
            <span className="text-xl font-black font-mono text-emerald-700 block leading-none">
              {activeCount}<span className="text-xs text-slate-400 font-normal">/{totalMachines}</span>
            </span>
            <span className="text-[8px] font-extrabold text-teal-800 bg-teal-50 px-1.5 py-0.5 rounded border border-teal-200 mt-1 inline-block">
              {activePercent}% ACTIVE
            </span>
          </div>
        </div>

        {/* KPI 3: MTTR Downtime */}
        <div className="p-2.5 rounded-xl bg-white border border-sky-200 shadow-xs flex items-center justify-between gap-2">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-9 h-9 rounded-lg bg-sky-50 text-sky-700 flex items-center justify-center font-black border border-sky-200 shrink-0">
              <Clock className="w-4 h-4" />
            </div>
            <div className="min-w-0">
              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block truncate">
                Thời Gian Sửa TB (MTTR)
              </span>
              <p className="text-[11px] text-slate-600 font-medium truncate">
                Mục tiêu: &lt;45m • Downtime: <strong className="text-slate-700">1h 45m</strong>
              </p>
            </div>
          </div>
          <div className="text-right shrink-0">
            <span className="text-xl font-black font-mono text-sky-900 block leading-none">
              28m
            </span>
            <span className="text-[8px] font-extrabold text-sky-800 bg-sky-50 px-1.5 py-0.5 rounded border border-sky-200 mt-1 inline-block">
              TỐT
            </span>
          </div>
        </div>

        {/* KPI 4: Pending Signoffs */}
        <div className="p-2.5 rounded-xl bg-white border border-amber-200 shadow-xs flex items-center justify-between gap-2">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-9 h-9 rounded-lg bg-amber-50 text-amber-700 flex items-center justify-center font-black border border-amber-200 shrink-0">
              <FileSignature className="w-4 h-4" />
            </div>
            <div className="min-w-0">
              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block truncate">
                Phiếu Chờ Nghiệm Thu
              </span>
              <p className="text-[11px] text-amber-700 font-bold truncate">
                {totalPendingSignoffs > 0 ? 'Cần Quản đốc ký cảm ứng' : 'Đã nghiệm thu xong'}
              </p>
            </div>
          </div>
          <div className="text-right shrink-0">
            <span className="text-xl font-black font-mono text-amber-800 block leading-none">
              {totalPendingSignoffs}
            </span>
            <span className="text-[8px] font-extrabold text-amber-800 bg-amber-50 px-1.5 py-0.5 rounded border border-amber-200 mt-1 inline-block">
              PHIẾU XONG
            </span>
          </div>
        </div>

        {/* KPI 5: Pending Spare Parts */}
        <div className="p-2.5 rounded-xl bg-white border border-rose-200 shadow-xs flex items-center justify-between gap-2">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-9 h-9 rounded-lg bg-rose-50 text-rose-700 flex items-center justify-center font-black border border-rose-200 shrink-0">
              <DollarSign className="w-4 h-4" />
            </div>
            <div className="min-w-0">
              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block truncate">
                Duyệt Vật Tư &gt; Ngưỡng
              </span>
              <p className="text-[11px] text-rose-600 font-bold truncate">
                Tổng tiền: 2.400.000 VNĐ
              </p>
            </div>
          </div>
          <div className="text-right shrink-0">
            <span className="text-xl font-black font-mono text-rose-700 block leading-none">
              {pendingSpareParts.length}
            </span>
            <span className="text-[8px] font-extrabold text-rose-800 bg-rose-50 px-1.5 py-0.5 rounded border border-rose-200 mt-1 inline-block">
              ĐỀ XUẤT
            </span>
          </div>
        </div>

      </div>

      {/* ========================================================================= */}
      {/* 3. SCROLLABLE CLEAN SUB-TABS */}
      {/* ========================================================================= */}
      <div className="flex bg-slate-100 p-0.5 rounded-xl border border-slate-200 gap-1 text-xs">
        <button
          onClick={() => {
            setMobileTab('OVERVIEW');
            sound.playClick();
          }}
          className={`flex-1 py-1.5 rounded-lg font-bold text-[10px] sm:text-xs transition text-center truncate ${
            mobileTab === 'OVERVIEW'
              ? 'bg-white text-slate-900 shadow-xs'
              : 'text-slate-600'
          }`}
        >
          Tổng Quan
        </button>

        <button
          onClick={() => {
            setMobileTab('SIGNOFF');
            sound.playClick();
          }}
          className={`flex-1 py-1.5 rounded-lg font-bold text-[10px] sm:text-xs transition text-center truncate ${
            mobileTab === 'SIGNOFF'
              ? 'bg-white text-amber-900 shadow-xs'
              : 'text-slate-600'
          }`}
        >
          Ký Tên ({totalPendingSignoffs})
        </button>

        <button
          onClick={() => {
            setMobileTab('SPARE_PARTS');
            sound.playClick();
          }}
          className={`flex-1 py-1.5 rounded-lg font-bold text-[10px] sm:text-xs transition text-center truncate ${
            mobileTab === 'SPARE_PARTS'
              ? 'bg-white text-rose-900 shadow-xs'
              : 'text-slate-600'
          }`}
        >
          Vật Tư ({pendingSpareParts.length})
        </button>

        <button
          onClick={() => {
            setMobileTab('MACHINES');
            sound.playClick();
          }}
          className={`flex-1 py-1.5 rounded-lg font-bold text-[10px] sm:text-xs transition text-center truncate ${
            mobileTab === 'MACHINES'
              ? 'bg-white text-emerald-900 shadow-xs'
              : 'text-slate-600'
          }`}
        >
          Máy ({machines.length})
        </button>
      </div>

      {/* ========================================================================= */}
      {/* 4. TAB CONTENTS */}
      {/* ========================================================================= */}

      {/* TAB A: OVERVIEW & MACHINES */}
      {(mobileTab === 'OVERVIEW' || mobileTab === 'MACHINES') && (
        <div className="space-y-2.5">
          
          {/* Machine List */}
          <div className="bg-white rounded-xl p-3 border border-slate-200 shadow-xs space-y-2">
            <div className="flex items-center justify-between border-b border-slate-100 pb-1.5">
              <span className="text-xs font-black uppercase text-slate-900 flex items-center gap-1.5">
                <Cpu className="w-3.5 h-3.5 text-emerald-600" />
                <span>Tiến Độ Giờ Chạy Máy ({machines.length})</span>
              </span>
              <span className="text-[10px] text-slate-500 font-mono font-bold">Mốc PM</span>
            </div>

            <div className="space-y-2">
              {machines.map((machine) => {
                const remainingHours = machine.nextMaintenanceHours - machine.runningHours;
                const progressPercent = Math.min(
                  100,
                  Math.round((machine.runningHours / machine.nextMaintenanceHours) * 100)
                );
                const isNearPM = remainingHours > 0 && remainingHours <= machine.nextMaintenanceHours * 0.1;
                const isOverdue = remainingHours <= 0;

                return (
                  <div
                    key={machine.id}
                    className="p-2.5 rounded-lg bg-slate-50 border border-slate-200 space-y-1.5"
                  >
                    <div className="flex items-center justify-between gap-1.5">
                      <div className="flex items-center gap-1.5 min-w-0 flex-1">
                        <span className="font-mono text-[11px] font-black text-slate-900 bg-white px-1.5 py-0.5 rounded border border-slate-200 shrink-0">
                          {machine.code}
                        </span>
                        <span className="text-xs font-extrabold text-slate-800 truncate">{machine.name}</span>
                      </div>

                      <div className="flex items-center gap-1 shrink-0">
                        <Badge
                          variant={
                            machine.status === 'ACTIVE'
                              ? 'active'
                              : machine.status === 'REPAIRING'
                              ? 'repairing'
                              : 'maintenance'
                          }
                        >
                          {machine.status}
                        </Badge>
                        {onOpenMachinePassport && (
                          <button
                            onClick={() => {
                              sound.playClick();
                              onOpenMachinePassport(machine);
                            }}
                            className="p-1 rounded bg-white text-slate-600 hover:text-emerald-700 border border-slate-200"
                            title="Xem Hộ Chiếu Máy"
                          >
                            <Eye className="w-3.5 h-3.5" />
                          </button>
                        )}
                      </div>
                    </div>

                    <div className="w-full bg-white p-1.5 rounded-md border border-slate-200/80">
                      <div className="flex justify-between text-[10px] font-mono font-bold mb-1">
                        <span className="text-slate-700">
                          Chạy: <strong>{machine.runningHours.toLocaleString('vi-VN')}</strong> {machine.unitLabel || 'h'}
                        </span>
                        <span className={isOverdue ? 'text-rose-600' : isNearPM ? 'text-amber-600' : 'text-slate-500'}>
                          Mốc: {machine.nextMaintenanceHours.toLocaleString('vi-VN')}h ({progressPercent}%)
                        </span>
                      </div>
                      <div className="w-full bg-slate-200 h-1.5 rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full transition-all duration-500 ${
                            isOverdue
                              ? 'bg-rose-600'
                              : isNearPM
                              ? 'bg-amber-500'
                              : 'bg-emerald-500'
                          }`}
                          style={{ width: `${progressPercent}%` }}
                        />
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Downtime Breakdown */}
          <div className="bg-white rounded-xl p-3 border border-slate-200 shadow-xs space-y-2">
            <div className="flex items-center justify-between border-b border-slate-100 pb-1.5">
              <span className="text-xs font-black uppercase text-slate-900 flex items-center gap-1.5">
                <Activity className="w-3.5 h-3.5 text-sky-600" />
                <span>Phân Tích Cơ Cấu Downtime Ca</span>
              </span>
              <span className="text-[10px] font-mono font-bold text-rose-600">Tổng: 6h 40m</span>
            </div>

            <div>
              <div className="w-full bg-slate-100 h-3.5 rounded-full overflow-hidden flex border border-slate-200">
                <div
                  className="bg-rose-500 h-full text-[8px] text-white font-bold flex items-center justify-center"
                  style={{ width: '42%' }}
                >
                  SOS (2h35m)
                </div>
                <div
                  className="bg-amber-500 h-full text-[8px] text-white font-bold flex items-center justify-center"
                  style={{ width: '25%' }}
                >
                  PM (1h20m)
                </div>
                <div
                  className="bg-emerald-500/40 h-full text-[8px] text-emerald-950 font-bold flex items-center justify-center"
                  style={{ width: '33%' }}
                >
                  Ổn Định
                </div>
              </div>

              <div className="grid grid-cols-3 gap-1 pt-1.5 text-center">
                <div className="p-1 rounded-md bg-slate-50 border border-slate-200">
                  <span className="text-[8px] font-bold text-slate-400 uppercase block">MTTR (Sửa)</span>
                  <span className="font-mono font-black text-slate-900 text-[11px]">28 Phút</span>
                </div>
                <div className="p-1 rounded-md bg-slate-50 border border-slate-200">
                  <span className="text-[8px] font-bold text-slate-400 uppercase block">MTBF (Ổn)</span>
                  <span className="font-mono font-black text-emerald-700 text-[11px]">18.5 Giờ</span>
                </div>
                <div className="p-1 rounded-md bg-slate-50 border border-slate-200">
                  <span className="text-[8px] font-bold text-slate-400 uppercase block">Sẵn Sàng</span>
                  <span className="font-mono font-black text-sky-700 text-[11px]">96.5%</span>
                </div>
              </div>
            </div>
          </div>

        </div>
      )}

      {/* TAB B: SIGNOFF QUEUE */}
      {(mobileTab === 'OVERVIEW' || mobileTab === 'SIGNOFF') && (
        <div className="bg-white rounded-xl p-3 border border-amber-200 shadow-xs space-y-2">
          <div className="flex items-center justify-between border-b border-amber-100 pb-1.5">
            <span className="text-xs font-black uppercase text-amber-950 flex items-center gap-1.5">
              <FileSignature className="w-3.5 h-3.5 text-amber-600" />
              <span>Chờ Quản Đốc Ký ({totalPendingSignoffs})</span>
            </span>
            <span className="text-[9px] font-bold text-amber-800 bg-amber-100 px-1.5 py-0.5 rounded">
              Chữ Ký Số
            </span>
          </div>

          {totalPendingSignoffs === 0 ? (
            <div className="p-4 text-center text-xs text-slate-500 border border-dashed border-slate-200 rounded-lg bg-slate-50">
              <CheckCircle2 className="w-4 h-4 text-emerald-600 mx-auto mb-1 opacity-80" />
              <span className="font-bold text-slate-700">Đã hoàn tất nghiệm thu toàn bộ!</span>
            </div>
          ) : (
            <div className="space-y-1.5">
              {pendingApprovalsWO.map((wo) => (
                <div
                  key={wo.id}
                  className="p-2.5 rounded-lg bg-amber-50/40 border border-amber-200 shadow-xs flex items-center justify-between gap-2"
                >
                  <div className="min-w-0">
                    <div className="flex items-center gap-1.5">
                      <span className="font-mono text-[10px] font-bold text-rose-700 bg-rose-50 px-1 py-0.2 rounded border border-rose-200 shrink-0">
                        SOS: {wo.code}
                      </span>
                      <span className="text-xs font-extrabold text-slate-900 truncate">{wo.machineName}</span>
                    </div>
                    <p className="text-[10px] text-slate-500 font-medium mt-0.5 truncate">
                      ME: <strong className="text-slate-700">{wo.assigneeName || 'Trần Minh Đức'}</strong>
                    </p>
                  </div>

                  <Button
                    size="sm"
                    variant="amber"
                    onClick={() => {
                      sound.playClick();
                      onOpenSignoff(
                        wo.code,
                        `Nghiệm Thu Phiếu SOS: ${wo.code}`,
                        `Ký xác nhận nghiệm thu bàn giao máy ${wo.machineCode} trở lại vận hành`
                      );
                    }}
                    className="gap-1 text-[11px] font-extrabold h-7 px-2.5 shadow-xs shrink-0"
                  >
                    <FileSignature className="w-3 h-3" />
                    <span>Ký Tên</span>
                  </Button>
                </div>
              ))}

              {pendingApprovalsPM.map((pm) => (
                <div
                  key={pm.id}
                  className="p-2.5 rounded-lg bg-emerald-50/40 border border-emerald-200 shadow-xs flex items-center justify-between gap-2"
                >
                  <div className="min-w-0">
                    <div className="flex items-center gap-1.5">
                      <span className="font-mono text-[10px] font-bold text-emerald-700 bg-emerald-50 px-1 py-0.2 rounded border border-emerald-200 shrink-0">
                        PM: {pm.code}
                      </span>
                      <span className="text-xs font-extrabold text-slate-900 truncate">{pm.machineName}</span>
                    </div>
                    <p className="text-[10px] text-slate-500 font-medium mt-0.5 truncate">
                      Mốc: <strong className="text-slate-700">{pm.scheduledHours}h máy chạy</strong>
                    </p>
                  </div>

                  <Button
                    size="sm"
                    variant="default"
                    onClick={() => {
                      sound.playClick();
                      onOpenSignoff(
                        pm.code,
                        `Nghiệm Thu Bảo Trì: ${pm.code}`,
                        `Ký xác nhận hoàn tất đợt PM mốc ${pm.scheduledHours}h cho thiết bị ${pm.machineCode}`
                      );
                    }}
                    className="gap-1 text-[11px] font-extrabold h-7 px-2.5 shadow-xs shrink-0"
                  >
                    <FileSignature className="w-3 h-3" />
                    <span>Ký Tên</span>
                  </Button>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* TAB C: SPARE PARTS APPROVAL */}
      {(mobileTab === 'OVERVIEW' || mobileTab === 'SPARE_PARTS') && (
        <div className="bg-white rounded-xl p-3 border border-rose-200 shadow-xs space-y-2">
          <div className="flex items-center justify-between border-b border-rose-100 pb-1.5">
            <span className="text-xs font-black uppercase text-rose-950 flex items-center gap-1.5">
              <DollarSign className="w-3.5 h-3.5 text-rose-600" />
              <span>Duyệt Vật Tư &gt; Ngưỡng ({pendingSpareParts.length})</span>
            </span>
            <span className="font-mono text-[9px] font-bold text-rose-700 bg-rose-100 px-1.5 py-0.5 rounded">
              &gt; {(thresholdConfig.costApprovalThreshold / 1000000).toFixed(1)}Tr
            </span>
          </div>

          {pendingSpareParts.length === 0 ? (
            <div className="p-4 text-center text-xs text-slate-500 border border-dashed border-slate-200 rounded-lg bg-slate-50">
              Không có đề xuất linh kiện nào chờ duyệt.
            </div>
          ) : (
            <div className="space-y-2">
              {pendingSpareParts.map((spr) => {
                const isOverThreshold = spr.totalCost >= thresholdConfig.costApprovalThreshold;

                return (
                  <div
                    key={spr.id}
                    className="p-2.5 rounded-lg bg-rose-50/40 border border-rose-200 shadow-xs space-y-1.5 text-xs"
                  >
                    <div className="flex items-center justify-between">
                      <span className="font-mono text-[10px] font-bold text-slate-900 bg-white px-1.5 py-0.5 rounded border border-slate-200">
                        {spr.machineCode}
                      </span>
                      <span className="font-extrabold text-rose-700 font-mono text-xs">
                        {spr.totalCost.toLocaleString('vi-VN')} VNĐ
                      </span>
                    </div>

                    <div>
                      <div className="font-bold text-slate-900 text-xs">
                        {spr.partName} <span className="text-slate-500 font-medium">(x{spr.quantity})</span>
                      </div>
                      <p className="text-[10px] text-slate-600 mt-0.5">Lý do: {spr.reason}</p>
                    </div>

                    {isOverThreshold && (
                      <div className="p-1 rounded-md bg-rose-100 text-rose-900 text-[9px] font-bold border border-rose-200 flex items-center gap-1">
                        <AlertTriangle className="w-3 h-3 text-rose-600 shrink-0" />
                        <span>Vượt ngưỡng phê duyệt phân xưởng!</span>
                      </div>
                    )}

                    <div className="flex items-center gap-1.5 pt-0.5">
                      <Button
                        variant="destructive"
                        size="sm"
                        onClick={() => {
                          sound.playClick();
                          setRejectModalPart(spr);
                        }}
                        className="flex-1 h-7 text-[11px] font-bold"
                      >
                        <XCircle className="w-3 h-3" />
                        <span>Từ Chối</span>
                      </Button>

                      <Button
                        variant="default"
                        size="sm"
                        onClick={() => {
                          sound.playSuccess();
                          onApproveSparePart(spr.id);
                        }}
                        className="flex-1 h-7 text-[11px] font-bold bg-emerald-600 hover:bg-emerald-700"
                      >
                        <CheckCircle className="w-3 h-3" />
                        <span>Phê Duyệt</span>
                      </Button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      )}

      {/* ========================================================================= */}
      {/* 5. REJECT MODAL */}
      {/* ========================================================================= */}
      {rejectModalPart && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
          <div className="w-full max-w-sm bg-white rounded-2xl p-4 shadow-2xl border border-slate-200 animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between border-b border-slate-100 pb-2 mb-3">
              <div className="flex items-center gap-1.5 text-rose-700 font-black text-xs">
                <AlertTriangle className="w-4 h-4" />
                <span>Từ Chối Đề Xuất Linh Kiện</span>
              </div>
              <button
                onClick={() => setRejectModalPart(null)}
                className="p-1 rounded-full text-slate-400 hover:text-slate-700"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleConfirmRejectPart} className="space-y-3">
              <div className="text-xs text-slate-800 bg-slate-50 p-2.5 rounded-xl border border-slate-200">
                <div>Mã máy: <strong className="font-mono text-slate-900">{rejectModalPart.machineCode}</strong></div>
                <div>Linh kiện: <strong className="text-slate-900">{rejectModalPart.partName}</strong></div>
                <div>Tổng chi phí: <strong className="text-rose-700 font-mono">{rejectModalPart.totalCost.toLocaleString('vi-VN')} VNĐ</strong></div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  Nhập lý do từ chối (Bắt buộc theo US-09):
                </label>
                <textarea
                  rows={3}
                  required
                  placeholder="Ví dụ: Đã có sẵn kho phụ tùng dự phòng, kiểm tra lại phụ tùng cũ..."
                  value={rejectionReasonInput}
                  onChange={(e) => setRejectionReasonInput(e.target.value)}
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl p-2.5 text-xs text-slate-900 focus:outline-none focus:border-rose-500"
                />
              </div>

              <div className="flex gap-2 pt-1">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() => setRejectModalPart(null)}
                  className="flex-1"
                >
                  Hủy
                </Button>
                <Button
                  type="submit"
                  variant="destructive"
                  size="sm"
                  className="flex-1"
                >
                  Xác Nhận Từ Chối
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};
