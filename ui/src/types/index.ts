export type UserRole = 'OPERATOR' | 'ME_ENGINEER' | 'SUPERVISOR';

export type MachineStatus = 'ACTIVE' | 'REPAIRING' | 'MAINTENANCE' | 'INACTIVE';

export type SeverityLevel = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';

export type TaskStatus = 'PENDING' | 'ASSIGNED' | 'IN_PROGRESS' | 'COMPLETED' | 'APPROVED' | 'REJECTED' | 'CANCELLED';

export interface UserProfile {
  id: string;
  fullName: string;
  role: UserRole;
  avatar: string;
}

export interface Machine {
  id: string;
  code: string;
  name: string;
  location: string;
  category: string;
  status: MachineStatus;
  runningHours: number; // Chỉ số tích lũy (Giờ hoặc Km)
  lastMaintenanceHours: number;
  nextMaintenanceHours: number;
  lastMaintenanceDate: string;
  trackingUnit?: 'HOURS' | 'KM' | 'DAYS'; // Đơn vị theo dõi: GIỜ, KM, NGÀY
  unitLabel?: string; // Tên hiển thị đơn vị (vd: 'Giờ máy chạy', 'Km di chuyển', 'Ngày vận hành')
  specifications: {
    power: string;
    voltage: string;
    manufacturer: string;
    year: number;
  };
  quickTroubleshooting: {
    issue: string;
    solution: string;
  }[];
}

export interface SparePartItem {
  id: string;
  name: string;
  quantity: number;
  unitPrice: number;
  totalCost: number;
  requiresApproval: boolean;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
}

export interface SparePartRequest {
  id: string;
  workOrderId?: string;
  machineCode: string;
  machineName: string;
  requestedBy: string;
  partName: string;
  quantity: number;
  unitPrice: number;
  totalCost: number;
  reason: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  rejectionReason?: string;
  createdAt: string;
}

export interface WorkOrder {
  id: string;
  code: string;
  machineId: string;
  machineName: string;
  machineCode: string;
  reporterId: string;
  reporterName: string;
  assigneeId?: string;
  assigneeName?: string;
  supervisorId?: string;
  supervisorName?: string;
  severity: SeverityLevel;
  description: string;
  imageUrl?: string;
  status: TaskStatus;
  downtimeStart: string;
  downtimeEnd?: string;
  supervisorSignatureUrl?: string;
  createdAt: string;
  cancellationReason?: string;
  rejectionReason?: string;
  usedSpareParts?: SparePartItem[];
}

export interface PMChecklistItem {
  id: string;
  taskDescription: string;
  isChecked: boolean;
  photoUrl?: string;
  isRequiredPhoto: boolean;
}

export interface PMChecklist {
  id: string;
  code: string;
  machineId: string;
  machineName: string;
  machineCode: string;
  assigneeId?: string;
  assigneeName?: string;
  scheduledHours: number;
  currentHours: number;
  status: TaskStatus;
  items: PMChecklistItem[];
  supervisorSignatureUrl?: string;
  createdAt: string;
  completedAt?: string;
  rejectionReason?: string;
}

export interface RunningHoursLog {
  id: string;
  machineId: string;
  machineCode: string;
  previousHours: number;
  newHours: number;
  shift: 'START_SHIFT' | 'END_SHIFT';
  loggedBy: string;
  timestamp: string;
}

export interface SystemThresholdConfig {
  workshopId: string;
  workshopName: string;
  costApprovalThreshold: number; // e.g. 2000000 VND
  pmIntervals: number[]; // e.g. [500, 1000, 2000]
}

export interface SystemNotification {
  id: string;
  title: string;
  message: string;
  type: 'SOS' | 'PM' | 'APPROVAL' | 'SYSTEM';
  timestamp: string;
  read: boolean;
  targetId?: string;
}
