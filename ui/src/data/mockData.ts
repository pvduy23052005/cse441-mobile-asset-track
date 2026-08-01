import { Machine, WorkOrder, PMChecklist, SystemNotification, UserProfile, SparePartRequest, SystemThresholdConfig, RunningHoursLog } from '../types';

export const mockUsers: UserProfile[] = [
  {
    id: 'usr-op-01',
    fullName: 'Nguyễn Văn Nam',
    role: 'OPERATOR',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
  },
  {
    id: 'usr-me-01',
    fullName: 'Trần Minh Đức (ME Engineer)',
    role: 'ME_ENGINEER',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
  },
  {
    id: 'usr-sv-01',
    fullName: 'Lê Hoàng Quản Đốc',
    role: 'SUPERVISOR',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
  },
];

export const initialThresholdConfig: SystemThresholdConfig = {
  workshopId: 'ws-01',
  workshopName: 'Phân Xưởng A - Cơ Khí Dập & CNC',
  costApprovalThreshold: 2000000, // 2 triệu VND
  pmIntervals: [500, 1000, 2000],
};

export const initialMachines: Machine[] = [
  {
    id: 'mch-101',
    code: 'MC-101',
    name: 'Máy Dập Thủy Lực 500 Tấn',
    location: 'Xưởng 1 - Dây chuyền A',
    category: 'Máy Dập',
    status: 'ACTIVE',
    runningHours: 498.5,
    lastMaintenanceHours: 0,
    nextMaintenanceHours: 500,
    lastMaintenanceDate: '2026-06-10',
    specifications: {
      power: '45 kW',
      voltage: '380V / 50Hz',
      manufacturer: 'Komatsu Japan',
      year: 2022,
    },
    quickTroubleshooting: [
      {
        issue: 'Áp suất dầu thủy lực giảm dưới 150 Bar',
        solution: 'Kiểm tra mức dầu bình chứa, xiết van xả phụ và kiểm tra rò rỉ đường ống dẫn.',
      },
      {
        issue: 'Nhiệt độ động cơ vượt quá 85°C',
        solution: 'Tắt máy nghỉ 15 phút, vệ sinh bộ tản nhiệt quạt làm mát.',
      },
      {
        issue: 'Báo lỗi lệch hành trình con trượt E-04',
        solution: 'Kiểm tra cảm biến tiệm cận trục X, lau sạch bụi bẩn kim loại trên mắt đọc.',
      },
    ],
  },
  {
    id: 'mch-102',
    code: 'MC-102',
    name: 'Máy Trung Tâm Gia Công CNC 5 Trục',
    location: 'Xưởng 1 - Dây chuyền B',
    category: 'Gia Công CNC',
    status: 'REPAIRING',
    runningHours: 1240.2,
    lastMaintenanceHours: 1000,
    nextMaintenanceHours: 1500,
    lastMaintenanceDate: '2026-05-20',
    specifications: {
      power: '22 kW',
      voltage: '380V / 50Hz',
      manufacturer: 'DMG Mori Germany',
      year: 2023,
    },
    quickTroubleshooting: [
      {
        issue: 'Rung lắc bất thường trục chính Spindle',
        solution: 'Kiểm tra độ đảo dao clamping, xiết lại mâm kẹp thủy lực.',
      },
      {
        issue: 'Lỗi dao không đổi được Tool Change E-12',
        solution: 'Bấm dừng khẩn cấp, đưa tay gắp dao về vị trí gốc Manually.',
      },
    ],
  },
  {
    id: 'mch-201',
    code: 'MC-201',
    name: 'Dây Chuyền Hàn Robot Tự Động',
    location: 'Xưởng 2 - Dây chuyền C',
    category: 'Robot Công Nghiệp',
    status: 'MAINTENANCE',
    runningHours: 998.0,
    lastMaintenanceHours: 500,
    nextMaintenanceHours: 1000,
    lastMaintenanceDate: '2026-04-15',
    specifications: {
      power: '15 kW',
      voltage: '380V',
      manufacturer: 'KUKA Robotics',
      year: 2024,
    },
    quickTroubleshooting: [
      {
        issue: 'Hồ quang hàn bị ngắt quãng',
        solution: 'Thay đầu béc hàn (Contact Tip), kiểm tra dây dẫn béc hàn béc cấp bù.',
      },
    ],
  },
  {
    id: 'mch-305',
    code: 'MC-305',
    name: 'Máy Nén Khí Trục Vít Công Nghiệp',
    location: 'Trạm Khí Nén Phụ Trợ',
    category: 'Thiết Bị Phụ Trợ',
    status: 'ACTIVE',
    runningHours: 2350.0,
    lastMaintenanceHours: 2000,
    nextMaintenanceHours: 2500,
    lastMaintenanceDate: '2026-03-01',
    specifications: {
      power: '75 kW',
      voltage: '380V',
      manufacturer: 'Atlas Copco',
      year: 2021,
    },
    quickTroubleshooting: [
      {
        issue: 'Khí nén bị lẫn nhiều nước',
        solution: 'Xả van ngưng tụ tự động xả đáy bình lọc khí 15 phút/lần.',
      },
    ],
  },
  {
    id: 'mch-401',
    code: 'XN-401',
    name: 'Xe Nâng Dầu Komatsu 3.5 Tấn (Theo dõi KM)',
    location: 'Khu Vực Kho Vận & Logistic',
    category: 'Phương Tiện Nâng Hạ',
    status: 'ACTIVE',
    runningHours: 15420.0,
    lastMaintenanceHours: 15000,
    nextMaintenanceHours: 16000,
    lastMaintenanceDate: '2026-06-01',
    trackingUnit: 'KM',
    unitLabel: 'Km di chuyển',
    specifications: {
      power: 'Động cơ Diesel 45 HP',
      voltage: '12V Ắc quy',
      manufacturer: 'Komatsu Japan',
      year: 2023,
    },
    quickTroubleshooting: [
      {
        issue: 'Càng nâng hạ chậm, kêu rè rè',
        solution: 'Kiểm tra mức dầu nhớt thủy lực càng nâng, xả bọt khí đường ống.',
      },
      {
        issue: 'Áp suất lốp xe bị giảm',
        solution: 'Bơm lốp đạt 7.5 Bar, kiểm tra đinh găm bánh xe.',
      },
    ],
  },
];

