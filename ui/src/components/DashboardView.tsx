'use client';

import React, { useState } from 'react';
import { Sliders, FileSignature, CheckCircle2, AlertTriangle, X, Users } from 'lucide-react';
import { Machine, WorkOrder, PMChecklist, SparePartRequest, SystemThresholdConfig } from '@/types';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';

interface DashboardViewProps {
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
}

export const DashboardView: React.FC<DashboardViewProps> = ({
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
}) => {
  const [timeFilter, setTimeFilter] = useState<'TODAY' | '7DAYS' | '30DAYS'>('TODAY');
  const [rejectModalPart, setRejectModalPart] = useState<SparePartRequest | null>(null);
  const [rejectionReasonInput, setRejectionReasonInput] = useState('');

  const activeCount = machines.filter((m) => m.status === 'ACTIVE').length;
  const repairingCount = machines.filter((m) => m.status === 'REPAIRING').length;
  const maintenanceCount = machines.filter((m) => m.status === 'MAINTENANCE').length;
  const totalMachines = machines.length || 1;

  const activePercent = Math.round((activeCount / totalMachines) * 100);
  const repairingPercent = Math.round((repairingCount / totalMachines) * 100);
  const maintenancePercent = Math.round((maintenanceCount / totalMachines) * 100);

  const pendingApprovalsWO = workOrders.filter((wo) => wo.status === 'COMPLETED');
  const pendingApprovalsPM = checklists.filter((pm) => pm.status === 'COMPLETED');
  const pendingSpareParts = sparePartRequests.filter((spr) => spr.status === 'PENDING');

  const sortedMachines = [...machines].sort((a, b) => b.runningHours - a.runningHours);

  const handleConfirmRejectPart = (e: React.FormEvent) => {
    e.preventDefault();
    if (!rejectModalPart) return;
    if (!rejectionReasonInput.trim()) {
      alert('Vui lòng nhập lý do từ chối!');
      return;
    }
    onRejectSparePart(rejectModalPart.id, rejectionReasonInput.trim());
    setRejectModalPart(null);
    setRejectionReasonInput('');
  };

  return (
    <div className="space-y-3 pb-20">
      
      {/* Top Header Row with System Settings & Time Filter (Wireframe 5.F) */}
      <div className="bg-white p-3.5 rounded-md border border-slate-200 shadow-xs space-y-2.5">
        <div className="flex items-center justify-between gap-2">
          <div>
            <h2 className="text-xs font-black uppercase text-slate-900">{thresholdConfig.workshopName}</h2>
            <p className="text-[11px] text-slate-500 font-medium">
              Ngưỡng duyệt linh kiện: <span className="font-mono font-bold text-emerald-700">{(thresholdConfig.costApprovalThreshold).toLocaleString('vi-VN')} VNĐ</span>
            </p>
          </div>
          <div className="flex items-center gap-1.5 shrink-0">
            {onOpenAddMachine && (
              <Button
                variant="outline"
                size="sm"
                onClick={onOpenAddMachine}
                className="gap-1 text-xs text-emerald-800 bg-emerald-50 border-emerald-300 hover:bg-emerald-100 font-bold"
              >
                + Thêm Máy Mới
              </Button>
            )}
            {onOpenUserManagement && (
              <Button
                variant="outline"
                size="sm"
                onClick={onOpenUserManagement}
                className="gap-1 text-xs text-amber-800 bg-amber-50 border-amber-200 hover:bg-amber-100 font-bold"
              >
                <Users className="w-3.5 h-3.5 text-amber-600" /> Quản Lý Nhân Sự
              </Button>
            )}
            <Button variant="outline" size="sm" onClick={onOpenThresholdConfig} className="gap-1 text-xs">
              <Sliders className="w-3.5 h-3.5 text-amber-600" /> Cấu Hình Ngưỡng
            </Button>
          </div>
        </div>

        {/* Time Filter Buttons (Wireframe 5.F) */}
        <div className="flex items-center justify-between pt-1 border-t border-slate-100">
          <span className="text-[11px] text-slate-500 font-bold uppercase">Bộ lọc thời gian:</span>
          <div className="flex gap-1.5">
            <button
              onClick={() => setTimeFilter('TODAY')}
              className={`px-3 py-1 rounded text-xs font-extrabold transition ${
                timeFilter === 'TODAY'
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
              }`}
            >
              Hôm nay
            </button>
            <button
              onClick={() => setTimeFilter('7DAYS')}
              className={`px-3 py-1 rounded text-xs font-extrabold transition ${
                timeFilter === '7DAYS'
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
              }`}
            >
              7 ngày
            </button>
            <button
              onClick={() => setTimeFilter('30DAYS')}
              className={`px-3 py-1 rounded text-xs font-extrabold transition ${
                timeFilter === '30DAYS'
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
              }`}
            >
              30 ngày
            </button>
          </div>
        </div>
      </div>

      {/* Visual Pie Chart & Status Breakdown (Wireframe 5.F) */}
      <Card>
        <CardHeader className="p-4 pb-2">
          <CardTitle className="text-xs font-extrabold uppercase tracking-wider text-slate-900">
            TRẠNG THÁI PHÂN XƯỞNG (Biểu đồ Tỷ lệ Máy)
          </CardTitle>
        </CardHeader>
        <CardContent className="p-4 pt-1">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 items-center">
            
            {/* SVG Pie / Donut Chart */}
            <div className="relative flex items-center justify-center p-2">
              <svg className="w-36 h-36 transform -rotate-90" viewBox="0 0 36 36">
                <path
                  className="text-slate-100"
                  strokeWidth="3.8"
                  stroke="currentColor"
                  fill="none"
                  d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                />
                {/* Active Segment (Green) */}
                <path
                  className="text-emerald-500 transition-all duration-500"
                  strokeWidth="3.8"
                  strokeDasharray={`${activePercent}, 100`}
                  stroke="currentColor"
                  fill="none"
                  d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                />
                {/* Repairing Segment (Red) */}
                <path
                  className="text-rose-500 transition-all duration-500"
                  strokeWidth="3.8"
                  strokeDasharray={`${repairingPercent}, 100`}
                  strokeDashoffset={`-${activePercent}`}
                  stroke="currentColor"
                  fill="none"
                  d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                />
                {/* Maintenance Segment (Amber) */}
                <path
                  className="text-amber-500 transition-all duration-500"
                  strokeWidth="3.8"
                  strokeDasharray={`${maintenancePercent}, 100`}
                  strokeDashoffset={`-${activePercent + repairingPercent}`}
                  stroke="currentColor"
                  fill="none"
                  d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                />
              </svg>
              <div className="absolute inset-0 flex flex-col items-center justify-center text-center">
                <span className="text-xl font-black text-slate-900 font-mono">{activePercent}%</span>
                <span className="text-[10px] text-slate-500 font-bold uppercase">Khả dụng</span>
              </div>
            </div>

            {/* Legend List */}
            <div className="space-y-2 text-xs">
              <div className="p-2.5 rounded-xl bg-emerald-50 border border-emerald-200 flex items-center justify-between">
                <span className="flex items-center gap-2 font-bold text-emerald-900">
                  <span className="w-3 h-3 rounded-full bg-emerald-500" /> 🟢 Active (Hoạt động):
                </span>
                <span className="font-extrabold font-mono text-emerald-800">{activeCount} máy ({activePercent}%)</span>
              </div>

              <div className="p-2.5 rounded-xl bg-rose-50 border border-rose-200 flex items-center justify-between">
                <span className="flex items-center gap-2 font-bold text-rose-900">
                  <span className="w-3 h-3 rounded-full bg-rose-500" /> 🔴 Repairing (Sự cố SOS):
                </span>
                <span className="font-extrabold font-mono text-rose-800">{repairingCount} máy ({repairingPercent}%)</span>
              </div>

              <div className="p-2.5 rounded-xl bg-amber-50 border border-amber-200 flex items-center justify-between">
                <span className="flex items-center gap-2 font-bold text-amber-900">
                  <span className="w-3 h-3 rounded-full bg-amber-500" /> 🟡 Maintenance (Bảo trì PM):
                </span>
                <span className="font-extrabold font-mono text-amber-800">{maintenanceCount} máy ({maintenancePercent}%)</span>
              </div>
            </div>

          </div>
        </CardContent>
      </Card>

      {/* Visual Downtime Bar Chart (Wireframe 5.F) */}
      <Card>
        <CardHeader className="p-3 pb-1.5">
          <CardTitle className="text-[11px] font-extrabold uppercase tracking-wider text-slate-900 flex items-center justify-between">
            <span>TỔNG DOWNTIME {timeFilter === 'TODAY' ? 'HÔM NAY' : timeFilter === '7DAYS' ? '7 NGÀY QUA' : '30 NGÀY QUA'}: 6h 40m</span>
            <span className="text-rose-600 font-mono">42% Ca</span>
          </CardTitle>
        </CardHeader>
        <CardContent className="p-3 pt-1 space-y-2">
          
          {/* Progress Bar Chart */}
          <div>
            <div className="w-full bg-slate-100 h-3.5 rounded-full overflow-hidden flex border border-slate-200">
              <div className="bg-rose-500 h-full text-[8px] text-white font-bold flex items-center justify-center" style={{ width: '42%' }}>
                SOS (2h 35m)
              </div>
              <div className="bg-amber-500 h-full text-[8px] text-white font-bold flex items-center justify-center" style={{ width: '25%' }}>
                PM (1h 20m)
              </div>
              <div className="bg-slate-300 h-full" style={{ width: '33%' }} />
            </div>
            <div className="flex justify-between text-[9px] text-slate-500 mt-0.5 font-semibold">
              <span>0h</span>
              <span>2h</span>
              <span>4h</span>
              <span>6h</span>
              <span>8h (Ca)</span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 text-[11px] pt-0.5">
            <div className="p-2 rounded-md bg-slate-50 border border-slate-200">
              <span className="text-[9px] text-slate-400 font-bold uppercase block">MTTR (Sửa TB)</span>
              <span className="font-extrabold font-mono text-slate-900 text-xs">32 phút</span>
            </div>
            <div className="p-2 rounded-md bg-slate-50 border border-slate-200">
              <span className="text-[9px] text-slate-400 font-bold uppercase block">MTBF (Thời gian chạy ổn)</span>
              <span className="font-extrabold font-mono text-emerald-700 text-xs">18.5 giờ</span>
            </div>
          </div>

        </CardContent>
      </Card>

      {/* Pending Spare Parts Approval Section (US-07, US-09, Feature 10 / Wireframe 5.H) */}
      {pendingSpareParts.length > 0 && (
        <Card className="border-rose-300 bg-rose-50/40">
          <CardHeader className="p-3.5 pb-2">
            <CardTitle className="text-xs font-extrabold uppercase tracking-wider text-rose-800">
              Đề Xuất Thay Linh Kiện Đắt Tiền Cần Duyệt ({pendingSpareParts.length})
            </CardTitle>
          </CardHeader>
          <CardContent className="p-3.5 pt-0 space-y-2.5">
            {pendingSpareParts.map((spr) => {
              const isOverThreshold = spr.totalCost >= thresholdConfig.costApprovalThreshold;
              return (
                <div key={spr.id} className="p-3 rounded-xl bg-white border border-rose-200 shadow-xs space-y-2 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="font-mono text-xs font-bold text-slate-900">{spr.machineCode}</span>
                    <span className="font-extrabold text-rose-700 font-mono">
                      {spr.totalCost.toLocaleString('vi-VN')} VNĐ
                    </span>
                  </div>

                  <div>
                    <div className="font-bold text-slate-900">{spr.partName} (x{spr.quantity})</div>
                    <p className="text-[11px] text-slate-600 mt-0.5">Lý do: {spr.reason}</p>
                    <span className="text-[10px] text-slate-400">Đề xuất bởi: {spr.requestedBy}</span>
                  </div>

                  {isOverThreshold && (
                    <div className="p-2 rounded-lg bg-rose-100 text-rose-900 text-[10px] font-extrabold border border-rose-300">
                      ⚠ Vượt ngưỡng duyệt chi phí ({(thresholdConfig.costApprovalThreshold / 1000000).toFixed(1)}Tr VNĐ)!
                    </div>
                  )}

                  <div className="flex items-center gap-2 pt-1">
                    <Button
                      variant="destructive"
                      size="sm"
                      onClick={() => setRejectModalPart(spr)}
                      className="flex-1 h-8 text-[11px]"
                    >
                      Từ Chối
                    </Button>
                    <Button
                      variant="default"
                      size="sm"
                      onClick={() => onApproveSparePart(spr.id)}
                      className="flex-1 h-8 text-[11px]"
                    >
                      Phê Duyệt
                    </Button>
                  </div>
                </div>
              );
            })}
          </CardContent>
        </Card>
      )}

      {/* Spare Part Rejection Form Modal (Wireframe 5.H) */}
      {rejectModalPart && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
          <div className="w-full max-w-sm bg-white rounded-2xl p-4 shadow-2xl border border-slate-200 animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between border-b border-slate-100 pb-2 mb-3">
              <div className="flex items-center gap-2 text-rose-700 font-extrabold text-xs">
                <AlertTriangle className="w-4 h-4" /> Từ Chối Đề Xuất Linh Kiện
              </div>
              <button onClick={() => setRejectModalPart(null)} className="p-1 rounded-full text-slate-400 hover:text-slate-700">
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleConfirmRejectPart} className="space-y-3">
              <div className="text-xs text-slate-800">
                Linh kiện: <strong>{rejectModalPart.partName}</strong> ({rejectModalPart.totalCost.toLocaleString('vi-VN')}đ)
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  Nhập lý do từ chối (bắt buộc):
                </label>
                <textarea
                  rows={3}
                  required
                  placeholder="Ví dụ: Đã có sẵn kho phụ tùng dự phòng, đề xuất kiểm tra lại van cũ trước..."
                  value={rejectionReasonInput}
                  onChange={(e) => setRejectionReasonInput(e.target.value)}
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl p-2.5 text-xs text-slate-900 focus:outline-none focus:border-rose-500"
                />
              </div>

              <div className="flex gap-2 pt-1">
                <Button type="button" variant="outline" size="sm" onClick={() => setRejectModalPart(null)} className="flex-1">
                  Hủy
                </Button>
                <Button type="submit" variant="destructive" size="sm" className="flex-1">
                  Xác Nhận Từ Chối
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Pending Approval Section */}
      <Card>
        <CardHeader className="p-4 pb-2">
          <CardTitle className="text-xs font-extrabold uppercase tracking-wider text-slate-900">
            Chờ Quản Đốc Ký Nghiệm Thu ({pendingApprovalsWO.length + pendingApprovalsPM.length})
          </CardTitle>
        </CardHeader>
        <CardContent className="p-4 pt-1 space-y-2">
          {pendingApprovalsWO.length === 0 && pendingApprovalsPM.length === 0 ? (
            <div className="py-6 text-center text-xs text-slate-500 border border-dashed border-slate-200 rounded-xl">
              Không có phiếu nào đang chờ nghiệm thu!
            </div>
          ) : (
            <div className="space-y-2">
              {pendingApprovalsWO.map((wo) => (
                <div key={wo.id} className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-mono text-xs font-bold text-rose-700">{wo.code}</span>
                      <span className="text-slate-900 font-bold">{wo.machineName}</span>
                    </div>
                    <span className="text-[11px] text-slate-500 font-medium">Sửa bởi: {wo.assigneeName || 'ME Engineer'}</span>
                  </div>
                  <Button
                    variant="amber"
                    size="sm"
                    onClick={() => onOpenSignoff(wo.code, `Nghiệm Thu Phiếu SOS: ${wo.code}`, `Ký xác nhận bàn giao máy ${wo.machineCode} trở lại sản xuất`)}
                  >
                    <FileSignature className="w-3.5 h-3.5" /> Ký Nghiệm Thu
                  </Button>
                </div>
              ))}

              {pendingApprovalsPM.map((pm) => (
                <div key={pm.id} className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-mono text-xs font-bold text-amber-700">{pm.code}</span>
                      <span className="text-slate-900 font-bold">{pm.machineName}</span>
                    </div>
                    <span className="text-[11px] text-slate-500 font-medium">Bảo trì mốc {pm.scheduledHours}h</span>
                  </div>
                  <Button
                    variant="default"
                    size="sm"
                    onClick={() => onOpenSignoff(pm.code, `Nghiệm Thu Bảo Trì: ${pm.code}`, `Ký xác nhận hoàn tất PM mốc ${pm.scheduledHours}h cho máy ${pm.machineCode}`)}
                  >
                    <FileSignature className="w-3.5 h-3.5" /> Ký Nghiệm Thu
                  </Button>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Top 5 Machines Downtime & Status Breakdown List (US-10 & Wireframe 5.F) */}
      <Card>
        <CardHeader className="p-4 pb-2">
          <CardTitle className="text-xs font-extrabold uppercase tracking-wider text-slate-600">
            TOP 5 MÁY CÓ DOWNTIME CAO NHẤT
          </CardTitle>
        </CardHeader>
        <CardContent className="p-4 pt-1 space-y-2">
          {sortedMachines.slice(0, 5).map((machine, index) => (
            <div key={machine.id} className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs">
              <div className="flex items-center gap-2.5">
                <span className="w-5 h-5 rounded-full bg-slate-200 text-slate-700 font-bold text-[10px] flex items-center justify-center font-mono">
                  {index + 1}
                </span>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-mono font-extrabold text-emerald-700">{machine.code}</span>
                    <span className="font-bold text-slate-900">{machine.name}</span>
                  </div>
                  <span className="text-[11px] text-slate-500 font-medium">{machine.location}</span>
                </div>
              </div>

              <div className="text-right">
                <span className="font-mono font-bold text-slate-900 block text-xs">
                  {index === 0 ? '2h 35m (SOS)' : index === 1 ? '1h 50m (SOS)' : index === 2 ? '1h 20m (PM)' : '45m (SOS)'}
                </span>
                {machine.status === 'ACTIVE' && (
                  <Badge variant="active">Active</Badge>
                )}
                {machine.status === 'REPAIRING' && (
                  <Badge variant="repairing">Repairing</Badge>
                )}
                {machine.status === 'MAINTENANCE' && (
                  <Badge variant="maintenance">Maintenance</Badge>
                )}
              </div>
            </div>
          ))}
        </CardContent>
      </Card>

    </div>
  );
};
