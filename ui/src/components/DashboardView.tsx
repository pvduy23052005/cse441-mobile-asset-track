'use client';

import React from 'react';
import { Machine, WorkOrder, PMChecklist, SparePartRequest, SystemThresholdConfig } from '@/types';
import { SupervisorMobileView } from '@/components/SupervisorMobileView';

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
  onOpenMachinePassport?: (machine: Machine) => void;
}

export const DashboardView: React.FC<DashboardViewProps> = (props) => {
  // Giao diện Supervisor chuẩn Mobile 100% không bị ảnh hưởng bởi breakpoint của màn hình máy tính
  return <SupervisorMobileView {...props} />;
};
