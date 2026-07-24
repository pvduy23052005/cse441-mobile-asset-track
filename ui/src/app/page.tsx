'use client';

import React, { useState } from 'react';
import {
  Wrench,
  CheckCircle2,
  Clock,
  Cpu,
  QrCode,
  ChevronRight,
  WifiOff,
  AlertTriangle,
  FileSignature,
  Sliders,
} from 'lucide-react';

import {
  UserRole,
  Machine,
  WorkOrder,
  PMChecklist,
  SystemNotification,
  SparePartRequest,
  SystemThresholdConfig,
  RunningHoursLog,
  SparePartItem,
} from '../types';

import {
  initialMachines,
  initialWorkOrders,
  initialPMChecklists,
  initialNotifications,
  initialSparePartRequests,
  initialThresholdConfig,
  initialRunningHoursLogs,
} from '../data/mockData';

import { RoleHeader } from '../components/RoleHeader';
import { BottomNav } from '../components/BottomNav';
import { QRScannerModal } from '../components/QRScannerModal';
import { MachinePassportModal } from '../components/MachinePassportModal';
import { SOSFormModal } from '../components/SOSFormModal';
import { PMChecklistModal } from '../components/PMChecklistModal';
import { DigitalSignoffModal } from '../components/DigitalSignoffModal';
import { ThresholdConfigModal } from '../components/ThresholdConfigModal';
import { WorkOrderDetailModal } from '../components/WorkOrderDetailModal';
import { DashboardView } from '../components/DashboardView';

import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