export const initialWorkOrders: WorkOrder[] = [
  {
    id: 'wo-1001',
    code: 'SOS-2026-001',
    machineId: 'mch-102',
    machineName: 'Máy Trung Tâm Gia Công CNC 5 Trục',
    machineCode: 'MC-102',
    reporterId: 'usr-op-01',
    reporterName: 'Nguyễn Văn Nam',
    assigneeId: 'usr-me-01',
    assigneeName: 'Trần Minh Đức (ME)',
    severity: 'HIGH',
    description: 'Trục chính Spindle phát ra tiếng kêu rít lớn khi quay tốc độ > 8000 RPM, kẹt gắp dao tự động làm dừng toàn bộ chuyền B.',
    imageUrl: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500&auto=format&fit=crop&q=80',
    status: 'IN_PROGRESS',
    downtimeStart: '2026-07-23 13:15:00',
    createdAt: '2026-07-23 13:15:00',
    usedSpareParts: [
      { id: 'sp-1', name: 'Vòng bi cao tốc Spindle 7014C', quantity: 2, unitPrice: 2250000, totalCost: 4500000, requiresApproval: true, status: 'APPROVED' },
      { id: 'sp-2', name: 'Dầu bôi trơn trục chính Mobil Velvet', quantity: 1, unitPrice: 850000, totalCost: 850000, requiresApproval: false, status: 'APPROVED' },
    ],
  },
  {
    id: 'wo-1002',
    code: 'SOS-2026-002',
    machineId: 'mch-101',
    machineName: 'Máy Dập Thủy Lực 500 Tấn',
    machineCode: 'MC-101',
    reporterId: 'usr-op-01',
    reporterName: 'Nguyễn Văn Nam',
    severity: 'CRITICAL',
    description: 'Rò rỉ dầu thủy lực xi lanh ép chính, áp suất hạ dốc nguy cơ rơi khuôn dập.',
    imageUrl: 'https://images.unsplash.com/photo-1581092335397-9583fe92d232?w=500&auto=format&fit=crop&q=80',
    status: 'PENDING',
    downtimeStart: '2026-07-23 14:40:00',
    createdAt: '2026-07-23 14:40:00',
  },
];

