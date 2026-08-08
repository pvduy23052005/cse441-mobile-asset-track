'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import {
  HardHat,
  ChevronLeft,
  QrCode,
  AlertTriangle,
  ChevronRight,
  Cpu,
  XCircle,
} from 'lucide-react';

import { Machine, WorkOrder } from '../../types';
import { initialMachines, initialWorkOrders } from '../../data/mockData';
import { QRScannerModal } from '../../components/QRScannerModal';
import { MachinePassportModal } from '../../components/MachinePassportModal';
import { SOSFormModal } from '../../components/SOSFormModal';
import { PhoneDeviceFrame } from '../../components/PhoneDeviceFrame';
import { Button } from '@/components/ui/button';

export default function OperatorPage() {
  const [machines, setMachines] = useState<Machine[]>(initialMachines);
  const [workOrders, setWorkOrders] = useState<WorkOrder[]>(initialWorkOrders);

  const [isQRScannerOpen, setIsQRScannerOpen] = useState(false);
  const [passportMachine, setPassportMachine] = useState<Machine | null>(null);
  const [sosMachine, setSosMachine] = useState<Machine | null>(null);

  const handleUpdateHours = (machineId: string, newHours: number) => {
    setMachines((prev) =>
      prev.map((m) => {
        if (m.id === machineId) {
          const updated = { ...m, runningHours: newHours };
          setPassportMachine(updated);
          return updated;
        }
        return m;
      })
    );
  };

  const handleCreateSOS = (data: {
    machineId: string;
    machineName: string;
    machineCode: string;
    severity: any;
    description: string;
    imageUrl?: string;
  }) => {
    const newWO: WorkOrder = {
      id: `wo-${Date.now()}`,
      code: `SOS-${Math.floor(100 + Math.random() * 900)}`,
      machineId: data.machineId,
      machineName: data.machineName,
      machineCode: data.machineCode,
      reporterId: 'usr-op-01',
      reporterName: 'Nguyễn Văn Nam',
      severity: data.severity,
      description: data.description,
      imageUrl: data.imageUrl,
      status: 'PENDING',
      downtimeStart: new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }),
      createdAt: new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }),
    };

    setWorkOrders((prev) => [newWO, ...prev]);

    setMachines((prev) =>
      prev.map((m) => (m.id === data.machineId ? { ...m, status: 'REPAIRING' } : m))
    );
  };

  const handleCancelWorkOrder = (woId: string) => {
    const reason = prompt('Nhập lý do hủy phiếu SOS (Tránh báo nhầm - US-13):');
    if (!reason) return;

    setWorkOrders((prev) =>
      prev.map((wo) => {
        if (wo.id === woId && wo.status === 'PENDING') {
          setMachines((mPrev) =>
            mPrev.map((m) => (m.id === wo.machineId ? { ...m, status: 'ACTIVE' } : m))
          );
          return { ...wo, status: 'CANCELLED', cancellationReason: reason };
        }
        return wo;
      })
    );
  };

  const pendingSosCount = workOrders.filter((w) => (w.severity === 'CRITICAL' || w.severity === 'HIGH') && w.status === 'PENDING').length;
  const activeMachinesCount = machines.filter((m) => m.status === 'ACTIVE').length;

  return (
    <PhoneDeviceFrame
      activeSosCount={pendingSosCount}
      activeMachinesCount={activeMachinesCount}
      totalMachinesCount={machines.length}
      currentUserRole="OPERATOR"
      currentUserEmail="operator.nam@factory.com"
      onOpenQR={() => setIsQRScannerOpen(true)}
    >
        <div className="w-full flex-1 bg-slate-50 flex flex-col relative overflow-hidden">
          
          {/* Header */}
          <header className="p-3 bg-white border-b border-slate-200 flex items-center justify-between sticky top-0 z-30 backdrop-blur-md bg-white/95 shadow-xs">
          <div className="flex items-center gap-3">
            <Link
              href="/"
              className="p-2 rounded-xl bg-slate-100 text-slate-600 hover:text-slate-900 transition"
            >
              <ChevronLeft className="w-5 h-5" />
            </Link>
            <div>
              <div className="flex items-center gap-1.5 text-emerald-700 font-extrabold text-xs">
                <HardHat className="w-4 h-4 text-emerald-600" />
                <span>Trang Công Nhân Vận Hành</span>
              </div>
              <h1 className="text-sm font-extrabold text-slate-900">Hộ Chiếu Máy & Báo Lỗi SOS</h1>
            </div>
          </div>

          <button
            onClick={() => setIsQRScannerOpen(true)}
            className="p-2 rounded-xl bg-emerald-600 text-white font-extrabold text-xs flex items-center gap-1 shadow-md hover:bg-emerald-700 transition"
          >
            <QrCode className="w-4 h-4" /> Quét QR
          </button>
        </header>

        {/* Content Body */}
        <main className="p-4 space-y-4 flex-1 overflow-y-auto pb-10">
          
          {/* Machines List */}
          <div className="space-y-2.5">
            <h2 className="text-xs font-extrabold uppercase tracking-wider text-slate-600">
              Danh Sách Máy Phụ Trách ({machines.length})
            </h2>

            {machines.map((m) => (
              <div
                key={m.id}
                onClick={() => setPassportMachine(m)}
                className="p-4 rounded-2xl bg-white border border-slate-200 shadow-xs flex items-center justify-between cursor-pointer hover:border-emerald-300 transition"
              >
                <div className="flex items-center gap-3">
                  <div className="p-3 rounded-xl bg-emerald-50 text-emerald-700 border border-emerald-200">
                    <Cpu className="w-5 h-5" />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-mono text-xs font-black text-emerald-700">{m.code}</span>
                      <span className="text-xs font-extrabold text-slate-900">{m.name}</span>
                    </div>
                    <span className="text-[11px] text-slate-500 font-medium">{m.location}</span>
                    <span className="text-[11px] text-slate-600 font-mono block mt-0.5 font-semibold">{m.runningHours} Giờ máy chạy</span>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-slate-400" />
              </div>
            ))}
          </div>

          {/* Submitted Work Orders Track */}
          <div className="p-4 rounded-2xl bg-white border border-slate-200 shadow-xs space-y-3">
            <h2 className="text-xs font-extrabold uppercase tracking-wider text-rose-700 flex items-center gap-1.5">
              <AlertTriangle className="w-4 h-4 text-rose-600" />
              Theo Dõi Phiếu Báo Lỗi Khẩn Cấp ({workOrders.length})
            </h2>

            <div className="space-y-2">
              {workOrders.map((wo) => (
                <div key={wo.id} className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 text-xs space-y-1.5">
                  <div className="flex items-center justify-between">
                    <span className="font-mono font-black text-rose-700">{wo.code}</span>
                    <span className={`px-2 py-0.5 rounded text-[10px] font-extrabold ${
                      wo.status === 'PENDING' ? 'bg-amber-100 text-amber-800' :
                      wo.status === 'IN_PROGRESS' ? 'bg-cyan-100 text-cyan-800' :
                      wo.status === 'CANCELLED' ? 'bg-slate-200 text-slate-700' : 'bg-emerald-100 text-emerald-800'
                    }`}>
                      {wo.status}
                    </span>
                  </div>
                  <div className="font-bold text-slate-900">{wo.machineName}</div>
                  <p className="text-slate-600 text-[11px] leading-snug font-medium">{wo.description}</p>

                  {/* Cancel SOS Button for Operator (US-13) */}
                  {wo.status === 'PENDING' && (
                    <div className="pt-1">
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleCancelWorkOrder(wo.id)}
                        className="w-full text-rose-700 border-rose-200 hover:bg-rose-50 text-[11px] h-7 font-bold"
                      >
                        <XCircle className="w-3.5 h-3.5" /> Hủy Phiếu SOS (Báo Nhầm - US-13)
                      </Button>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>

        </main>

        {/* Modals */}
        <QRScannerModal
          isOpen={isQRScannerOpen}
          onClose={() => setIsQRScannerOpen(false)}
          machines={machines}
          onSelectMachine={(m) => setPassportMachine(m)}
        />

        <MachinePassportModal
          machine={passportMachine}
          isOpen={!!passportMachine}
          onClose={() => setPassportMachine(null)}
          onUpdateHours={handleUpdateHours}
          onOpenSOS={(m) => setSosMachine(m)}
          pastWorkOrders={workOrders}
          userRole="OPERATOR"
        />

        <SOSFormModal
          machine={sosMachine}
          isOpen={!!sosMachine}
          onClose={() => setSosMachine(null)}
          onSubmitSOS={handleCreateSOS}
        />

      </div>
    </PhoneDeviceFrame>
  );
}