export default function AssetTrackMobileApp() {
  const [currentRole, setCurrentRole] = useState<UserRole>('OPERATOR');
  const [activeTab, setActiveTab] = useState<'HOME' | 'SCANNER' | 'TASKS' | 'MACHINES'>('HOME');

  // Core Data States according to overview.md
  const [machines, setMachines] = useState<Machine[]>(initialMachines);
  const [workOrders, setWorkOrders] = useState<WorkOrder[]>(initialWorkOrders);
  const [checklists, setChecklists] = useState<PMChecklist[]>(initialPMChecklists);
  const [notifications, setNotifications] = useState<SystemNotification[]>(initialNotifications);
  const [sparePartRequests, setSparePartRequests] = useState<SparePartRequest[]>(initialSparePartRequests);
  const [thresholdConfig, setThresholdConfig] = useState<SystemThresholdConfig>(initialThresholdConfig);
  const [runningLogs, setRunningLogs] = useState<RunningHoursLog[]>(initialRunningHoursLogs);

  // Global Offline Queue Simulation (NFR-06)
  const [isGlobalOffline, setIsGlobalOffline] = useState(false);

  // Modal States
  const [isQRScannerOpen, setIsQRScannerOpen] = useState(false);
  const [passportMachine, setPassportMachine] = useState<Machine | null>(null);
  const [sosMachine, setSosMachine] = useState<Machine | null>(null);
  const [pmModalChecklist, setPmModalChecklist] = useState<PMChecklist | null>(null);
  const [isThresholdModalOpen, setIsThresholdModalOpen] = useState(false);
  const [selectedWorkOrder, setSelectedWorkOrder] = useState<WorkOrder | null>(null);

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

  // --- HANDLERS IMPLEMENTING 12 CORE FEATURES ---

  // 1 & 2. Running Hours Logging (Feature 2 / US-02)
  const handleUpdateHours = (machineId: string, newHours: number, shift: 'START_SHIFT' | 'END_SHIFT') => {
    const targetMachine = machines.find((m) => m.id === machineId);
    if (!targetMachine) return;

    // Log entry
    const newLog: RunningHoursLog = {
      id: `log-${Date.now()}`,
      machineId,
      machineCode: targetMachine.code,
      previousHours: targetMachine.runningHours,
      newHours,
      shift,
      loggedBy: 'Nguyễn Văn Nam (Operator)',
      timestamp: new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }),
    };
    setRunningLogs((prev) => [newLog, ...prev]);

    setMachines((prev) =>
      prev.map((m) => {
        if (m.id === machineId) {
          const updated = { ...m, runningHours: newHours };

          // Auto-trigger PM checklist if running hours exceeds nextMaintenanceHours (Feature 12 / US-11)
          if (newHours >= m.nextMaintenanceHours) {
            updated.status = 'MAINTENANCE';
            const newPM: PMChecklist = {
              id: `pm-${Date.now()}`,
              code: `PM-${m.code}-${m.nextMaintenanceHours}H`,
              machineId: m.id,
              machineName: m.name,
              machineCode: m.code,
              scheduledHours: m.nextMaintenanceHours,
              currentHours: newHours,
              status: 'PENDING',
              createdAt: new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }),
              items: [
                { id: 'pmi-a', taskDescription: 'Thay dầu bôi trơn động cơ ép chính', isChecked: false, isRequiredPhoto: true },
                { id: 'pmi-b', taskDescription: 'Kiểm tra áp suất khí nén và van an toàn', isChecked: false, isRequiredPhoto: false },
                { id: 'pmi-c', taskDescription: 'Siết chặt bu-lông chân máy và kiểm tra độ chùng', isChecked: false, isRequiredPhoto: true },
              ],
            };
            setChecklists((pmPrev) => [newPM, ...pmPrev]);

            // Add notification
            setNotifications((nPrev) => [
              {
                id: `noti-${Date.now()}`,
                title: `TỰ ĐỘNG SINH PHIẾU PM (${m.nextMaintenanceHours}H)`,
                message: `Máy ${m.code} đạt chỉ số ${newHours}h - đã sinh phiếu PM Checklist tự động!`,
                type: 'PM',
                timestamp: 'Vừa xong',
                read: false,
              },
              ...nPrev,
            ]);
          }
          setPassportMachine(updated);
          return updated;
        }
        return m;
      })
    );
  };

  // 3 & 4. Breakdown SOS Creation & Failure Photo (Feature 3, 4 / US-03)
  const handleCreateSOS = (data: {
    machineId: string;
    machineName: string;
    machineCode: string;
    severity: any;
    description: string;
    imageUrl?: string;
    isOffline?: boolean;
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

    const isOff = data.isOffline || isGlobalOffline;

    const newNoti: SystemNotification = {
      id: `noti-${Date.now()}`,
      title: isOff ? `[OFFLINE QUEUE] SỰ CỐ SOS (${data.severity})` : `SỰ CỐ SOS MỚI (${data.severity})`,
      message: isOff
        ? `⚠️ Mất kết nối - Phiếu SOS máy ${data.machineCode} được lưu trong local queue!`
        : `Máy ${data.machineCode} báo sự cố dừng chuyền: ${data.description}`,
      type: 'SOS',
      timestamp: 'Vừa xong',
      read: false,
    };
    setNotifications((prev) => [newNoti, ...prev]);
  };

  // US-13. Cancel Pending SOS Request
  const handleCancelWorkOrder = (woId: string) => {
    const reason = prompt('Nhập lý do hủy phiếu báo lỗi SOS (Tránh báo nhầm):');
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

  // 5. SOS Work Order Claiming (Feature 5 / US-04)
  const handleClaimWorkOrder = (woId: string) => {
    const targetWO = workOrders.find((w) => w.id === woId);
    if (!targetWO) return;

    if (targetWO.status !== 'PENDING') {
      alert('Phiếu đã được tiếp nhận bởi kỹ sư khác!');
      return;
    }

    setWorkOrders((prev) =>
      prev.map((wo) =>
        wo.id === woId
          ? { ...wo, status: 'IN_PROGRESS', assigneeName: 'Kỹ Sư ME Trần Minh Đức' }
          : wo
      )
    );
    if (selectedWorkOrder?.id === woId) {
      setSelectedWorkOrder((prev) => prev ? { ...prev, status: 'IN_PROGRESS', assigneeName: 'Kỹ Sư ME Trần Minh Đức' } : null);
    }
  };

  // Complete WO after repair
  const handleCompleteWorkOrder = (woId: string, usedParts?: SparePartItem[]) => {
    setWorkOrders((prev) =>
      prev.map((wo) => (wo.id === woId ? { ...wo, status: 'COMPLETED', usedSpareParts: usedParts || wo.usedSpareParts } : wo))
    );
  };

  // Add spare part to Work Order
  const handleAddSparePartToWO = (woId: string, part: SparePartItem) => {
    setWorkOrders((prev) =>
      prev.map((wo) => {
        if (wo.id === woId) {
          const updatedParts = [...(wo.usedSpareParts || []), part];
          return { ...wo, usedSpareParts: updatedParts };
        }
        return wo;
      })
    );

    if (selectedWorkOrder?.id === woId) {
      setSelectedWorkOrder((prev) =>
        prev
          ? {
              ...prev,
              usedSpareParts: [...(prev.usedSpareParts || []), part],
            }
          : null
      );
    }

    if (part.requiresApproval) {
      const targetWO = workOrders.find((w) => w.id === woId);
      const newSpr: SparePartRequest = {
        id: `spr-${Date.now()}`,
        workOrderId: woId,
        machineCode: targetWO?.machineCode || 'MC-101',
        machineName: targetWO?.machineName || 'Thiết bị',
        requestedBy: 'Trần Minh Đức (ME)',
        partName: part.name,
        quantity: part.quantity,
        unitPrice: part.unitPrice,
        totalCost: part.totalCost,
        reason: `Sửa chữa sự cố phiếu ${targetWO?.code}`,
        status: 'PENDING',
        createdAt: new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }),
      };
      setSparePartRequests((sPrev) => [newSpr, ...sPrev]);
    }
  };

  // 6 & 7 & 8. PM Checklist & Spare Parts Logging
  const handleCompletePMChecklist = (
    pmId: string,
    items: any[],
    spareParts: SparePartItem[]
  ) => {
    const targetPM = checklists.find((p) => p.id === pmId);

    spareParts.forEach((sp) => {
      if (sp.requiresApproval) {
        const newSpr: SparePartRequest = {
          id: `spr-${Date.now()}`,
          workOrderId: pmId,
          machineCode: targetPM?.machineCode || 'MC-101',
          machineName: targetPM?.machineName || 'Thiết bị',
          requestedBy: 'Trần Minh Đức (ME)',
          partName: sp.name,
          quantity: sp.quantity,
          unitPrice: sp.unitPrice,
          totalCost: sp.totalCost,
          reason: `Thay thế linh kiện đợt PM mốc ${targetPM?.scheduledHours || 500}h`,
          status: 'PENDING',
          createdAt: new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }),
        };
        setSparePartRequests((sPrev) => [newSpr, ...sPrev]);
      }
    });

    setChecklists((prev) =>
      prev.map((pm) =>
        pm.id === pmId ? { ...pm, status: 'COMPLETED', items } : pm
      )
    );
  };

  // 9. Digital Sign-off Confirmation (Feature 9 / US-08)
  const handleConfirmSignoff = (signatureUrl: string) => {
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
                const nextMoc = sortedIntervals.find((interval) => interval > m.runningHours)
                  || (m.runningHours + (sortedIntervals[0] || 500));
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

  // Rejection by Supervisor
  const handleRejectSignoff = (reason: string) => {
    const code = signoffData.itemCode;
    setWorkOrders((prev) =>
      prev.map((wo) => (wo.code === code ? { ...wo, status: 'REJECTED', rejectionReason: reason } : wo))
    );
    setChecklists((prev) =>
      prev.map((pm) => (pm.code === code ? { ...pm, status: 'REJECTED', rejectionReason: reason } : pm))
    );
  };

  // 10. Spare Parts Approval / Rejection by Supervisor (Feature 10 / US-09)
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

  // 12. Save System Threshold Config (Feature 12 / US-11)
  const handleSaveThresholdConfig = (newConfig: SystemThresholdConfig) => {
    setThresholdConfig(newConfig);
    setMachines((prev) =>
      prev.map((m) => {
        const sortedIntervals = [...newConfig.pmIntervals].sort((a, b) => a - b);
        const nextMoc = sortedIntervals.find((interval) => interval > m.runningHours)
          || (m.runningHours + (sortedIntervals[0] || 500));
        return {
          ...m,
          nextMaintenanceHours: nextMoc,
        };
      })
    );
  };

  const handleBottomTabChange = (tab: 'HOME' | 'SCANNER' | 'TASKS' | 'MACHINES') => {
    if (tab === 'SCANNER') {
      setIsQRScannerOpen(true);
    } else {
      setActiveTab(tab);
    }
  };

  return (
    <div className="min-h-screen bg-slate-100 text-slate-900 flex flex-col font-sans selection:bg-emerald-500 selection:text-white">
      
      {/* Mobile Frame Container */}
      <div className="w-full max-w-md mx-auto min-h-screen bg-slate-50 flex flex-col relative border-x border-slate-200 shadow-2xl">
        
        {/* Role Header */}
        <RoleHeader
          currentRole={currentRole}
          onChangeRole={setCurrentRole}
          notifications={notifications}
          onOpenQR={() => setIsQRScannerOpen(true)}
        />

        {/* Global Offline Network Simulation Banner (NFR-06) */}
        {isGlobalOffline && (
          <div className="bg-amber-500 text-white p-2.5 px-4 text-xs font-bold flex items-center justify-between shadow-xs">
            <div className="flex items-center gap-2">
              <WifiOff className="w-4 h-4 animate-pulse" />
              <span>Đang Offline — Dữ liệu sẽ lưu vào Local Queue (SQLite)</span>
            </div>
            <button
              onClick={() => setIsGlobalOffline(false)}
              className="px-2 py-0.5 rounded bg-white text-amber-900 font-extrabold text-[10px]"
            >
              Bật Online
            </button>
          </div>
        )}

        {/* Main Content Area */}
        <main className="flex-1 p-2.5 overflow-y-auto pb-16">
          
          {/* TAB: HOME / ROLE VIEW */}
          {activeTab === 'HOME' && (
            <>
              {/* OPERATOR ROLE HOME VIEW */}
              {currentRole === 'OPERATOR' && (
                <div className="space-y-2.5">
                  
                  {/* Offline Simulation Toggle Bar */}
                  <div className="flex items-center justify-between p-2 rounded-md bg-white border border-slate-200 shadow-xs text-xs">
                    <span className="font-extrabold text-slate-700">Mạng Kết Nối:</span>
                    <button
                      onClick={() => setIsGlobalOffline(!isGlobalOffline)}
                      className={`px-2.5 py-0.5 rounded text-[11px] font-black transition flex items-center gap-1 ${
                        isGlobalOffline
                          ? 'bg-amber-100 text-amber-900 border border-amber-300'
                          : 'bg-emerald-100 text-emerald-900 border border-emerald-300'
                      }`}
                    >
                      {isGlobalOffline ? (
                        <>
                          <WifiOff className="w-3 h-3 text-amber-600" /> Offline Mode
                        </>
                      ) : (
                        <>
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" /> Online Sync
                        </>
                      )}
                    </button>
                  </div>

                  {/* Quick Action QR Banner */}
                  <div className="p-3 rounded-md bg-gradient-to-br from-emerald-600 to-teal-700 text-white shadow-xs relative overflow-hidden">
                    <div className="flex items-center justify-between">
                      <div>
                        <span className="text-[9px] font-extrabold uppercase tracking-wider text-emerald-100 bg-white/20 px-1.5 py-0.5 rounded-sm">
                          Thao tác công nhân
                        </span>
                        <h2 className="text-sm font-extrabold text-white mt-0.5">
                          Quét QR Hộ Chiếu Máy
                        </h2>
                        <p className="text-[11px] text-emerald-50 mt-0.5">
                          Xem thông số, lịch sử & báo lỗi khẩn cấp
                        </p>
                      </div>
                      <button
                        onClick={() => setIsQRScannerOpen(true)}
                        className="p-2.5 rounded-md bg-white text-emerald-800 shadow-md hover:scale-105 active:scale-95 transition font-extrabold"
                      >
                        <QrCode className="w-5 h-5 stroke-[2.5]" />
                      </button>
                    </div>
                  </div>

                  {/* Machine Status List */}
                  <div>
                    <h3 className="text-[11px] font-extrabold uppercase tracking-wider text-slate-600 mb-2 flex items-center justify-between">
                      <span>Danh Sách Máy Phụ Trách ({machines.length})</span>
                      <span className="text-[10px] text-emerald-700 font-bold">Chạm xem chi tiết</span>
                    </h3>

                    <div className="space-y-2">
                      {machines.map((m) => (
                        <div
                          key={m.id}
                          onClick={() => setPassportMachine(m)}
                          className="p-2.5 rounded-md bg-white border border-slate-200 shadow-xs hover:border-emerald-300 transition cursor-pointer flex items-center justify-between"
                        >
                          <div className="flex items-center gap-2.5">
                            <div className={`p-2 rounded ${
                              m.status === 'ACTIVE' ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' :
                              m.status === 'REPAIRING' ? 'bg-rose-50 text-rose-700 border border-rose-200' : 'bg-amber-50 text-amber-700 border border-amber-200'
                            }`}>
                              <Cpu className="w-5 h-5" />
                            </div>
                            <div>
                              <div className="flex items-center gap-2">
                                <span className="font-mono text-xs font-black text-slate-900">{m.code}</span>
                                <span className="text-xs font-bold text-slate-800">{m.name}</span>
                              </div>
                              <div className="text-[11px] text-slate-500 font-medium mt-0.5">
                                {m.runningHours} Giờ máy chạy (Mốc kế: {m.nextMaintenanceHours}h)
                              </div>
                            </div>
                          </div>
                          <ChevronRight className="w-4 h-4 text-slate-400" />
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Active SOS Tracker */}
                  <Card>
                    <CardHeader className="p-4 pb-2">
                      <CardTitle className="text-xs font-extrabold uppercase tracking-wider text-slate-600">
                        Theo Dõi Phiếu Báo Lỗi SOS ({workOrders.length})
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="p-4 pt-1 space-y-2">
                      {workOrders.map((wo) => (
                        <div
                          key={wo.id}
                          onClick={() => setSelectedWorkOrder(wo)}
                          className="p-3 rounded-xl bg-slate-50 hover:bg-slate-100 cursor-pointer border border-slate-200 text-xs space-y-1 transition"
                        >
                          <div className="flex items-center justify-between">
                            <span className="font-mono font-black text-rose-700">{wo.code}</span>
                            <div className="flex items-center gap-1.5">
                              {wo.status === 'PENDING' && (
                                <button
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    handleCancelWorkOrder(wo.id);
                                  }}
                                  className="px-2 py-0.5 text-[10px] font-bold text-slate-500 hover:text-rose-700 underline"
                                >
                                  Hủy báo nhầm
                                </button>
                              )}
                              <Badge
                                variant={
                                  wo.status === 'PENDING' ? 'maintenance' :
                                  wo.status === 'IN_PROGRESS' ? 'secondary' : 'active'
                                }
                              >
                                {wo.status}
                              </Badge>
                            </div>
                          </div>
                          <p className="text-slate-900 font-bold text-[11px]">{wo.machineName}</p>
                          <p className="text-slate-500 text-[11px] line-clamp-1">{wo.description}</p>
                        </div>
                      ))}
                    </CardContent>
                  </Card>

                </div>
              )}

              {/* ME ENGINEER ROLE HOME VIEW */}
              {currentRole === 'ME_ENGINEER' && (
                <div className="space-y-3">
                  {/* Emergency Work Orders Feed */}
                  <Card>
                    <CardHeader className="p-4 pb-2">
                      <div className="flex items-center justify-between">
                        <CardTitle className="text-xs font-extrabold uppercase tracking-wider text-rose-700">
                          Phiếu Sự Cố SOS Cần Xử Lý ({workOrders.filter((w) => w.status !== 'APPROVED').length})
                        </CardTitle>
                        <span className="text-[10px] text-cyan-700 font-bold">Chạm xem chi tiết</span>
                      </div>
                    </CardHeader>

                    <CardContent className="p-3 pt-1 space-y-2">
                      {workOrders.filter((w) => w.status !== 'APPROVED').map((wo) => (
                        <div
                          key={wo.id}
                          onClick={() => setSelectedWorkOrder(wo)}
                          className="p-2.5 rounded-md bg-slate-50 hover:bg-slate-100/80 cursor-pointer border border-slate-200 space-y-1.5 transition shadow-xs"
                        >
                          <div className="flex items-center justify-between">
                            <span className="font-mono text-xs font-black text-rose-700">{wo.code}</span>
                            <Badge variant={wo.severity === 'CRITICAL' ? 'destructive' : 'maintenance'}>
                              Nghiêm trọng: {wo.severity}
                            </Badge>
                          </div>

                          <div>
                            <div className="text-xs font-extrabold text-slate-900">{wo.machineName}</div>
                            <p className="text-[11px] text-slate-600 leading-snug mt-0.5 line-clamp-2">{wo.description}</p>
                          </div>

                          {wo.imageUrl && (
                            <img src={wo.imageUrl} alt="Lỗi" className="w-full h-20 object-cover rounded border border-slate-200" />
                          )}

                          {wo.rejectionReason && (
                            <div className="p-1.5 rounded bg-rose-100 border border-rose-300 text-rose-800 text-[10px] font-bold">
                              ⚠️ Supervisor từ chối nghiệm thu: {wo.rejectionReason}
                            </div>
                          )}

                          <div className="pt-0.5 flex gap-1.5">
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
                                <Wrench className="w-3.5 h-3.5" /> Bấm Tiếp Nhận Sửa Chữa
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
                                <CheckCircle2 className="w-3.5 h-3.5" /> Hoàn Thành & Gửi Nghiệm Thu
                              </Button>
                            )}
                            {wo.status === 'COMPLETED' && (
                              <div className="w-full text-[11px] text-amber-700 font-bold flex items-center justify-center gap-1 p-1.5 rounded bg-amber-50 border border-amber-200">
                                <Clock className="w-3 h-3" /> Đã xong - Đang chờ Quản Đốc ký
                              </div>
                            )}
                          </div>
                        </div>
                      ))}
                    </CardContent>
                  </Card>

                  {/* PM Checklists Feed */}
                  <Card>
                    <CardHeader className="p-3 pb-1.5">
                      <CardTitle className="text-[11px] font-extrabold uppercase tracking-wider text-amber-700">
                        Nhiệm Vụ Bảo Trì Định Kỳ (PM Checklist)
                      </CardTitle>
                    </CardHeader>

                    <CardContent className="p-3 pt-1 space-y-2">
                      {checklists.map((pm) => (
                        <div key={pm.id} className="p-2.5 rounded-md bg-slate-50 border border-slate-200 flex items-center justify-between">
                          <div>
                            <div className="flex items-center gap-1.5">
                              <span className="font-mono text-[11px] font-bold text-amber-700">{pm.code}</span>
                              <span className="text-[11px] font-extrabold text-slate-900">{pm.machineName}</span>
                            </div>
                            <span className="text-[10px] text-slate-500 font-medium block mt-0.5">Mốc số giờ: {pm.scheduledHours}h</span>
                          </div>

                          <Button
                            variant="amber"
                            size="sm"
                            onClick={() => setPmModalChecklist(pm)}
                          >
                            Thực Hiện PM
                          </Button>
                        </div>
                      ))}
                    </CardContent>
                  </Card>

                </div>
              )}

              {/* SUPERVISOR ROLE HOME VIEW */}
              {currentRole === 'SUPERVISOR' && (
                <DashboardView
                  machines={machines}
                  workOrders={workOrders}
                  checklists={checklists}
                  sparePartRequests={sparePartRequests}
                  thresholdConfig={thresholdConfig}
                  onOpenSignoff={(code, title, subtitle) =>
                    setSignoffData({ isOpen: true, itemCode: code, title, subtitle })
                  }
                  onOpenThresholdConfig={() => setIsThresholdModalOpen(true)}
                  onApproveSparePart={handleApproveSparePart}
                  onRejectSparePart={handleRejectSparePart}
                />
              )}
            </>
          )}

          {/* TAB: MACHINES LIST */}
          {activeTab === 'MACHINES' && (
            <div className="space-y-2">
              <h2 className="text-[11px] font-extrabold text-slate-600 uppercase tracking-wider">Tất Cả Thiết Bị Phân Xưởng</h2>
              <div className="space-y-2">
                {machines.map((m) => (
                  <div
                    key={m.id}
                    onClick={() => setPassportMachine(m)}
                    className="p-2.5 rounded-md bg-white border border-slate-200 shadow-xs flex items-center justify-between cursor-pointer hover:border-slate-300 transition"
                  >
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-[11px] font-black text-emerald-700">{m.code}</span>
                        <span className="text-[11px] font-extrabold text-slate-900">{m.name}</span>
                      </div>
                      <span className="text-[10px] text-slate-500 font-medium block mt-0.5">{m.location}</span>
                      <span className="text-[10px] text-slate-600 font-mono mt-0.5 block font-semibold">Mốc bảo trì kế: {m.nextMaintenanceHours}h</span>
                    </div>
                    <ChevronRight className="w-4 h-4 text-slate-400" />
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* TAB: TASKS LIST - TAILORED SPECIFICALLY PER USER ROLE (TÁC NHÂN KHÁC NHAU) */}
          {activeTab === 'TASKS' && (
            <div className="space-y-4">
              
              {/* OPERATOR SPECIFIC TASKS */}
              {currentRole === 'OPERATOR' && (
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <h2 className="text-[11px] font-extrabold text-slate-600 uppercase tracking-wider">
                      Nhiệm Vụ Ca Làm Việc Công Nhân
                    </h2>
                    <Badge variant="secondary">Công nhân: Nguyễn Văn Nam</Badge>
                  </div>

                  {/* Task 1: Declare Running Hours */}
                  <Card>
                    <CardHeader className="p-2.5 pb-1">
                      <CardTitle className="text-[11px] font-bold text-slate-800">
                        1. Khai báo giờ máy chạy ca này ({machines.length} máy)
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="p-2.5 pt-0 space-y-1.5">
                      {machines.map((m) => (
                        <div key={m.id} className="p-2 rounded-md bg-slate-50 border border-slate-200 flex items-center justify-between text-[11px]">
                          <div>
                            <div className="font-bold text-slate-900">{m.code} - {m.name}</div>
                            <span className="text-[10px] text-slate-500">Giờ hiện tại: {m.runningHours}h</span>
                          </div>
                          <Button size="sm" variant="default" onClick={() => setPassportMachine(m)} className="h-6 px-2 text-[10px]">
                            Nhập Giờ Ca
                          </Button>
                        </div>
                      ))}
                    </CardContent>
                  </Card>

                  {/* Task 2: Track Submitted SOS */}
                  <Card>
                    <CardHeader className="p-2.5 pb-1">
                      <CardTitle className="text-[11px] font-bold text-slate-800">
                        2. Phiếu báo sự cố SOS đã tạo ({workOrders.length})
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="p-2.5 pt-0 space-y-1.5">
                      {workOrders.map((wo) => (
                        <div
                          key={wo.id}
                          onClick={() => setSelectedWorkOrder(wo)}
                          className="p-2 rounded-md bg-slate-50 hover:bg-slate-100 cursor-pointer border border-slate-200 text-[11px] space-y-0.5"
                        >
                          <div className="flex items-center justify-between">
                            <span className="font-mono font-bold text-rose-700">{wo.code}</span>
                            <Badge variant={wo.status === 'PENDING' ? 'maintenance' : 'active'}>{wo.status}</Badge>
                          </div>
                          <p className="font-bold text-slate-900">{wo.machineName}</p>
                          <p className="text-slate-500 text-[10px] line-clamp-1">{wo.description}</p>
                        </div>
                      ))}
                    </CardContent>
                  </Card>
                </div>
              )}

              {/* ME ENGINEER SPECIFIC TASKS */}
              {currentRole === 'ME_ENGINEER' && (
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <h2 className="text-[11px] font-extrabold text-slate-600 uppercase tracking-wider">
                      Nhiệm Vụ Kỹ Sư Cơ Điện (ME Tasks)
                    </h2>
                    <Badge variant="secondary">Kỹ sư: Trần Minh Đức</Badge>
                  </div>

                  {/* Task 1: Pending SOS work orders */}
                  <Card>
                    <CardHeader className="p-2.5 pb-1">
                      <CardTitle className="text-[11px] font-bold text-slate-800">
                        1. Sự cố SOS khẩn cấp cần sửa chữa ({workOrders.filter((w) => w.status !== 'APPROVED').length})
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="p-2.5 pt-0 space-y-1.5">
                      {workOrders.filter((w) => w.status !== 'APPROVED').map((wo) => (
                        <div
                          key={wo.id}
                          onClick={() => setSelectedWorkOrder(wo)}
                          className="p-2 rounded-md bg-slate-50 hover:bg-slate-100 cursor-pointer border border-slate-200 text-[11px] space-y-0.5"
                        >
                          <div className="flex items-center justify-between">
                            <span className="font-mono font-bold text-rose-700">{wo.code}</span>
                            <Badge variant="destructive">{wo.severity}</Badge>
                          </div>
                          <p className="font-bold text-slate-900">{wo.machineName}</p>
                          <p className="text-slate-500 text-[10px] line-clamp-1">{wo.description}</p>
                        </div>
                      ))}
                    </CardContent>
                  </Card>

                  {/* Task 2: PM Checklists */}
                  <Card>
                    <CardHeader className="p-2.5 pb-1">
                      <CardTitle className="text-[11px] font-bold text-slate-800">
                        2. Đợt bảo trì định kỳ PM Checklist ({checklists.length})
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="p-2.5 pt-0 space-y-1.5">
                      {checklists.map((pm) => (
                        <div key={pm.id} className="p-2 rounded-md bg-slate-50 border border-slate-200 text-[11px] flex items-center justify-between">
                          <div>
                            <div className="font-bold text-slate-900">{pm.code} - {pm.machineName}</div>
                            <span className="text-[10px] text-slate-500">Mốc {pm.scheduledHours}h máy chạy</span>
                          </div>
                          <Button size="sm" variant="amber" onClick={() => setPmModalChecklist(pm)} className="h-6 px-2 text-[10px]">
                            Làm PM
                          </Button>
                        </div>
                      ))}
                    </CardContent>
                  </Card>
                </div>
              )}

              {/* SUPERVISOR SPECIFIC TASKS */}
              {currentRole === 'SUPERVISOR' && (
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <h2 className="text-[11px] font-extrabold text-slate-600 uppercase tracking-wider">
                      Nhiệm Vụ Quản Đốc (Supervisor Tasks)
                    </h2>
                    <Badge variant="secondary">Quản đốc: Lê Hoàng</Badge>
                  </div>

                  {/* Task 1: Pending Sign-off Approvals */}
                  <Card>
                    <CardHeader className="p-2.5 pb-1">
                      <CardTitle className="text-[11px] font-bold text-slate-800">
                        1. Duyệt & Ký tên nghiệm thu điện tử ({workOrders.filter((w) => w.status === 'COMPLETED').length + checklists.filter((p) => p.status === 'COMPLETED').length})
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="p-2.5 pt-0 space-y-1.5">
                      {workOrders.filter((w) => w.status === 'COMPLETED').map((wo) => (
                        <div key={wo.id} className="p-2 rounded-md bg-slate-50 border border-slate-200 text-[11px] flex items-center justify-between">
                          <div>
                            <div className="font-bold text-slate-900">SOS: {wo.code} - {wo.machineName}</div>
                            <span className="text-[10px] text-slate-500">Kỹ sư hoàn thành: {wo.assigneeName || 'ME Engineer'}</span>
                          </div>
                          <Button
                            size="sm"
                            variant="amber"
                            onClick={() => setSignoffData({ isOpen: true, itemCode: wo.code, title: `Nghiệm Thu Phiếu SOS: ${wo.code}`, subtitle: `Ký xác nhận bàn giao máy ${wo.machineCode}` })}
                            className="h-6 px-2 text-[10px]"
                          >
                            Ký Tên
                          </Button>
                        </div>
                      ))}

                      {checklists.filter((p) => p.status === 'COMPLETED').map((pm) => (
                        <div key={pm.id} className="p-2 rounded-md bg-slate-50 border border-slate-200 text-[11px] flex items-center justify-between">
                          <div>
                            <div className="font-bold text-slate-900">PM: {pm.code} - {pm.machineName}</div>
                            <span className="text-[10px] text-slate-500">Mốc bảo trì: {pm.scheduledHours}h</span>
                          </div>
                          <Button
                            size="sm"
                            variant="default"
                            onClick={() => setSignoffData({ isOpen: true, itemCode: pm.code, title: `Nghiệm Thu Bảo Trì: ${pm.code}`, subtitle: `Ký xác nhận hoàn tất PM mốc ${pm.scheduledHours}h` })}
                            className="h-6 px-2 text-[10px]"
                          >
                            Ký Tên
                          </Button>
                        </div>
                      ))}
                    </CardContent>
                  </Card>

                  {/* Task 2: Pending Expensive Spare Parts Approvals */}
                  <Card>
                    <CardHeader className="p-3.5 pb-2">
                      <CardTitle className="text-xs font-bold text-slate-800">
                        2. Duyệt đề xuất linh kiện đắt tiền ({sparePartRequests.filter((s) => s.status === 'PENDING').length})
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="p-3.5 pt-0 space-y-2">
                      {sparePartRequests.filter((s) => s.status === 'PENDING').map((spr) => (
                        <div key={spr.id} className="p-3 rounded-xl bg-rose-50/50 border border-rose-200 text-xs space-y-2">
                          <div className="flex items-center justify-between">
                            <span className="font-bold text-slate-900">{spr.machineCode} - {spr.partName}</span>
                            <span className="font-extrabold text-rose-700 font-mono">{spr.totalCost.toLocaleString('vi-VN')}đ</span>
                          </div>
                          <div className="flex gap-2 pt-1">
                            <Button size="sm" variant="destructive" onClick={() => handleRejectSparePart(spr.id, 'Từ chối')} className="flex-1 h-7 text-[11px]">
                              Từ Chối
                            </Button>
                            <Button size="sm" variant="default" onClick={() => handleApproveSparePart(spr.id)} className="flex-1 h-7 text-[11px]">
                              Duyệt Vật Tư
                            </Button>
                          </div>
                        </div>
                      ))}
                    </CardContent>
                  </Card>
                </div>
              )}

            </div>
          )}

        </main>

        {/* Bottom Mobile Tab Bar */}
        <BottomNav
          activeTab={activeTab}
          onChangeTab={handleBottomTabChange}
          pendingTasksCount={workOrders.filter((w) => w.status === 'PENDING').length}
        />

        {/* MODALS */}
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
          pastChecklists={checklists}
          userRole={currentRole}
        />

        <SOSFormModal
          machine={sosMachine}
          isOpen={!!sosMachine}
          onClose={() => setSosMachine(null)}
          onSubmitSOS={handleCreateSOS}
        />

        <PMChecklistModal
          checklist={pmModalChecklist}
          isOpen={!!pmModalChecklist}
          onClose={() => setPmModalChecklist(null)}
          costApprovalThreshold={thresholdConfig.costApprovalThreshold}
          onCompletePM={handleCompletePMChecklist}
        />

        <WorkOrderDetailModal
          workOrder={selectedWorkOrder}
          isOpen={!!selectedWorkOrder}
          onClose={() => setSelectedWorkOrder(null)}
          costApprovalThreshold={thresholdConfig.costApprovalThreshold}
          onClaimWorkOrder={handleClaimWorkOrder}
          onCompleteWorkOrder={handleCompleteWorkOrder}
          onAddSparePartToWO={handleAddSparePartToWO}
          onCancelWorkOrder={handleCancelWorkOrder}
        />

        <DigitalSignoffModal
          isOpen={signoffData.isOpen}
          onClose={() => setSignoffData((prev) => ({ ...prev, isOpen: false }))}
          onConfirmSign={handleConfirmSignoff}
          onReject={handleRejectSignoff}
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

        <ThresholdConfigModal
          isOpen={isThresholdModalOpen}
          onClose={() => setIsThresholdModalOpen(false)}
          config={thresholdConfig}
          onSaveConfig={handleSaveThresholdConfig}
        />

      </div>
    </div>
  );
}
