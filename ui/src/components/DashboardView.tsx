'use client';

import React from 'react';
import { Activity, Clock, Wrench, CheckCircle2, TrendingUp, AlertTriangle, FileSignature, Sliders, DollarSign, XCircle, ShieldAlert } from 'lucide-react';
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
  onApproveSparePart,
  onRejectSparePart,
}) => {
  const activeCount = machines.filter((m) => m.status === 'ACTIVE').length;
  const repairingCount = machines.filter((m) => m.status === 'REPAIRING').length;
  const maintenanceCount = machines.filter((m) => m.status === 'MAINTENANCE').length;

  const pendingApprovalsWO = workOrders.filter((wo) => wo.status === 'COMPLETED');
  const pendingApprovalsPM = checklists.filter((pm) => pm.status === 'COMPLETED');
  const pendingSpareParts = sparePartRequests.filter((spr) => spr.status === 'PENDING');

  // Calculate top machines with running hours/downtime
  const sortedMachines = [...machines].sort((a, b) => b.runningHours - a.runningHours);

  return (
    <div className="space-y-4 pb-20">
      
      {/* Top Header Row with System Settings Button */}
      <div className="flex items-center justify-between bg-white p-3 rounded-2xl border border-slate-200 shadow-xs">
        <div>
          <h2 className="text-xs font-black uppercase text-slate-900">{thresholdConfig.workshopName}</h2>
          <p className="text-[11px] text-slate-500 font-medium">
            Ngưỡng duyệt linh kiện: <span className="font-mono font-bold text-emerald-700">{(thresholdConfig.costApprovalThreshold).toLocaleString('vi-VN')} VNĐ</span>
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={onOpenThresholdConfig} className="gap-1 text-xs">
          <Sliders className="w-3.5 h-3.5 text-amber-600" /> Cấu Hình Ngưỡng
        </Button>
      </div>

      {/* Overview Stat Cards using shadcn Card */}
      <div className="grid grid-cols-2 gap-2.5">
        <Card>
          <CardHeader className="p-3.5 pb-1 flex flex-row items-center justify-between space-y-0">
            <span className="text-xs text-slate-500 font-semibold">Máy Hoạt Động</span>
            <Activity className="w-4 h-4 text-emerald-600" />
          </CardHeader>
          <CardContent className="p-3.5 pt-0">
            <div className="text-2xl font-black font-mono text-emerald-700">
              {activeCount} <span className="text-xs text-slate-500 font-normal">/ {machines.length}</span>
            </div>
            <div className="text-[11px] text-slate-500 font-medium mt-1 flex items-center gap-1">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" /> Tỷ lệ: {Math.round((activeCount / (machines.length || 1)) * 100)}%
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="p-3.5 pb-1 flex flex-row items-center justify-between space-y-0">
            <span className="text-xs text-slate-500 font-semibold">Đang Sửa/Bảo Trì</span>
            <AlertTriangle className="w-4 h-4 text-rose-600" />
          </CardHeader>
          <CardContent className="p-3.5 pt-0">
            <div className="text-2xl font-black font-mono text-rose-700">
              {repairingCount + maintenanceCount} <span className="text-xs text-slate-500 font-normal">Máy</span>
            </div>
            <div className="text-[11px] text-slate-500 mt-1 flex items-center gap-1 font-medium">
              <span className="text-rose-600 font-bold">{repairingCount} SOS</span> • <span className="text-amber-600 font-bold">{maintenanceCount} PM</span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="p-3.5 pb-1 flex flex-row items-center justify-between space-y-0">
            <span className="text-xs text-slate-500 font-semibold">Tổng Downtime Ca</span>
            <Clock className="w-4 h-4 text-sky-600" />
          </CardHeader>
          <CardContent className="p-3.5 pt-0">
            <div className="text-xl font-black font-mono text-sky-700">1h 45m</div>
            <div className="text-[11px] text-slate-500 mt-1 font-medium">
              MTTR Trung Bình: <span className="text-slate-900 font-bold">32 phút</span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="p-3.5 pb-1 flex flex-row items-center justify-between space-y-0">
            <span className="text-xs text-slate-500 font-semibold">Hiệu Suất OEE</span>
            <TrendingUp className="w-4 h-4 text-amber-600" />
          </CardHeader>
          <CardContent className="p-3.5 pt-0">
            <div className="text-xl font-black font-mono text-amber-700">94.2%</div>
            <div className="text-[11px] text-slate-500 mt-1 font-medium">
              Mục tiêu ca: <span className="text-slate-900 font-bold">&gt; 90%</span>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Pending Spare Parts Approval Section (US-07, US-09, Feature 10) */}
      {pendingSpareParts.length > 0 && (
        <Card className="border-rose-300 bg-rose-50/40">
          <CardHeader className="p-3.5 pb-2">
            <div className="flex items-center gap-2 text-rose-800">
              <ShieldAlert className="w-4 h-4 text-rose-600 animate-bounce" />
              <CardTitle className="text-xs font-extrabold uppercase tracking-wider">
                Đề Xuất Thay Linh Kiện Đắt Tiền Cần Duyệt ({pendingSpareParts.length})
              </CardTitle>
            </div>
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
                    <div className="p-2 rounded-lg bg-rose-100 text-rose-900 text-[10px] font-extrabold border border-rose-300 flex items-center gap-1">
                      <AlertTriangle className="w-3.5 h-3.5 text-rose-600" />
                      Vượt ngưỡng duyệt chi phí ({(thresholdConfig.costApprovalThreshold / 1000000).toFixed(1)}Tr VNĐ)!
                    </div>
                  )}

                  <div className="flex items-center gap-2 pt-1">
                    <Button
                      variant="destructive"
                      size="sm"
                      onClick={() => {
                        const r = prompt('Nhập lý do từ chối đề xuất linh kiện này:');
                        if (r) onRejectSparePart(spr.id, r);
                      }}
                      className="flex-1 h-8 text-[11px]"
                    >
                      <XCircle className="w-3.5 h-3.5" /> Từ Chối
                    </Button>
                    <Button
                      variant="default"
                      size="sm"
                      onClick={() => onApproveSparePart(spr.id)}
                      className="flex-1 h-8 text-[11px]"
                    >
                      <CheckCircle2 className="w-3.5 h-3.5" /> Phê Duyệt
                    </Button>
                  </div>
                </div>
              );
            })}
          </CardContent>
        </Card>
      )}

      {/* Pending Approval Section */}
      <Card>
        <CardHeader className="p-4 pb-2">
          <div className="flex items-center gap-2">
            <div className="p-1.5 rounded-lg bg-amber-50 text-amber-700 border border-amber-200">
              <FileSignature className="w-4 h-4" />
            </div>
            <CardTitle className="text-xs font-extrabold uppercase tracking-wider text-slate-900">
              Chờ Quản Đốc Ký Nghiệm Thu ({pendingApprovalsWO.length + pendingApprovalsPM.length})
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="p-4 pt-1 space-y-2">
          {pendingApprovalsWO.length === 0 && pendingApprovalsPM.length === 0 ? (
            <div className="py-6 text-center text-xs text-slate-500 border border-dashed border-slate-200 rounded-xl">
              <CheckCircle2 className="w-6 h-6 text-emerald-600 mx-auto mb-1 opacity-80" />
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

      {/* Top 5 Machines Downtime & Status Breakdown List (US-10) */}
      <Card>
        <CardHeader className="p-4 pb-2">
          <CardTitle className="text-xs font-extrabold uppercase tracking-wider text-slate-600">
            Top Máy Tích Lũy Số Giờ Chạy & Trạng Thái
          </CardTitle>
        </CardHeader>
        <CardContent className="p-4 pt-1 space-y-2">
          {sortedMachines.map((machine, index) => (
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

              <div>
                {machine.status === 'ACTIVE' && (
                  <Badge variant="active">Active ({machine.runningHours}h)</Badge>
                )}
                {machine.status === 'REPAIRING' && (
                  <Badge variant="repairing">Repairing (SOS)</Badge>
                )}
                {machine.status === 'MAINTENANCE' && (
                  <Badge variant="maintenance">PM Maintenance</Badge>
                )}
              </div>
            </div>
          ))}
        </CardContent>
      </Card>

    </div>
  );
};
