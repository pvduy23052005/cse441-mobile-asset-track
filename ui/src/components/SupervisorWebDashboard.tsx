'use client';

import React, { useState } from 'react';
import {
  Sliders,
  FileSignature,
  CheckCircle2,
  AlertTriangle,
  X,
  Users,
  Cpu,
  Clock,
  TrendingUp,
  Activity,
  PlusCircle,
  Download,
  Search,
  Eye,
  CheckCircle,
  XCircle,
  Layers,
  ChevronRight,
  DollarSign,
} from 'lucide-react';
import { Machine, WorkOrder, PMChecklist, SparePartRequest, SystemThresholdConfig } from '@/types';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { sound } from '@/lib/soundEffects';

interface SupervisorWebDashboardProps {
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

export const SupervisorWebDashboard: React.FC<SupervisorWebDashboardProps> = ({
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
  const [timeFilter, setTimeFilter] = useState<'TODAY' | '7DAYS' | '30DAYS'>('TODAY');
  const [machineSearch, setMachineSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<'ALL' | 'ACTIVE' | 'REPAIRING' | 'MAINTENANCE'>('ALL');
  const [rejectModalPart, setRejectModalPart] = useState<SparePartRequest | null>(null);
  const [rejectionReasonInput, setRejectionReasonInput] = useState('');
  const [isExporting, setIsExporting] = useState(false);

  // Machine Statistics
  const totalMachines = machines.length || 1;
  const activeCount = machines.filter((m) => m.status === 'ACTIVE').length;
  const repairingCount = machines.filter((m) => m.status === 'REPAIRING').length;
  const maintenanceCount = machines.filter((m) => m.status === 'MAINTENANCE').length;

  const activePercent = Math.round((activeCount / totalMachines) * 100);
  const repairingPercent = Math.round((repairingCount / totalMachines) * 100);
  const maintenancePercent = Math.round((maintenanceCount / totalMachines) * 100);

  // Pending Approvals
  const pendingApprovalsWO = workOrders.filter((wo) => wo.status === 'COMPLETED');
  const pendingApprovalsPM = checklists.filter((pm) => pm.status === 'COMPLETED');
  const pendingSpareParts = sparePartRequests.filter((spr) => spr.status === 'PENDING');
  const totalPendingSignoffs = pendingApprovalsWO.length + pendingApprovalsPM.length;

  // Filtered Machines
  const filteredMachines = machines.filter((m) => {
    const matchesSearch =
      m.name.toLowerCase().includes(machineSearch.toLowerCase()) ||
      m.code.toLowerCase().includes(machineSearch.toLowerCase()) ||
      m.location.toLowerCase().includes(machineSearch.toLowerCase());
    const matchesStatus = statusFilter === 'ALL' || m.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  // Rejection Submission Handler
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

  // Export Report Simulation
  const handleExportReport = () => {
    sound.playSuccess();
    setIsExporting(true);
    setTimeout(() => {
      setIsExporting(false);
      alert('📊 Đã xuất Báo cáo Nghiệm thu & OEE Toàn Phân Xưởng (PDF/Excel) thành công!');
    }, 600);
  };

  return (
    <div className="w-full max-w-7xl mx-auto space-y-5 pb-20 font-sans select-none overflow-hidden">
      
      {/* ========================================================================= */}
      {/* 1. TOP EXECUTIVE COMMAND HEADER */}
      {/* ========================================================================= */}
      <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-xs space-y-3">
        <div className="flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-11 h-11 rounded-2xl bg-gradient-to-br from-emerald-600 to-teal-700 text-white flex items-center justify-center font-black text-sm shadow-md">
              WS
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-xl font-black text-slate-900 tracking-tight">
                  Giám Sát & Điều Hành Quản Đốc (Supervisor Executive Dashboard)
                </h1>
                <span className="px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 font-mono text-xs font-black border border-emerald-200">
                  PHÂN XƯỞNG {thresholdConfig.workshopName || 'WS-01'}
                </span>
                <div className="flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 text-[10px] font-bold">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-ping" />
                  <span>Realtime Supabase Active</span>
                </div>
              </div>
              <p className="text-xs text-slate-500 font-medium mt-0.5">
                Theo dõi hiệu suất OEE • Nghiệm thu chữ ký số cảm ứng • Phê duyệt linh kiện vượt ngưỡng (Ngưỡng: <strong className="text-emerald-700 font-mono">{(thresholdConfig.costApprovalThreshold).toLocaleString('vi-VN')}đ</strong>)
              </p>
            </div>
          </div>

          {/* Action Buttons Toolbar */}
          <div className="flex items-center gap-2">
            {onOpenAddMachine && (
              <button
                onClick={() => {
                  sound.playClick();
                  onOpenAddMachine();
                }}
                className="px-3 py-2 rounded-xl text-xs font-black text-emerald-800 bg-emerald-50 border border-emerald-300 hover:bg-emerald-100 flex items-center gap-1.5 transition shadow-xs"
              >
                <PlusCircle className="w-4 h-4 text-emerald-600" />
                <span>+ Thêm Máy Mới</span>
              </button>
            )}

            {onOpenUserManagement && (
              <button
                onClick={() => {
                  sound.playClick();
                  onOpenUserManagement();
                }}
                className="px-3 py-2 rounded-xl text-xs font-black text-amber-800 bg-amber-50 border border-amber-300 hover:bg-amber-100 flex items-center gap-1.5 transition shadow-xs"
              >
                <Users className="w-4 h-4 text-amber-600" />
                <span>Quản Lý Nhân Sự</span>
              </button>
            )}

            <button
              onClick={() => {
                sound.playClick();
                onOpenThresholdConfig();
              }}
              className="px-3 py-2 rounded-xl text-xs font-black text-slate-700 bg-slate-50 border border-slate-300 hover:bg-slate-100 flex items-center gap-1.5 transition shadow-xs"
            >
              <Sliders className="w-4 h-4 text-slate-600" />
              <span>Cấu Hình Ngưỡng</span>
            </button>

            <button
              disabled={isExporting}
              onClick={handleExportReport}
              className="px-3.5 py-2 rounded-xl text-xs font-black text-white bg-indigo-600 hover:bg-indigo-700 flex items-center gap-1.5 transition shadow-xs"
            >
              <Download className="w-4 h-4" />
              <span>{isExporting ? 'Đang xuất...' : 'Xuất Báo Cáo (Excel/PDF)'}</span>
            </button>
          </div>
        </div>

        {/* Time Horizon Filter Tabs */}
        <div className="flex items-center justify-between pt-2 border-t border-slate-100 text-xs">
          <span className="text-xs text-slate-500 font-extrabold uppercase tracking-wider">
            Phạm vi phân tích dữ liệu:
          </span>
          <div className="flex bg-slate-100 p-1 rounded-xl border border-slate-200 gap-1">
            <button
              onClick={() => {
                setTimeFilter('TODAY');
                sound.playClick();
              }}
              className={`px-4 py-1 rounded-lg text-xs font-bold transition ${
                timeFilter === 'TODAY'
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              Hôm nay (Ca 1 & Ca 2)
            </button>
            <button
              onClick={() => {
                setTimeFilter('7DAYS');
                sound.playClick();
              }}
              className={`px-4 py-1 rounded-lg text-xs font-bold transition ${
                timeFilter === '7DAYS'
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              7 ngày qua
            </button>
            <button
              onClick={() => {
                setTimeFilter('30DAYS');
                sound.playClick();
              }}
              className={`px-4 py-1 rounded-lg text-xs font-bold transition ${
                timeFilter === '30DAYS'
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              30 ngày qua
            </button>
          </div>
        </div>

      </div>

      {/* ========================================================================= */}
      {/* 2. FIVE EXECUTIVE SCORECARDS (5 CỘT SANG TRỌNG TRÊN DESKTOP) */}
      {/* ========================================================================= */}
      <div className="grid grid-cols-5 gap-3.5">
        
        {/* KPI 1: OEE Metric */}
        <div className="p-4 rounded-2xl bg-gradient-to-br from-emerald-500/10 via-white to-white border border-emerald-200 shadow-xs relative overflow-hidden">
          <div className="flex items-center justify-between text-xs font-bold text-emerald-800 mb-1">
            <span className="uppercase tracking-wider">Hiệu Suất OEE</span>
            <TrendingUp className="w-4 h-4 text-emerald-600" />
          </div>
          <div className="flex items-baseline gap-1.5">
            <span className="text-3xl font-black font-mono text-slate-900">94.2%</span>
            <span className="text-xs font-bold text-emerald-700">+1.8%</span>
          </div>
          <p className="text-xs text-slate-500 mt-1 font-medium line-clamp-1">
            Chuẩn thế giới (&gt;90%)
          </p>
        </div>

        {/* KPI 2: Active Machines */}
        <div className="p-4 rounded-2xl bg-gradient-to-br from-teal-500/10 via-white to-white border border-teal-200 shadow-xs relative overflow-hidden">
          <div className="flex items-center justify-between text-xs font-bold text-teal-800 mb-1">
            <span className="uppercase tracking-wider">Máy Hoạt Động</span>
            <Cpu className="w-4 h-4 text-teal-600" />
          </div>
          <div className="flex items-baseline gap-1.5">
            <span className="text-3xl font-black font-mono text-emerald-700">{activeCount}</span>
            <span className="text-xs font-bold text-slate-500 font-mono">/ {totalMachines} ({activePercent}%)</span>
          </div>
          <p className="text-xs text-slate-500 mt-1 font-medium line-clamp-1">
            {repairingCount} Sửa SOS • {maintenanceCount} PM
          </p>
        </div>

        {/* KPI 3: MTTR Downtime */}
        <div className="p-4 rounded-2xl bg-gradient-to-br from-sky-500/10 via-white to-white border border-sky-200 shadow-xs relative overflow-hidden">
          <div className="flex items-center justify-between text-xs font-bold text-sky-800 mb-1">
            <span className="uppercase tracking-wider">Thời Gian Sửa (MTTR)</span>
            <Clock className="w-4 h-4 text-sky-600" />
          </div>
          <div className="flex items-baseline gap-1.5">
            <span className="text-3xl font-black font-mono text-sky-900">28m</span>
            <span className="text-xs font-bold text-sky-700">&lt; 45m mục tiêu</span>
          </div>
          <p className="text-xs text-slate-500 mt-1 font-medium line-clamp-1">
            Downtime ca: 1h 45m
          </p>
        </div>

        {/* KPI 4: Pending Sign-offs */}
        <div className="p-4 rounded-2xl bg-gradient-to-br from-amber-500/10 via-white to-white border border-amber-200 shadow-xs relative overflow-hidden">
          <div className="flex items-center justify-between text-xs font-bold text-amber-800 mb-1">
            <span className="uppercase tracking-wider">Chờ Ký Nghiệm Thu</span>
            <FileSignature className="w-4 h-4 text-amber-600" />
          </div>
          <div className="flex items-baseline gap-1.5">
            <span className="text-3xl font-black font-mono text-amber-800">{totalPendingSignoffs}</span>
            <span className="text-xs font-bold text-slate-500">Phiếu</span>
          </div>
          <p className="text-xs text-amber-700 font-bold mt-1 line-clamp-1">
            {totalPendingSignoffs > 0 ? 'Cần Quản đốc ký' : 'Đã nghiệm thu'}
          </p>
        </div>

        {/* KPI 5: Pending Spare Parts */}
        <div className="p-4 rounded-2xl bg-gradient-to-br from-rose-500/10 via-white to-white border border-rose-200 shadow-xs relative overflow-hidden">
          <div className="flex items-center justify-between text-xs font-bold text-rose-800 mb-1">
            <span className="uppercase tracking-wider">Duyệt Linh Kiện &gt; Ngưỡng</span>
            <AlertTriangle className="w-4 h-4 text-rose-600" />
          </div>
          <div className="flex items-baseline gap-1.5">
            <span className="text-3xl font-black font-mono text-rose-700">{pendingSpareParts.length}</span>
            <span className="text-xs font-bold text-slate-500">Đề xuất</span>
          </div>
          <p className="text-xs text-rose-600 font-bold mt-1 line-clamp-1">
            Tổng tiền: 2.400.000đ
          </p>
        </div>

      </div>

      {/* ========================================================================= */}
      {/* 3. TWELVE COLUMN EXECUTIVE WORKSHOP FLEET & CONTROL MATRIX */}
      {/* ========================================================================= */}
      <div className="grid grid-cols-12 gap-5 items-start">
        
        {/* ========================================================= */}
        {/* LEFT COLUMN (7 Cols): FLEET MONITORING & PM PROGRESS */}
        {/* ========================================================= */}
        <div className="col-span-7 space-y-5">
          
          {/* Card: Ma Trận Giám Sát Thiết Bị Thời Gian Thực */}
          <Card className="shadow-xs border-slate-200 overflow-hidden">
            <CardHeader className="p-4 pb-3 border-b border-slate-100">
              <div className="flex items-center justify-between gap-4">
                <div>
                  <CardTitle className="text-sm font-black uppercase tracking-wider text-slate-900 flex items-center gap-2">
                    <Cpu className="w-4 h-4 text-emerald-600" />
                    <span>Ma Trận Giám Sát Thiết Bị & Mốc PM ({filteredMachines.length}/{machines.length})</span>
                  </CardTitle>
                  <p className="text-xs text-slate-500 font-medium mt-0.5">
                    Hộ chiếu máy, chỉ số giờ chạy và chu kỳ bảo dưỡng phòng ngừa
                  </p>
                </div>

                {/* Filter & Search Bar */}
                <div className="flex items-center gap-2">
                  <div className="relative">
                    <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      placeholder="Tìm mã máy, tên máy..."
                      value={machineSearch}
                      onChange={(e) => setMachineSearch(e.target.value)}
                      className="pl-8 pr-3 py-1.5 text-xs rounded-xl bg-slate-50 border border-slate-200 focus:outline-none focus:border-emerald-500 w-44 font-medium"
                    />
                  </div>

                  <select
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value as any)}
                    className="py-1.5 px-3 text-xs rounded-xl bg-slate-50 border border-slate-200 text-slate-700 font-bold focus:outline-none"
                  >
                    <option value="ALL">Tất Cả Trạng Thái</option>
                    <option value="ACTIVE">🟢 Đang Hoạt Động</option>
                    <option value="REPAIRING">🔴 Đang Sửa SOS</option>
                    <option value="MAINTENANCE">🟡 Đang Bảo Trì PM</option>
                  </select>
                </div>
              </div>
            </CardHeader>

            <CardContent className="p-0">
              <div className="divide-y divide-slate-100">
                {filteredMachines.map((machine) => {
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
                      className="p-4 hover:bg-slate-50/80 transition flex items-center justify-between gap-4 group"
                    >
                      {/* Left: Machine Identity */}
                      <div className="flex items-center gap-3 min-w-0">
                        <div
                          className={`w-9 h-9 rounded-xl flex items-center justify-center font-black text-xs shrink-0 border ${
                            machine.status === 'ACTIVE'
                              ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
                              : machine.status === 'REPAIRING'
                              ? 'bg-rose-50 text-rose-800 border-rose-200 animate-pulse'
                              : 'bg-amber-50 text-amber-800 border-amber-200'
                          }`}
                        >
                          {machine.code.substring(0, 3)}
                        </div>

                        <div className="min-w-0">
                          <div className="flex items-center gap-2">
                            <span className="font-mono text-xs font-black text-slate-900">{machine.code}</span>
                            <span className="text-xs font-extrabold text-slate-800 truncate">{machine.name}</span>
                          </div>
                          <span className="text-xs text-slate-400 font-medium block truncate">
                            {machine.location} • {machine.specifications?.manufacturer || 'Brother Japan'}
                          </span>
                        </div>
                      </div>

                      {/* Right: Running Hours Progress Bar & Passport Button */}
                      <div className="flex items-center gap-4 shrink-0">
                        <div className="w-44 text-right">
                          <div className="flex justify-between text-xs font-mono font-bold mb-1">
                            <span className="text-slate-700">
                              Chạy: <strong className="text-slate-900">{machine.runningHours.toLocaleString('vi-VN')}</strong> {machine.unitLabel || 'h'}
                            </span>
                            <span className={isOverdue ? 'text-rose-600' : isNearPM ? 'text-amber-600' : 'text-slate-500'}>
                              Mốc: {machine.nextMaintenanceHours.toLocaleString('vi-VN')}h ({progressPercent}%)
                            </span>
                          </div>

                          <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden">
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

                        <Badge
                          variant={
                            machine.status === 'ACTIVE'
                              ? 'active'
                              : machine.status === 'REPAIRING'
                              ? 'repairing'
                              : 'maintenance'
                          }
                        >
                          {machine.status === 'ACTIVE'
                            ? 'Hoạt Động'
                            : machine.status === 'REPAIRING'
                            ? 'Sự Cố SOS'
                            : 'Bảo Trì PM'}
                        </Badge>

                        {onOpenMachinePassport && (
                          <button
                            onClick={() => {
                              sound.playClick();
                              onOpenMachinePassport(machine);
                            }}
                            className="p-1.5 rounded-lg bg-slate-100 hover:bg-emerald-50 text-slate-600 hover:text-emerald-700 border border-slate-200 hover:border-emerald-300 transition"
                            title="Xem Hộ Chiếu Máy"
                          >
                            <Eye className="w-4 h-4" />
                          </button>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            </CardContent>
          </Card>

          {/* Card: Phân Tích Cơ Cấu Downtime & MTTR/MTBF */}
          <Card className="shadow-xs border-slate-200 overflow-hidden">
            <CardHeader className="p-4 pb-3 border-b border-slate-100">
              <div className="flex items-center justify-between">
                <CardTitle className="text-xs font-black uppercase tracking-wider text-slate-900 flex items-center gap-2">
                  <Activity className="w-4 h-4 text-sky-600" />
                  <span>Phân Tích Cơ Cấu Downtime Ca & Telemetry</span>
                </CardTitle>
                <span className="text-xs font-mono font-bold text-rose-600">Tổng downtime ca: 6h 40m</span>
              </div>
            </CardHeader>

            <CardContent className="p-4 space-y-3">
              <div>
                <div className="w-full bg-slate-100 h-4 rounded-full overflow-hidden flex border border-slate-200">
                  <div
                    className="bg-rose-500 h-full text-[9px] text-white font-bold flex items-center justify-center"
                    style={{ width: '42%' }}
                  >
                    Dừng Sự Cố SOS (2h 35m)
                  </div>
                  <div
                    className="bg-amber-500 h-full text-[9px] text-white font-bold flex items-center justify-center"
                    style={{ width: '25%' }}
                  >
                    Bảo Trì PM (1h 20m)
                  </div>
                  <div
                    className="bg-emerald-500/40 h-full text-[9px] text-emerald-950 font-bold flex items-center justify-center"
                    style={{ width: '33%' }}
                  >
                    Vận Hành Ổn Định
                  </div>
                </div>
                <div className="flex justify-between text-xs text-slate-400 mt-1 font-mono font-semibold">
                  <span>0h</span>
                  <span>2h</span>
                  <span>4h</span>
                  <span>6h</span>
                  <span>8h (Hết ca)</span>
                </div>
              </div>

              <div className="grid grid-cols-3 gap-3 pt-1">
                <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                  <span className="text-xs font-bold text-slate-400 uppercase block">Thời Gian Sửa TB (MTTR)</span>
                  <span className="font-mono font-black text-slate-900 text-sm">28 Phút / Sự cố</span>
                </div>
                <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                  <span className="text-xs font-bold text-slate-400 uppercase block">Chạy Ổn Định TB (MTBF)</span>
                  <span className="font-mono font-black text-emerald-700 text-sm">18.5 Giờ</span>
                </div>
                <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                  <span className="text-xs font-bold text-slate-400 uppercase block">Tỷ Lệ Sẵn Sàng Máy</span>
                  <span className="font-mono font-black text-sky-700 text-sm">96.5%</span>
                </div>
              </div>
            </CardContent>
          </Card>

        </div>

        {/* ========================================================= */}
        {/* RIGHT COLUMN (5 Cols): APPROVAL CENTER & DONUT CHART */}
        {/* ========================================================= */}
        <div className="col-span-5 space-y-5">
          
          {/* Box 1: Hàng Đợi Ký Nghiệm Thu Chữ Ký Số */}
          <Card className="shadow-xs border-amber-200 bg-amber-50/20 overflow-hidden">
            <CardHeader className="p-4 pb-3 border-b border-amber-100 bg-amber-50/60">
              <div className="flex items-center justify-between">
                <CardTitle className="text-xs font-black uppercase tracking-wider text-amber-950 flex items-center gap-2">
                  <FileSignature className="w-4 h-4 text-amber-600" />
                  <span>Ký Nghiệm Thu Điện Tử ({totalPendingSignoffs})</span>
                </CardTitle>
                <span className="text-[10px] font-bold text-amber-800 bg-amber-100 px-2 py-0.5 rounded">
                  Chờ Quản Đốc
                </span>
              </div>
            </CardHeader>

            <CardContent className="p-4 space-y-2.5">
              {totalPendingSignoffs === 0 ? (
                <div className="p-6 text-center text-xs text-slate-500 border border-dashed border-slate-200 rounded-xl bg-white">
                  <CheckCircle2 className="w-6 h-6 text-emerald-600 mx-auto mb-1 opacity-80" />
                  <span className="font-bold text-slate-700">Tất cả phiếu sửa chữa và PM đã được nghiệm thu!</span>
                </div>
              ) : (
                <div className="space-y-2">
                  {pendingApprovalsWO.map((wo) => (
                    <div
                      key={wo.id}
                      className="p-3 rounded-xl bg-white border border-slate-200 shadow-xs flex items-center justify-between gap-3 text-xs hover:border-amber-400 transition"
                    >
                      <div className="min-w-0">
                        <div className="flex items-center gap-2">
                          <span className="font-mono text-xs font-bold text-rose-700 bg-rose-50 px-1.5 py-0.5 rounded border border-rose-200">
                            SOS: {wo.code}
                          </span>
                          <span className="font-bold text-slate-900 truncate">{wo.machineName}</span>
                        </div>
                        <p className="text-xs text-slate-500 font-medium mt-0.5 truncate">
                          ME hoàn tất: <strong className="text-slate-700">{wo.assigneeName || 'Trần Minh Đức'}</strong>
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
                        className="gap-1.5 text-xs font-extrabold h-8 px-3 shadow-xs shrink-0"
                      >
                        <FileSignature className="w-3.5 h-3.5" />
                        <span>Ký Tên</span>
                      </Button>
                    </div>
                  ))}

                  {pendingApprovalsPM.map((pm) => (
                    <div
                      key={pm.id}
                      className="p-3 rounded-xl bg-white border border-slate-200 shadow-xs flex items-center justify-between gap-3 text-xs hover:border-emerald-400 transition"
                    >
                      <div className="min-w-0">
                        <div className="flex items-center gap-2">
                          <span className="font-mono text-xs font-bold text-emerald-700 bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-200">
                            PM: {pm.code}
                          </span>
                          <span className="font-bold text-slate-900 truncate">{pm.machineName}</span>
                        </div>
                        <p className="text-xs text-slate-500 font-medium mt-0.5 truncate">
                          Bảo trì mốc: <strong className="text-slate-700">{pm.scheduledHours}h máy chạy</strong>
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
                        className="gap-1.5 text-xs font-extrabold h-8 px-3 shadow-xs shrink-0"
                      >
                        <FileSignature className="w-3.5 h-3.5" />
                        <span>Ký Tên</span>
                      </Button>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Box 2: Phê Duyệt Linh Kiện Đắt Tiền Vượt Ngưỡng */}
          <Card className="shadow-xs border-rose-200 bg-rose-50/20 overflow-hidden">
            <CardHeader className="p-4 pb-3 border-b border-rose-100 bg-rose-50/60">
              <div className="flex items-center justify-between">
                <CardTitle className="text-xs font-black uppercase tracking-wider text-rose-950 flex items-center gap-2">
                  <DollarSign className="w-4 h-4 text-rose-600" />
                  <span>Duyệt Linh Kiện &gt; Ngưỡng ({pendingSpareParts.length})</span>
                </CardTitle>
                <span className="font-mono text-[10px] font-bold text-rose-700 bg-rose-100 px-2 py-0.5 rounded">
                  &gt; {(thresholdConfig.costApprovalThreshold / 1000000).toFixed(1)}Tr
                </span>
              </div>
            </CardHeader>

            <CardContent className="p-4 space-y-3">
              {pendingSpareParts.length === 0 ? (
                <div className="p-6 text-center text-xs text-slate-500 border border-dashed border-slate-200 rounded-xl bg-white">
                  Không có đề xuất linh kiện đắt tiền nào đang chờ duyệt.
                </div>
              ) : (
                pendingSpareParts.map((spr) => {
                  const isOverThreshold = spr.totalCost >= thresholdConfig.costApprovalThreshold;

                  return (
                    <div
                      key={spr.id}
                      className="p-3.5 rounded-xl bg-white border border-rose-200 shadow-xs space-y-2.5 text-xs"
                    >
                      <div className="flex items-center justify-between">
                        <span className="font-mono text-xs font-bold text-slate-900 px-2 py-0.5 rounded bg-slate-100">
                          {spr.machineCode}
                        </span>
                        <span className="font-extrabold text-rose-700 font-mono text-sm">
                          {spr.totalCost.toLocaleString('vi-VN')} VNĐ
                        </span>
                      </div>

                      <div className="space-y-0.5">
                        <div className="font-bold text-slate-900">
                          {spr.partName} <span className="text-slate-500 font-medium">(Số lượng: {spr.quantity})</span>
                        </div>
                        <p className="text-xs text-slate-600">Lý do: {spr.reason}</p>
                        <p className="text-[10px] text-slate-400 font-medium">Đề xuất bởi: {spr.requestedBy}</p>
                      </div>

                      {isOverThreshold && (
                        <div className="p-2 rounded-lg bg-rose-50 text-rose-900 text-xs font-bold border border-rose-200 flex items-center gap-1.5">
                          <AlertTriangle className="w-3.5 h-3.5 text-rose-600 shrink-0" />
                          <span>Vượt ngưỡng phê duyệt {(thresholdConfig.costApprovalThreshold).toLocaleString('vi-VN')}đ</span>
                        </div>
                      )}

                      <div className="flex items-center gap-2 pt-1">
                        <Button
                          variant="destructive"
                          size="sm"
                          onClick={() => {
                            sound.playClick();
                            setRejectModalPart(spr);
                          }}
                          className="flex-1 h-8 text-xs font-bold"
                        >
                          <XCircle className="w-3.5 h-3.5" />
                          <span>Từ Chối</span>
                        </Button>

                        <Button
                          variant="default"
                          size="sm"
                          onClick={() => {
                            sound.playSuccess();
                            onApproveSparePart(spr.id);
                          }}
                          className="flex-1 h-8 text-xs font-bold bg-emerald-600 hover:bg-emerald-700"
                        >
                          <CheckCircle className="w-3.5 h-3.5" />
                          <span>Phê Duyệt</span>
                        </Button>
                      </div>
                    </div>
                  );
                })
              )}
            </CardContent>
          </Card>

          {/* Box 3: Biểu Đồ Trạng Thái Donut Toàn Phân Xưởng */}
          <Card className="shadow-xs border-slate-200 overflow-hidden">
            <CardHeader className="p-4 pb-3 border-b border-slate-100">
              <CardTitle className="text-xs font-black uppercase tracking-wider text-slate-900 flex items-center gap-2">
                <Layers className="w-4 h-4 text-teal-600" />
                <span>Trạng Thái Thiết Bị Toàn Phân Xưởng</span>
              </CardTitle>
            </CardHeader>

            <CardContent className="p-4">
              <div className="flex items-center justify-between gap-4">
                
                {/* SVG Donut */}
                <div className="relative flex items-center justify-center p-2 shrink-0">
                  <svg className="w-28 h-28 transform -rotate-90" viewBox="0 0 36 36">
                    <path
                      className="text-slate-100"
                      strokeWidth="4"
                      stroke="currentColor"
                      fill="none"
                      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                    />
                    <path
                      className="text-emerald-500 transition-all duration-500"
                      strokeWidth="4"
                      strokeDasharray={`${activePercent}, 100`}
                      stroke="currentColor"
                      fill="none"
                      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                    />
                    <path
                      className="text-rose-500 transition-all duration-500"
                      strokeWidth="4"
                      strokeDasharray={`${repairingPercent}, 100`}
                      strokeDashoffset={`-${activePercent}`}
                      stroke="currentColor"
                      fill="none"
                      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                    />
                    <path
                      className="text-amber-500 transition-all duration-500"
                      strokeWidth="4"
                      strokeDasharray={`${maintenancePercent}, 100`}
                      strokeDashoffset={`-${activePercent + repairingPercent}`}
                      stroke="currentColor"
                      fill="none"
                      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                    />
                  </svg>
                  <div className="absolute inset-0 flex flex-col items-center justify-center text-center">
                    <span className="text-lg font-black text-slate-900 font-mono">{activePercent}%</span>
                    <span className="text-[9px] text-slate-400 font-bold uppercase">Sẵn Sàng</span>
                  </div>
                </div>

                {/* Legend Details */}
                <div className="space-y-1.5 text-xs flex-1">
                  <div className="p-2 rounded-lg bg-emerald-50 text-emerald-900 flex justify-between font-bold">
                    <span className="flex items-center gap-1.5">
                      <span className="w-2 h-2 rounded-full bg-emerald-500" />
                      <span>Hoạt Động:</span>
                    </span>
                    <span className="font-mono">{activeCount} máy</span>
                  </div>

                  <div className="p-2 rounded-lg bg-rose-50 text-rose-900 flex justify-between font-bold">
                    <span className="flex items-center gap-1.5">
                      <span className="w-2 h-2 rounded-full bg-rose-500" />
                      <span>Sự Cố SOS:</span>
                    </span>
                    <span className="font-mono">{repairingCount} máy</span>
                  </div>

                  <div className="p-2 rounded-lg bg-amber-50 text-amber-900 flex justify-between font-bold">
                    <span className="flex items-center gap-1.5">
                      <span className="w-2 h-2 rounded-full bg-amber-500" />
                      <span>Bảo Trì PM:</span>
                    </span>
                    <span className="font-mono">{maintenanceCount} máy</span>
                  </div>
                </div>

              </div>
            </CardContent>
          </Card>

        </div>

      </div>

      {/* ========================================================================= */}
      {/* 4. MODAL: REJECT SPARE PART REASON */}
      {/* ========================================================================= */}
      {rejectModalPart && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
          <div className="w-full max-w-sm bg-white rounded-2xl p-5 shadow-2xl border border-slate-200 animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between border-b border-slate-100 pb-2 mb-3">
              <div className="flex items-center gap-2 text-rose-700 font-black text-sm">
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
                  placeholder="Ví dụ: Đã có sẵn kho phụ tùng dự phòng ở tủ cấp 2, kiểm tra lại gioăng cũ..."
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
