'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import {
  Wrench,
  AlertTriangle,
  CheckCircle2,
  Clock,
  ChevronLeft,
  Eye,
  Filter,
} from 'lucide-react';

import { WorkOrder, PMChecklist, PMChecklistItem, SparePartItem } from '../../types';
import { initialWorkOrders, initialPMChecklists, initialThresholdConfig } from '../../data/mockData';
import { PMChecklistModal } from '../../components/PMChecklistModal';
import { WorkOrderDetailModal } from '../../components/WorkOrderDetailModal';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';

export default function MEEngineerPage() {
  const [workOrders, setWorkOrders] = useState<WorkOrder[]>(initialWorkOrders);
  const [checklists, setChecklists] = useState<PMChecklist[]>(initialPMChecklists);
  const [selectedChecklist, setSelectedChecklist] = useState<PMChecklist | null>(null);
  const [selectedWorkOrder, setSelectedWorkOrder] = useState<WorkOrder | null>(null);
  
  // Section tabs: SOS vs PM
  const [sectionTab, setSectionTab] = useState<'SOS' | 'PM'>('SOS');
  
  // 4 Work Order Filter Tabs (Wireframe 5.C / US-12): ALL | PENDING | IN_PROGRESS | COMPLETED
  const [statusFilter, setStatusFilter] = useState<'ALL' | 'PENDING' | 'IN_PROGRESS' | 'COMPLETED'>('ALL');

  const handleClaimWorkOrder = (woId: string) => {
    setWorkOrders((prev) =>
      prev.map((wo) =>
        wo.id === woId
          ? { ...wo, status: 'IN_PROGRESS', assigneeName: 'Kỹ Sư ME Trần Minh Đức' }
          : wo
      )
    );
  };

  const handleCompleteWorkOrder = (woId: string, usedParts?: SparePartItem[]) => {
    setWorkOrders((prev) =>
      prev.map((wo) => (wo.id === woId ? { ...wo, status: 'COMPLETED', usedSpareParts: usedParts || wo.usedSpareParts } : wo))
    );
  };

  const handleCancelWorkOrder = (woId: string, reason: string) => {
    setWorkOrders((prev) =>
      prev.map((wo) => (wo.id === woId ? { ...wo, status: 'CANCELLED', cancellationReason: reason } : wo))
    );
  };

  const handleAddSparePartToWO = (woId: string, part: SparePartItem) => {
    setWorkOrders((prev) =>
      prev.map((wo) => {
        if (wo.id === woId) {
          const updated = [...(wo.usedSpareParts || []), part];
          return { ...wo, usedSpareParts: updated };
        }
        return wo;
      })
    );
    if (selectedWorkOrder?.id === woId) {
      setSelectedWorkOrder((prev) =>
        prev ? { ...prev, usedSpareParts: [...(prev.usedSpareParts || []), part] } : null
      );
    }
  };

  const handleCompletePMChecklist = (
    pmId: string,
    items: PMChecklistItem[],
    spareParts: SparePartItem[]
  ) => {
    setChecklists((prev) =>
      prev.map((pm) => (pm.id === pmId ? { ...pm, status: 'COMPLETED', items } : pm))
    );
  };

  // Filter Work Orders according to Wireframe 5.C 4 Status Tabs
  const filteredWorkOrders = workOrders.filter((wo) => {
    if (statusFilter === 'PENDING') return wo.status === 'PENDING';
    if (statusFilter === 'IN_PROGRESS') return wo.status === 'IN_PROGRESS' || wo.status === 'REJECTED';
    if (statusFilter === 'COMPLETED') return wo.status === 'COMPLETED' || wo.status === 'APPROVED';
    return true; // ALL
  });

  const pendingSOSCount = workOrders.filter((w) => w.status === 'PENDING').length;
  const inProgressSOSCount = workOrders.filter((w) => w.status === 'IN_PROGRESS' || w.status === 'REJECTED').length;

  return (
    <div className="min-h-screen bg-slate-100 text-slate-900 flex flex-col font-sans selection:bg-cyan-500 selection:text-white">
      <div className="w-full max-w-md mx-auto min-h-screen bg-slate-50 flex flex-col relative border-x border-slate-200 shadow-2xl">
        
        {/* Header */}
        <header className="p-4 bg-white border-b border-slate-200 flex items-center justify-between sticky top-0 z-30 backdrop-blur-md bg-white/90 shadow-xs">
          <div className="flex items-center gap-3">
            <Link
              href="/"
              className="p-2 rounded-xl bg-slate-100 text-slate-600 hover:text-slate-900 transition"
            >
              <ChevronLeft className="w-5 h-5" />
            </Link>
            <div>
              <div className="flex items-center gap-1.5 text-cyan-700 font-extrabold text-xs">
                <Wrench className="w-4 h-4 text-cyan-600" />
                <span>Trang Kỹ Sư Cơ Điện (ME)</span>
              </div>
              <h1 className="text-sm font-extrabold text-slate-900">Bảo Trì & Sửa Chữa Sự Cố</h1>
            </div>
          </div>

          <div className="w-8 h-8 rounded-full bg-cyan-100 text-cyan-800 border border-cyan-200 flex items-center justify-center font-black text-xs">
            ME
          </div>
        </header>

        {/* Quick Stats */}
        <div className="p-4 grid grid-cols-2 gap-2.5">
          <div className="p-3.5 rounded-2xl bg-white border border-slate-200 shadow-xs">
            <span className="text-[11px] text-slate-500 font-bold uppercase">Chờ Tiếp Nhận</span>
            <div className="text-2xl font-black font-mono text-rose-700">{pendingSOSCount} <span className="text-xs text-slate-500 font-normal">SOS</span></div>
          </div>
          <div className="p-3.5 rounded-2xl bg-white border border-slate-200 shadow-xs">
            <span className="text-[11px] text-slate-500 font-bold uppercase">Đang Xử Lý</span>
            <div className="text-2xl font-black font-mono text-cyan-700">{inProgressSOSCount} <span className="text-xs text-slate-500 font-normal">Máy</span></div>
          </div>
        </div>

        {/* Section Selector: SOS vs PM */}
        <div className="px-4 border-b border-slate-200 flex gap-4 bg-white">
          <button
            onClick={() => setSectionTab('SOS')}
            className={`pb-2.5 pt-2 text-xs font-extrabold border-b-2 transition ${
              sectionTab === 'SOS'
                ? 'border-cyan-600 text-cyan-700'
                : 'border-transparent text-slate-500 hover:text-slate-900'
            }`}
          >
            Sự Cố Khẩn Cấp ({workOrders.length})
          </button>
          <button
            onClick={() => setSectionTab('PM')}
            className={`pb-2.5 pt-2 text-xs font-extrabold border-b-2 transition ${
              sectionTab === 'PM'
                ? 'border-cyan-600 text-cyan-700'
                : 'border-transparent text-slate-500 hover:text-slate-900'
            }`}
          >
            Bảo Trì Định Kỳ ({checklists.length})
          </button>
        </div>

        {/* 4 WORK ORDER FILTER TABS (Wireframe 5.C: [Tất cả] [Chờ] [Xử lý] [Xong]) */}
        {sectionTab === 'SOS' && (
          <div className="px-4 pt-3 pb-1 bg-slate-50 flex items-center gap-1.5 overflow-x-auto">
            <button
              onClick={() => setStatusFilter('ALL')}
              className={`px-3 py-1.5 rounded-xl text-xs font-extrabold transition shrink-0 ${
                statusFilter === 'ALL'
                  ? 'bg-slate-900 text-white shadow-xs'
                  : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-100'
              }`}
            >
              Tất cả ({workOrders.length})
            </button>

            <button
              onClick={() => setStatusFilter('PENDING')}
              className={`px-3 py-1.5 rounded-xl text-xs font-extrabold transition shrink-0 ${
                statusFilter === 'PENDING'
                  ? 'bg-rose-600 text-white shadow-xs'
                  : 'bg-white text-rose-700 border border-rose-200 hover:bg-rose-50'
              }`}
            >
              Chờ tiếp nhận ({workOrders.filter((w) => w.status === 'PENDING').length})
            </button>

            <button
              onClick={() => setStatusFilter('IN_PROGRESS')}
              className={`px-3 py-1.5 rounded-xl text-xs font-extrabold transition shrink-0 ${
                statusFilter === 'IN_PROGRESS'
                  ? 'bg-cyan-600 text-white shadow-xs'
                  : 'bg-white text-cyan-700 border border-cyan-200 hover:bg-cyan-50'
              }`}
            >
              Đang xử lý ({workOrders.filter((w) => w.status === 'IN_PROGRESS' || w.status === 'REJECTED').length})
            </button>

            <button
              onClick={() => setStatusFilter('COMPLETED')}
              className={`px-3 py-1.5 rounded-xl text-xs font-extrabold transition shrink-0 ${
                statusFilter === 'COMPLETED'
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'bg-white text-emerald-700 border border-emerald-200 hover:bg-emerald-50'
              }`}
            >
              Hoàn thành ({workOrders.filter((w) => w.status === 'COMPLETED' || w.status === 'APPROVED').length})
            </button>
          </div>
        )}

        {/* Body Tasks Feed */}
        <main className="p-4 space-y-3 flex-1 overflow-y-auto pb-10">
          {sectionTab === 'SOS' && (
            <div className="space-y-3">
              {filteredWorkOrders.length === 0 ? (
                <div className="py-8 text-center text-xs text-slate-500 border border-dashed border-slate-200 rounded-2xl bg-white">
                  Không có phiếu SOS nào thuộc trạng thái đã chọn!
                </div>
              ) : (
                filteredWorkOrders.map((wo) => (
                  <div
                    key={wo.id}
                    onClick={() => setSelectedWorkOrder(wo)}
                    className="p-4 rounded-2xl bg-white border border-slate-200 shadow-xs space-y-3 cursor-pointer hover:border-cyan-300 transition"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-xs font-black text-rose-700">{wo.code}</span>
                        <Eye className="w-3.5 h-3.5 text-slate-400" />
                      </div>
                      <Badge variant={wo.severity === 'CRITICAL' ? 'destructive' : 'maintenance'}>
                        Nghiêm trọng: {wo.severity}
                      </Badge>
                    </div>

                    <div>
                      <h3 className="text-sm font-extrabold text-slate-900">{wo.machineName}</h3>
                      <p className="text-xs text-slate-600 mt-1 leading-snug font-medium line-clamp-2">{wo.description}</p>
                    </div>

                    {wo.imageUrl && (
                      <img src={wo.imageUrl} alt="Hiện trạng lỗi" className="w-full h-32 object-cover rounded-xl border border-slate-200" />
                    )}

                    {wo.rejectionReason && (
                      <div className="p-2 rounded-lg bg-rose-100 border border-rose-300 text-rose-800 text-[11px] font-bold">
                        ⚠️ Supervisor từ chối nghiệm thu: {wo.rejectionReason}
                      </div>
                    )}

                    <div className="pt-1">
                      {wo.status === 'PENDING' && (
                        <Button
                          variant="cyan"
                          size="sm"
                          onClick={(e) => {
                            e.stopPropagation();
                            handleClaimWorkOrder(wo.id);
                          }}
                          className="w-full"
                        >
                          <Wrench className="w-4 h-4" /> Bấm Tiếp Nhận Sửa Chữa
                        </Button>
                      )}

                      {(wo.status === 'IN_PROGRESS' || wo.status === 'REJECTED') && (
                        <Button
                          variant="default"
                          size="sm"
                          onClick={(e) => {
                            e.stopPropagation();
                            handleCompleteWorkOrder(wo.id);
                          }}
                          className="w-full"
                        >
                          <CheckCircle2 className="w-4 h-4" /> Hoàn Thành & Gửi Nghiệm Thu
                        </Button>
                      )}

                      {wo.status === 'COMPLETED' && (
                        <div className="p-2.5 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-xs font-bold text-center flex items-center justify-center gap-1.5">
                          <Clock className="w-4 h-4" /> Đã hoàn thành - Đang chờ Quản Đốc ký nghiệm thu
                        </div>
                      )}
                    </div>
                  </div>
                ))
              )}
            </div>
          )}

          {sectionTab === 'PM' && (
            <div className="space-y-3">
              {checklists.map((pm) => (
                <div key={pm.id} className="p-4 rounded-2xl bg-white border border-slate-200 shadow-xs space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="font-mono text-xs font-bold text-amber-700">{pm.code}</span>
                    <span className="text-xs text-slate-500 font-medium">Mốc {pm.scheduledHours}h</span>
                  </div>

                  <h3 className="text-sm font-extrabold text-slate-900">{pm.machineName}</h3>
                  <p className="text-xs text-slate-600 font-medium">Tổng số hạng mục kiểm tra: {pm.items.length} công việc</p>

                  <div className="pt-2">
                    <Button
                      variant="amber"
                      size="sm"
                      onClick={() => setSelectedChecklist(pm)}
                      className="w-full"
                    >
                      <Wrench className="w-4 h-4" /> Mở Danh Sách PM Checklist
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </main>

        <PMChecklistModal
          checklist={selectedChecklist}
          isOpen={!!selectedChecklist}
          onClose={() => setSelectedChecklist(null)}
          costApprovalThreshold={initialThresholdConfig.costApprovalThreshold}
          onCompletePM={handleCompletePMChecklist}
        />

        <WorkOrderDetailModal
          workOrder={selectedWorkOrder}
          isOpen={!!selectedWorkOrder}
          onClose={() => setSelectedWorkOrder(null)}
          costApprovalThreshold={initialThresholdConfig.costApprovalThreshold}
          onClaimWorkOrder={handleClaimWorkOrder}
          onCompleteWorkOrder={handleCompleteWorkOrder}
          onAddSparePartToWO={handleAddSparePartToWO}
          onCancelWorkOrder={handleCancelWorkOrder}
        />

      </div>
    </div>
  );
}