export const initialPMChecklists: PMChecklist[] = [
  {
    id: 'pm-501',
    code: 'PM-2026-0500H',
    machineId: 'mch-201',
    machineName: 'Dây Chuyền Hàn Robot Tự Động',
    machineCode: 'MC-201',
    assigneeId: 'usr-me-01',
    assigneeName: 'Trần Minh Đức (ME)',
    scheduledHours: 1000,
    currentHours: 998,
    status: 'IN_PROGRESS',
    createdAt: '2026-07-23 08:00:00',
    items: [
      {
        id: 'pmi-1',
        taskDescription: 'Thay thế bộ béc hàn Contact Tip & chụp khí súng hàn Robot',
        isChecked: true,
        photoUrl: 'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?w=500&auto=format&fit=crop&q=80',
        isRequiredPhoto: true,
      },
      {
        id: 'pmi-2',
        taskDescription: 'Tra mỡ bôi trơn chuyên dụng mỡ chịu nhiệt các khớp xoay Axis 1 - Axis 6',
        isChecked: true,
        photoUrl: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500&auto=format&fit=crop&q=80',
        isRequiredPhoto: true,
      },
      {
        id: 'pmi-3',
        taskDescription: 'Kiểm tra độ chùng dây cáp tín hiệu nguồn encoder mắt đọc',
        isChecked: false,
        isRequiredPhoto: false,
      },
      {
        id: 'pmi-4',
        taskDescription: 'Vệ sinh hộp điều khiển tủ điện KRC4 & thay tấm lọc bụi quạt gió',
        isChecked: false,
        isRequiredPhoto: true,
      },
    ],
  },
];

export const initialSparePartRequests: SparePartRequest[] = [
  {
    id: 'spr-101',
    workOrderId: 'wo-1001',
    machineCode: 'MC-102',
    machineName: 'Máy CNC 5 Trục',
    requestedBy: 'Trần Minh Đức (ME)',
    partName: 'Cụm Van Điều Áp Thủy Lực PN-16',
    quantity: 1,
    unitPrice: 3500000,
    totalCost: 3500000,
    reason: 'Van cũ bị xước lòng ti xả, rò rỉ áp suất gây kẹt Spindle.',
    status: 'PENDING',
    createdAt: '2026-07-23 10:25:00',
  },
];

export const initialRunningHoursLogs: RunningHoursLog[] = [
  {
    id: 'log-01',
    machineId: 'mch-101',
    machineCode: 'MC-101',
    previousHours: 490.0,
    newHours: 498.5,
    shift: 'END_SHIFT',
    loggedBy: 'Nguyễn Văn Nam (Operator)',
    timestamp: '2026-07-23 06:00:00',
  },
];

export const initialNotifications: SystemNotification[] = [
  {
    id: 'noti-1',
    title: 'SỰ CỐ KHẨN CẤP (SOS)',
    message: 'Máy MC-101 vừa báo sự cố CRITICAL rò rỉ dầu thủy lực tại Xưởng 1 dây chuyền A!',
    type: 'SOS',
    timestamp: '14:40',
    read: false,
    targetId: 'wo-1002',
  },
  {
    id: 'noti-2',
    title: 'ĐỀ XUẤT VẬT TƯ ĐẮT TIỀN',
    message: 'Kỹ sư ME Trần Minh Đức đề xuất thay Cụm Van PN-16 (3.500.000đ) cho máy MC-102 - Chờ Supervisor duyệt!',
    type: 'APPROVAL',
    timestamp: '10:25',
    read: false,
    targetId: 'spr-101',
  },
  {
    id: 'noti-3',
    title: 'ĐẾN HẠN BẢO TRÌ (PM 1000H)',
    message: 'Máy MC-201 đã đạt 998h máy chạy, hệ thống đã giao phiếu PM Checklist cho kỹ sư ME.',
    type: 'PM',
    timestamp: '08:00',
    read: true,
    targetId: 'pm-501',
  },
];
