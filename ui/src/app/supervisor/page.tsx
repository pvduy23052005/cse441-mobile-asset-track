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

import { WorkOrder, PMChecklist, Machine, SparePartRequest, SystemThresholdConfig } from '../../types';
import {
  initialWorkOrders,
  initialPMChecklists,
  initialMachines,
  initialSparePartRequests,
  initialThresholdConfig,
} from '../../data/mockData';
import { DashboardView } from '../../components/DashboardView';
import { DigitalSignoffModal } from '../../components/DigitalSignoffModal';
import { UserManagementModal } from '../../components/UserManagementModal';
import { ThresholdConfigModal } from '../../components/ThresholdConfigModal';
import { MachinePassportModal } from '../../components/MachinePassportModal';
import { AddMachineModal } from '../../components/AddMachineModal';
import { PhoneDeviceFrame } from '../../components/PhoneDeviceFrame';

export default function SupervisorPage() {
  const [machines, setMachines] = useState<Machine[]>(initialMachines);
  const [workOrders, setWorkOrders] = useState<WorkOrder[]>(initialWorkOrders);
  const [checklists, setChecklists] = useState<PMChecklist[]>(initialPMChecklists);
  const [sparePartRequests, setSparePartRequests] = useState<SparePartRequest[]>(initialSparePartRequests);
  const [thresholdConfig, setThresholdConfig] = useState<SystemThresholdConfig>(initialThresholdConfig);

  // Modals
  const [isUserManagementOpen, setIsUserManagementOpen] = useState(false);
  const [isThresholdModalOpen, setIsThresholdModalOpen] = useState(false);
  const [isAddMachineOpen, setIsAddMachineOpen] = useState(false);
  const [passportMachine, setPassportMachine] = useState<Machine | null>(null);

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

  const pendingApprovalsWO = workOrders.filter((wo) => wo.status === 'COMPLETED');
  const pendingApprovalsPM = checklists.filter((pm) => pm.status === 'COMPLETED');
  const totalPendingSignoffs = pendingApprovalsWO.length + pendingApprovalsPM.length;

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
            mPrev.map((m) => {
              if (m.id === pm.machineId) {
                const sortedIntervals = [...thresholdConfig.pmIntervals].sort((a, b) => a - b);
                const nextMoc =
                  sortedIntervals.find((interval) => interval > m.runningHours) ||
                  m.runningHours + (sortedIntervals[0] || 500);
                return {
                  ...m,
                  status: 'ACTIVE',
                  lastMaintenanceHours: m.runningHours,
                  lastMaintenanceDate: new Date().toISOString().split('T')[0],
                  nextMaintenanceHours: nextMoc,
                };
              }
              return m;
            })
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

  const handleApproveSparePart = (requestId: string) => {
    setSparePartRequests((prev) =>
      prev.map((spr) => (spr.id === requestId ? { ...spr, status: 'APPROVED' } : spr))
    );
  };

  const handleRejectSparePart = (requestId: string, reason: string) => {
    setSparePartRequests((prev) =>
      prev.map((spr) => (spr.id === requestId ? { ...spr, status: 'REJECTED', rejectionReason: reason } : spr))
    );
  };

  const handleSaveThresholdConfig = (newConfig: SystemThresholdConfig) => {
    setThresholdConfig(newConfig);
  };

  const handleOpenSignoff = (itemCode: string, title: string, subtitle: string) => {
    setSignoffData({
      isOpen: true,
      itemCode,
      title,
      subtitle,
    });
  };

  return (
    <PhoneDeviceFrame
      activeSosCount={totalPendingSignoffs}
      activeMachinesCount={machines.filter((m) => m.status === 'ACTIVE').length}
      totalMachinesCount={machines.length}
      currentUserRole="SUPERVISOR"
      currentUserEmail="supervisor.hoang@factory.com"
    >
      <div className="w-full flex-1 bg-slate-50 flex flex-col relative overflow-hidden">
        
        {/* Navigation Bar */}
        <header className="p-3 bg-white border-b border-slate-200 flex items-center justify-between sticky top-0 z-30 backdrop-blur-md bg-white/95 shadow-xs">
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
              <h1 className="text-sm font-extrabold text-slate-900">Executive Dashboard & Nghiệm Thu Điện Tử</h1>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => setIsUserManagementOpen(true)}
              className="p-2 rounded-xl bg-amber-50 text-amber-700 border border-amber-200 hover:bg-amber-100 font-extrabold text-xs flex items-center gap-1.5 transition"
              title="Quản Lý Nhân Sự Phân Xưởng"
            >
              <Users className="w-4 h-4 text-amber-600" />
              <span className="hidden sm:inline">Nhân Sự</span>
            </button>

            <div className="w-8 h-8 rounded-full bg-amber-100 text-amber-800 border border-amber-200 flex items-center justify-center font-black text-xs">
              QĐ
            </div>
          </div>
        </header>

        {/* Dashboard Main Content */}
        <main className="p-3 sm:p-5 flex-1 overflow-y-auto">
          <DashboardView
            machines={machines}
            workOrders={workOrders}
            checklists={checklists}
            sparePartRequests={sparePartRequests}
            thresholdConfig={thresholdConfig}
            onOpenSignoff={handleOpenSignoff}
            onOpenThresholdConfig={() => setIsThresholdModalOpen(true)}
            onOpenUserManagement={() => setIsUserManagementOpen(true)}
            onOpenAddMachine={() => setIsAddMachineOpen(true)}
            onApproveSparePart={handleApproveSparePart}
            onRejectSparePart={handleRejectSparePart}
            onOpenMachinePassport={(m) => setPassportMachine(m)}
          />
        </main>

        {/* Signature Modal with Work Summary Box */}
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

        {/* Threshold Config Modal */}
        <ThresholdConfigModal
          isOpen={isThresholdModalOpen}
          onClose={() => setIsThresholdModalOpen(false)}
          config={thresholdConfig}
          onSaveConfig={handleSaveThresholdConfig}
        />

        {/* Machine Passport Modal */}
        <MachinePassportModal
          machine={passportMachine}
          isOpen={!!passportMachine}
          onClose={() => setPassportMachine(null)}
          onUpdateHours={(machineId, newHours) => {
            setMachines((prev) =>
              prev.map((m) => (m.id === machineId ? { ...m, runningHours: newHours } : m))
            );
          }}
          onOpenSOS={() => {}}
          pastWorkOrders={workOrders}
          pastChecklists={checklists}
          userRole="SUPERVISOR"
        />

        {/* Add Machine Modal */}
        <AddMachineModal
          isOpen={isAddMachineOpen}
          onClose={() => setIsAddMachineOpen(false)}
          onAddMachine={(newM) => {
            setMachines((prev) => [newM, ...prev]);
          }}
        />

      </div>
    </PhoneDeviceFrame>
  );
}
