'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import {
  ShieldCheck,
  ChevronLeft,
  Activity,
  Clock,
  TrendingUp,
  FileSignature,
  CheckCircle2,
  Users,
  UserPlus,
} from 'lucide-react';

import { WorkOrder, PMChecklist, Machine } from '../../types';
import { initialWorkOrders, initialPMChecklists, initialMachines } from '../../data/mockData';
import { DigitalSignoffModal } from '../../components/DigitalSignoffModal';
import { UserManagementModal } from '../../components/UserManagementModal';

export default function SupervisorPage() {
  const [machines, setMachines] = useState<Machine[]>(initialMachines);
  const [workOrders, setWorkOrders] = useState<WorkOrder[]>(initialWorkOrders);
  const [checklists, setChecklists] = useState<PMChecklist[]>(initialPMChecklists);
  const [isUserManagementOpen, setIsUserManagementOpen] = useState(false);

  const [signoffData, setSignoffData] = useState<{
    isOpen: boolean;
    itemCode: string;
    title: string;
    subtitle: string;
  }>({
    isOpen: false,
    itemCode: '',
    title: '',
    subtitle: '',
  });

  const activeCount = machines.filter((m) => m.status === 'ACTIVE').length;
  const repairingCount = machines.filter((m) => m.status === 'REPAIRING').length;
  const maintenanceCount = machines.filter((m) => m.status === 'MAINTENANCE').length;

  const pendingApprovalsWO = workOrders.filter((wo) => wo.status === 'COMPLETED');
  const pendingApprovalsPM = checklists.filter((pm) => pm.status === 'COMPLETED');

  const handleConfirmSign = (signatureUrl: string) => {
    const code = signoffData.itemCode;
    setWorkOrders((prev) =>
      prev.map((wo) => {
        if (wo.code === code) {
          setMachines((mPrev) =>
            mPrev.map((m) => (m.id === wo.machineId ? { ...m, status: 'ACTIVE' } : m))
          );
          return { ...wo, status: 'APPROVED', supervisorSignatureUrl: signatureUrl };
        }
        return wo;
      })
    );

    setChecklists((prev) =>
      prev.map((pm) => {
        if (pm.code === code) {
          setMachines((mPrev) =>
            mPrev.map((m) => (m.id === pm.machineId ? { ...m, status: 'ACTIVE' } : m))
          );
          return { ...pm, status: 'APPROVED', supervisorSignatureUrl: signatureUrl };
        }
        return pm;
      })
    );
  };

  const handleRejectSign = (reason: string) => {
    const code = signoffData.itemCode;
    setWorkOrders((prev) =>
      prev.map((wo) => (wo.code === code ? { ...wo, status: 'REJECTED', rejectionReason: reason } : wo))
    );
    setChecklists((prev) =>
      prev.map((pm) => (pm.code === code ? { ...pm, status: 'REJECTED', rejectionReason: reason } : pm))
    );
  };

  return (
    <div className="min-h-screen bg-slate-100 text-slate-900 flex flex-col font-sans selection:bg-amber-500 selection:text-white">
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
              <div className="flex items-center gap-1.5 text-amber-700 font-extrabold text-xs">
                <ShieldCheck className="w-4 h-4 text-amber-600" />
                <span>Trang Quản Đốc Phân Xưởng</span>
              </div>
              <h1 className="text-sm font-extrabold text-slate-900">Giám Sát & Nghiệm Thu Điện Tử</h1>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => setIsUserManagementOpen(true)}
              className="p-2 rounded-xl bg-amber-50 text-amber-700 border border-amber-200 hover:bg-amber-100 font-extrabold text-xs flex items-center gap-1.5 transition"
              title="Quản Lý Nhân Sự Phân Xưởng"
            >
              <Users className="w-4 h-4 text-amber-600" />
              <span className="hidden sm:inline">Quản Lý Nhân Sự</span>
            </button>

            <div className="w-8 h-8 rounded-full bg-amber-100 text-amber-800 border border-amber-200 flex items-center justify-center font-black text-xs">
              QĐ
            </div>
          </div>
        </header>

        {/* Dashboard Analytics Grid */}
        <div className="p-4 space-y-4 flex-1 overflow-y-auto pb-10">

          {/* Banner Quản Lý Nhân Sự Quick Banner */}
          <div className="p-3.5 rounded-2xl bg-gradient-to-r from-amber-500 to-amber-600 text-white shadow-xs flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="p-2 rounded-xl bg-white/20 backdrop-blur-md text-white">
                <UserPlus className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-xs font-extrabold">Quản Lý Nhân Sự Phân Xưởng</h2>
                <p className="text-[10px] text-amber-100 font-medium">Cấp tài khoản thủ công hoặc Import file Excel hàng loạt</p>
              </div>
            </div>
            <button
              onClick={() => setIsUserManagementOpen(true)}
              className="px-3 py-1.5 rounded-xl bg-white text-amber-900 font-extrabold text-xs shadow-xs hover:bg-amber-50 transition shrink-0"
            >
              Quản Lý
            </button>
          </div>
          
          <div className="grid grid-cols-2 gap-2.5">
            <div className="p-3.5 rounded-2xl bg-white border border-slate-200 shadow-xs">
              <span className="text-[11px] text-slate-500 font-bold uppercase block mb-1">Máy Hoạt Động</span>
              <div className="text-2xl font-black font-mono text-emerald-700">
                {activeCount} <span className="text-xs text-slate-500 font-normal">/ {machines.length}</span>
              </div>
            </div>

            <div className="p-3.5 rounded-2xl bg-white border border-slate-200 shadow-xs">
              <span className="text-[11px] text-slate-500 font-bold uppercase block mb-1">Sự Cố & Bảo Trì</span>
              <div className="text-2xl font-black font-mono text-rose-700">
                {repairingCount + maintenanceCount} <span className="text-xs text-slate-500 font-normal">Máy</span>
              </div>
            </div>

            <div className="p-3.5 rounded-2xl bg-white border border-slate-200 shadow-xs">
              <span className="text-[11px] text-slate-500 font-bold uppercase block mb-1">Tổng Downtime Ca</span>
              <div className="text-xl font-black font-mono text-sky-700">1h 45m</div>
            </div>

            <div className="p-3.5 rounded-2xl bg-white border border-slate-200 shadow-xs">
              <span className="text-[11px] text-slate-500 font-bold uppercase block mb-1">Hiệu Suất OEE</span>
              <div className="text-xl font-black font-mono text-amber-700">94.2%</div>
            </div>
          </div>

          {/* Pending Sign-off Section */}
          <div className="p-4 rounded-2xl bg-white border border-slate-200 shadow-xs space-y-3">
            <div className="flex items-center gap-2">
              <div className="p-1.5 rounded-lg bg-amber-50 text-amber-700 border border-amber-200">
                <FileSignature className="w-4 h-4" />
              </div>
              <h2 className="text-xs font-extrabold uppercase tracking-wider text-slate-900">
                Danh Sách Chờ Ký Nghiệm Thu ({pendingApprovalsWO.length + pendingApprovalsPM.length})
              </h2>
            </div>

            {pendingApprovalsWO.length === 0 && pendingApprovalsPM.length === 0 ? (
              <div className="p-6 text-center text-xs text-slate-500 border border-dashed border-slate-200 rounded-xl">
                <CheckCircle2 className="w-6 h-6 text-emerald-600 mx-auto mb-1 opacity-80" />
                Hiện tại không có phiếu nào chờ nghiệm thu.
              </div>
            ) : (
              <div className="space-y-2.5">
                {pendingApprovalsWO.map((wo) => (
                  <div key={wo.id} className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs">
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-xs font-bold text-rose-700">{wo.code}</span>
                        <span className="text-slate-900 font-extrabold">{wo.machineName}</span>
                      </div>
                      <span className="text-[11px] text-slate-500 font-medium block mt-0.5">Sửa xong bởi: {wo.assigneeName || 'ME Engineer'}</span>
                    </div>

                    <button
                      onClick={() =>
                        setSignoffData({
                          isOpen: true,
                          itemCode: wo.code,
                          title: `Nghiệm Thu Phiếu SOS: ${wo.code}`,
                          subtitle: `Ký tên xác nhận nghiệm thu bàn giao máy ${wo.machineCode} trở lại hoạt động`,
                        })
                      }
                      className="px-3 py-1.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-white font-extrabold text-xs flex items-center gap-1 shadow-xs transition"
                    >
                      <FileSignature className="w-3.5 h-3.5" /> Ký Nghiệm Thu
                    </button>
                  </div>
                ))}

                {pendingApprovalsPM.map((pm) => (
                  <div key={pm.id} className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs">
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-xs font-bold text-amber-700">{pm.code}</span>
                        <span className="text-slate-900 font-extrabold">{pm.machineName}</span>
                      </div>
                      <span className="text-[11px] text-slate-500 font-medium block mt-0.5">Bảo trì mốc {pm.scheduledHours}h</span>
                    </div>

                    <button
                      onClick={() =>
                        setSignoffData({
                          isOpen: true,
                          itemCode: pm.code,
                          title: `Nghiệm Thu Bảo Trì: ${pm.code}`,
                          subtitle: `Ký tên xác nhận nghiệm thu đợt PM mốc ${pm.scheduledHours}h cho máy ${pm.machineCode}`,
                        })
                      }
                      className="px-3 py-1.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-extrabold text-xs flex items-center gap-1 shadow-xs transition"
                    >
                      <FileSignature className="w-3.5 h-3.5" /> Ký Nghiệm Thu
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Machine Inventory & Status Overview */}
          <div className="p-4 rounded-2xl bg-white border border-slate-200 shadow-xs space-y-3">
            <h2 className="text-xs font-extrabold uppercase tracking-wider text-slate-600">
              Trạng Thái Máy Móc Toàn Nhà Máy
            </h2>
            <div className="space-y-2">
              {machines.map((m) => (
                <div key={m.id} className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-extrabold text-emerald-700">{m.code}</span>
                      <span className="font-bold text-slate-900">{m.name}</span>
                    </div>
                    <span className="text-[11px] text-slate-500 font-medium">{m.location}</span>
                  </div>

                  <div>
                    {m.status === 'ACTIVE' && (
                      <span className="px-2.5 py-0.5 rounded-full text-[10px] font-extrabold bg-emerald-100 text-emerald-800 border border-emerald-200">
                        ● Hoạt động ({m.runningHours}h)
                      </span>
                    )}
                    {m.status === 'REPAIRING' && (
                      <span className="px-2.5 py-0.5 rounded-full text-[10px] font-extrabold bg-rose-100 text-rose-800 border border-rose-200">
                        ● Đang sửa SOS
                      </span>
                    )}
                    {m.status === 'MAINTENANCE' && (
                      <span className="px-2.5 py-0.5 rounded-full text-[10px] font-extrabold bg-amber-100 text-amber-800 border border-amber-200">
                        ● Đang bảo trì PM
                      </span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>

        </div>

        {/* Signature Modal with Work Summary Box (Wireframe 5.E) */}
        <DigitalSignoffModal
          isOpen={signoffData.isOpen}
          onClose={() => setSignoffData((prev) => ({ ...prev, isOpen: false }))}
          onConfirmSign={handleConfirmSign}
          onReject={handleRejectSign}
          title={signoffData.title}
          subtitle={signoffData.subtitle}
          itemCode={signoffData.itemCode}
          workSummary={(() => {
            const wo = workOrders.find((w) => w.code === signoffData.itemCode);
            const pm = checklists.find((p) => p.code === signoffData.itemCode);
            if (wo) {
              return {
                machineName: wo.machineName,
                machineCode: wo.machineCode,
                engineerName: wo.assigneeName || 'Trần Minh Đức (ME)',
                downtimeDuration: '2h 35m',
                spareParts: wo.usedSpareParts?.map((sp) => ({ name: sp.name, quantity: sp.quantity })),
              };
            }
            if (pm) {
              return {
                machineName: pm.machineName,
                machineCode: pm.machineCode,
                engineerName: pm.assigneeName || 'Trần Minh Đức (ME)',
                downtimeDuration: '1h 20m',
                spareParts: [{ name: 'Dầu bôi trơn & Bộ lọc PM', quantity: 1 }],
              };
            }
            return undefined;
          })()}
        />

        {/* User Management & Batch Excel Import Modal */}
        <UserManagementModal
          isOpen={isUserManagementOpen}
          onClose={() => setIsUserManagementOpen(false)}
        />

      </div>
    </div>
  );
}
