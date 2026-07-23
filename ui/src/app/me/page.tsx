'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import {
  Wrench,
  AlertTriangle,
  CheckCircle2,
  Clock,
  ChevronLeft,
} from 'lucide-react';

import { WorkOrder, PMChecklist, PMChecklistItem } from '../../types';
import { initialWorkOrders, initialPMChecklists } from '../../data/mockData';
import { PMChecklistModal } from '../../components/PMChecklistModal';

export default function MEEngineerPage() {
  const [workOrders, setWorkOrders] = useState<WorkOrder[]>(initialWorkOrders);
  const [checklists, setChecklists] = useState<PMChecklist[]>(initialPMChecklists);
  const [selectedChecklist, setSelectedChecklist] = useState<PMChecklist | null>(null);
  const [activeTab, setActiveTab] = useState<'SOS' | 'PM'>('SOS');

  const handleClaimWorkOrder = (woId: string) => {
    setWorkOrders((prev) =>
      prev.map((wo) =>
        wo.id === woId
          ? { ...wo, status: 'IN_PROGRESS', assigneeName: 'Kỹ Sư ME Trần Minh Đức' }
          : wo
      )
    );
  };

  const handleCompleteWorkOrder = (woId: string) => {
    setWorkOrders((prev) =>
      prev.map((wo) => (wo.id === woId ? { ...wo, status: 'COMPLETED' } : wo))
    );
  };

  const handleCompletePMChecklist = (
    pmId: string,
    items: PMChecklistItem[],
    spareParts: { name: string; quantity: number }[]
  ) => {
    setChecklists((prev) =>
      prev.map((pm) => (pm.id === pmId ? { ...pm, status: 'COMPLETED', items } : pm))
    );
  };

  const pendingSOSCount = workOrders.filter((w) => w.status === 'PENDING').length;
  const inProgressSOSCount = workOrders.filter((w) => w.status === 'IN_PROGRESS').length;

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

        {/* Tab Selector */}
        <div className="px-4 border-b border-slate-200 flex gap-4 bg-white">
          <button
            onClick={() => setActiveTab('SOS')}
            className={`pb-2.5 pt-2 text-xs font-extrabold border-b-2 transition ${
              activeTab === 'SOS'
                ? 'border-cyan-600 text-cyan-700'
                : 'border-transparent text-slate-500 hover:text-slate-900'
            }`}
          >
            Sự Cố Khẩn Cấp ({workOrders.length})
          </button>
          <button
            onClick={() => setActiveTab('PM')}
            className={`pb-2.5 pt-2 text-xs font-extrabold border-b-2 transition ${
              activeTab === 'PM'
                ? 'border-cyan-600 text-cyan-700'
                : 'border-transparent text-slate-500 hover:text-slate-900'
            }`}
          >
            Bảo Trì Định Kỳ ({checklists.length})
          </button>
        </div>

        {/* Body Tasks Feed */}
        <main className="p-4 space-y-3 flex-1 overflow-y-auto pb-10">
          {activeTab === 'SOS' && (
            <div className="space-y-3">
              {workOrders.map((wo) => (
                <div key={wo.id} className="p-4 rounded-2xl bg-white border border-slate-200 shadow-xs space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="font-mono text-xs font-black text-rose-700">{wo.code}</span>
                    <span className={`px-2.5 py-0.5 rounded-full text-[10px] font-extrabold border ${
                      wo.severity === 'CRITICAL' ? 'bg-rose-100 text-rose-800 border-rose-200' : 'bg-orange-100 text-orange-800 border-orange-200'
                    }`}>
                      Nghiêm trọng: {wo.severity}
                    </span>
                  </div>

                  <div>
                    <h3 className="text-sm font-extrabold text-slate-900">{wo.machineName}</h3>
                    <p className="text-xs text-slate-600 mt-1 leading-snug font-medium">{wo.description}</p>
                  </div>

                  {wo.imageUrl && (
                    <img src={wo.imageUrl} alt="Hiện trạng lỗi" className="w-full h-32 object-cover rounded-xl border border-slate-200" />
                  )}

                  <div className="pt-2">
                    {wo.status === 'PENDING' && (
                      <button
                        onClick={() => handleClaimWorkOrder(wo.id)}
                        className="w-full py-2.5 rounded-xl bg-cyan-600 hover:bg-cyan-700 text-white font-extrabold text-xs flex items-center justify-center gap-2 transition shadow-xs"
                      >
                        <Wrench className="w-4 h-4" /> Bấm Tiếp Nhận Sửa Chữa
                      </button>
                    )}

                    {wo.status === 'IN_PROGRESS' && (
                      <button
                        onClick={() => handleCompleteWorkOrder(wo.id)}
                        className="w-full py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-extrabold text-xs flex items-center justify-center gap-2 transition shadow-xs"
                      >
                        <CheckCircle2 className="w-4 h-4" /> Hoàn Thành & Gửi Nghiệm Thu
                      </button>
                    )}

                    {wo.status === 'COMPLETED' && (
                      <div className="p-2.5 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-xs font-bold text-center flex items-center justify-center gap-1.5">
                        <Clock className="w-4 h-4" /> Đã hoàn thành - Đang chờ Quản Đốc ký nghiệm thu
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}

          {activeTab === 'PM' && (
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
                    <button
                      onClick={() => setSelectedChecklist(pm)}
                      className="w-full py-2.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-white font-extrabold text-xs flex items-center justify-center gap-2 transition shadow-xs"
                    >
                      <Wrench className="w-4 h-4" /> Mở Danh Sách PM Checklist
                    </button>
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
          onCompletePM={handleCompletePMChecklist}
        />

      </div>
    </div>
  );
}
