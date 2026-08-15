import {
  Injectable,
  Logger,
  NotFoundException,
  OnModuleInit,
} from '@nestjs/common';
import * as QRCode from 'qrcode';
import { FirebaseService } from '../firebase/firebase.service';

export interface Machine {
  id: string;
  code: string;
  name: string;
  model: string;
  location?: string;
  next_maintenance_hours?: number;
  specifications: Record<string, any>;
  status: string;
  running_hours: number;
  createdAt?: string;
  updatedAt?: string;
  [key: string]: any;
}

export interface FirestoreMachine {
  code?: string;
  name?: string;
  model?: string;
  location?: string;
  next_maintenance_hours?: number;
  specifications?: Record<string, any>;
  status?: string;
  running_hours?: number;
  createdAt?: string;
  updatedAt?: string;
}

export interface WorkOrder {
  id: string;
  code: string;
  machineId: string;
  machineName: string;
  severity: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW';
  status: 'PENDING' | 'IN_PROGRESS' | 'COMPLETED' | 'APPROVED' | 'REJECTED';
  description: string;
  imageUrl?: string;
  assigneeName?: string;
  rejectionReason?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface FirestoreWorkOrder {
  code?: string;
  machineId?: string;
  machineName?: string;
  severity?: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW';
  status?: 'PENDING' | 'IN_PROGRESS' | 'COMPLETED' | 'APPROVED' | 'REJECTED';
  description?: string;
  imageUrl?: string;
  assigneeName?: string;
  rejectionReason?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface PMChecklist {
  id: string;
  code: string;
  machineId: string;
  machineName: string;
  scheduledHours: number;
  status: 'PENDING' | 'IN_PROGRESS' | 'COMPLETED' | 'APPROVED';
  itemCount: number;
  items?: PMChecklistItem[];
  createdAt?: string;
  updatedAt?: string;
}

export interface FirestorePMChecklist {
  code?: string;
  machineId?: string;
  machineName?: string;
  scheduledHours?: number;
  status?: 'PENDING' | 'IN_PROGRESS' | 'COMPLETED' | 'APPROVED';
  itemCount?: number;
  items?: PMChecklistItem[];
  createdAt?: string;
  updatedAt?: string;
}

export interface PMChecklistItem {
  id?: string;
  pmChecklistId?: string;
  taskDescription: string;
  isChecked: boolean;
  photoRequired: boolean;
  photoUrl?: string;
}

export interface RunningHoursLog {
  id?: string;
  machineId: string;
  machineCode: string;
  previousHours: number;
  newHours: number;
  shift: 'START_SHIFT' | 'END_SHIFT';
  loggedBy: string;
  timestamp: string;
}

export interface SparePartLog {
  id?: string;
  workOrderId?: string;
  pmChecklistId?: string;
  partName: string;
  quantity: number;
  unit: string;
  loggedAt: string;
  loggedBy: string;
}

export interface SparePartsRequest {
  id: string;
  workOrderId?: string;
  pmChecklistId?: string;
  requestedBy: string;
  partName: string;
  quantity: number;
  unitPrice: number;
  totalCost: number;
  reason: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  rejectionReason?: string;
  createdAt?: string;
}

export interface WorkshopConfig {
  id: string;
  workshopId: string;
  machineModel: string;
  pmThresholdHours: number[];
  costApprovalThreshold: number;
  updatedAt?: string;
}

export interface MachineQrCodeResponse {
  machineId: string;
  code: string;
  name: string;
  qrCode: string;
}

@Injectable()
export class MachineService implements OnModuleInit {
  private readonly logger = new Logger(MachineService.name);

  // Collections as per system_design.md
  private readonly machinesCollection = 'machines';
  private readonly workOrdersCollection = 'work_orders';
  private readonly pmChecklistsCollection = 'pm_checklists';
  private readonly pmChecklistItemsCollection = 'pm_checklist_items';
  private readonly runningHoursLogsCollection = 'running_hours_logs';
  private readonly sparePartLogsCollection = 'spare_part_logs';
  private readonly sparePartsRequestsCollection = 'spare_parts_requests';
  private readonly workshopConfigsCollection = 'workshop_configs';

  constructor(private readonly firebaseService: FirebaseService) {}

  async onModuleInit() {
    await this.seedAllFirebaseCollections();
  }

  async getAllMachines(): Promise<Machine[]> {
    try {
      const snapshot = await this.firebaseService.firestore
        .collection(this.machinesCollection)
        .get();

      return snapshot.docs.map((doc) => {
        const data = doc.data() as FirestoreMachine;
        return {
          id: doc.id,
          code: data.code || '',
          name: data.name || '',
          model: data.model || '',
          location: data.location || '',
          next_maintenance_hours: data.next_maintenance_hours,
          specifications: data.specifications || {},
          status: data.status || 'ACTIVE',
          running_hours: data.running_hours ?? 0,
          createdAt: data.createdAt,
          updatedAt: data.updatedAt,
        };
      });
    } catch (error) {
      this.logger.error(`Error fetching machines from Firestore: ${error}`);
      return [];
    }
  }

  async getMachineById(id: string): Promise<Machine> {
    const doc = await this.firebaseService.firestore
      .collection(this.machinesCollection)
      .doc(id)
      .get();

    if (!doc.exists) {
      throw new NotFoundException(`Machine with ID '${id}' not found`);
    }

    const data = (doc.data() as FirestoreMachine) || {};
    return {
      id: doc.id,
      code: data.code || '',
      name: data.name || '',
      model: data.model || '',
      location: data.location || '',
      next_maintenance_hours: data.next_maintenance_hours,
      specifications: data.specifications || {},
      status: data.status || 'ACTIVE',
      running_hours: data.running_hours ?? 0,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    };
  }

  async updateMachineStatus(id: string, status: string): Promise<Machine> {
    const docRef = this.firebaseService.firestore
      .collection(this.machinesCollection)
      .doc(id);

    const doc = await docRef.get();
    if (!doc.exists) {
      throw new NotFoundException(`Machine with ID '${id}' not found`);
    }

    const updatedAt = new Date().toISOString();
    await docRef.update({
      status: status.toUpperCase(),
      updatedAt,
    });

    return this.getMachineById(id);
  }

  async updateMachine(
    id: string,
    data: Partial<FirestoreMachine>,
  ): Promise<Machine> {
    const docRef = this.firebaseService.firestore
      .collection(this.machinesCollection)
      .doc(id);

    const doc = await docRef.get();
    if (!doc.exists) {
      throw new NotFoundException(`Machine with ID '${id}' not found`);
    }

    const updatedAt = new Date().toISOString();
    await docRef.update({
      ...data,
      updatedAt,
    });

    return this.getMachineById(id);
  }

  // Work Orders Firestore API
  async getWorkOrders(): Promise<WorkOrder[]> {
    try {
      const snapshot = await this.firebaseService.firestore
        .collection(this.workOrdersCollection)
        .get();

      return snapshot.docs.map((doc) => {
        const data = doc.data() as FirestoreWorkOrder;
        return {
          id: doc.id,
          code: data.code || '',
          machineId: data.machineId || '',
          machineName: data.machineName || '',
          severity: data.severity || 'LOW',
          status: data.status || 'PENDING',
          description: data.description || '',
          imageUrl: data.imageUrl,
          assigneeName: data.assigneeName,
          rejectionReason: data.rejectionReason,
          createdAt: data.createdAt,
          updatedAt: data.updatedAt,
        };
      });
    } catch (error) {
      this.logger.error(`Error fetching work orders from Firestore: ${error}`);
      return [];
    }
  }

  async updateWorkOrderStatus(id: string, status: string): Promise<WorkOrder> {
    const docRef = this.firebaseService.firestore
      .collection(this.workOrdersCollection)
      .doc(id);

    const doc = await docRef.get();
    if (!doc.exists) {
      throw new NotFoundException(`WorkOrder with ID '${id}' not found`);
    }

    const updatedAt = new Date().toISOString();
    await docRef.update({
      status: status.toUpperCase(),
      updatedAt,
    });

    const updatedDoc = await docRef.get();
    const data = (updatedDoc.data() as FirestoreWorkOrder) || {};
    return {
      id: updatedDoc.id,
      code: data.code || '',
      machineId: data.machineId || '',
      machineName: data.machineName || '',
      severity: data.severity || 'LOW',
      status: data.status || 'PENDING',
      description: data.description || '',
      imageUrl: data.imageUrl,
      assigneeName: data.assigneeName,
      rejectionReason: data.rejectionReason,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    };
  }

  // PM Checklists Firestore API
  async getPMChecklists(): Promise<PMChecklist[]> {
    try {
      const snapshot = await this.firebaseService.firestore
        .collection(this.pmChecklistsCollection)
        .get();

      return snapshot.docs.map((doc) => {
        const data = doc.data() as FirestorePMChecklist;
        return {
          id: doc.id,
          code: data.code || '',
          machineId: data.machineId || '',
          machineName: data.machineName || '',
          scheduledHours: data.scheduledHours || 0,
          status: data.status || 'PENDING',
          itemCount: data.itemCount || 0,
          createdAt: data.createdAt,
          updatedAt: data.updatedAt,
        };
      });
    } catch (error) {
      this.logger.error(
        `Error fetching PM checklists from Firestore: ${error}`,
      );
      return [];
    }
  }

  async generateMachineQrCode(id: string): Promise<MachineQrCodeResponse> {
    const machine = await this.getMachineById(id);

    const qrDataUrl = await QRCode.toDataURL(machine.id, {
      errorCorrectionLevel: 'H',
      type: 'image/png',
      margin: 2,
      width: 320,
      color: {
        dark: '#000000',
        light: '#ffffff',
      },
    });

    return {
      machineId: machine.id,
      code: machine.code,
      name: machine.name,
      qrCode: qrDataUrl,
    };
  }

  // Auto seed missing Firebase collections matching system_design.md
  async seedAllFirebaseCollections() {
    try {
      // 1. Check & Seed Work Orders
      const woSnap = await this.firebaseService.firestore
        .collection(this.workOrdersCollection)
        .get();

      if (woSnap.empty) {
        this.logger.log(
          'Seeding collection: work_orders into Firebase Firestore...',
        );
        const defaultWorkOrders = [
          {
            code: 'SOS-2026-001',
            machineId: 'MC-101',
            machineName: 'Máy Trung Tâm Gia Công CNC 5 Trục',
            severity: 'HIGH',
            status: 'IN_PROGRESS',
            description:
              'Trục chính Spindle phát ra tiếng kêu rít lớn khi quay tốc độ > 8000 RPM, kẹt gắp dao tự động làm dừng toàn bộ chuyển B.',
            imageUrl:
              'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500',
            assigneeName: 'Kỹ Sư ME Trần Minh Đức',
            createdAt: new Date().toISOString(),
          },
          {
            code: 'SOS-2026-002',
            machineId: 'MC-102',
            machineName: 'Máy Dập Thủy Lực 500 Tấn',
            severity: 'CRITICAL',
            status: 'PENDING',
            description:
              'Rò rỉ dầu thủy lực xi lanh ép chính, áp suất hạ dốc nguy cơ rơi khuôn dập.',
            createdAt: new Date().toISOString(),
          },
          {
            code: 'SOS-2026-003',
            machineId: 'MC-103',
            machineName: 'Máy Nén Khí Trục Vít Công Nghiệp',
            severity: 'MEDIUM',
            status: 'PENDING',
            description:
              'Áp suất khí nén đầu ra tụt giảm dưới 4.5 Bar, bình tách dầu phát tiếng ồn lạ tại van xả an toàn.',
            imageUrl:
              'https://images.unsplash.com/photo-1581092335397-9583fe92d232?w=500',
            createdAt: new Date().toISOString(),
          },
        ];

        for (const wo of defaultWorkOrders) {
          await this.firebaseService.firestore
            .collection(this.workOrdersCollection)
            .add(wo);
        }
      }

      // 2. Check & Seed PM Checklists & Items
      const pmSnap = await this.firebaseService.firestore
        .collection(this.pmChecklistsCollection)
        .get();

      if (pmSnap.empty) {
        this.logger.log(
          'Seeding collection: pm_checklists into Firebase Firestore...',
        );
        const pmDocRef = await this.firebaseService.firestore
          .collection(this.pmChecklistsCollection)
          .add({
            code: 'PM-2026-0500H',
            machineId: 'MC-105',
            machineName: 'Dây Chuyền Hàn Robot Tự Động',
            scheduledHours: 1000,
            status: 'PENDING',
            itemCount: 3,
            createdAt: new Date().toISOString(),
          });

        const pmItems = [
          {
            pmChecklistId: pmDocRef.id,
            taskDescription: 'Thay dầu bôi trơn động cơ ép chính và xả cặn đáy',
            isChecked: false,
            photoRequired: true,
          },
          {
            pmChecklistId: pmDocRef.id,
            taskDescription:
              'Kiểm tra áp suất khí nén đầu vào và điều chỉnh van an toàn',
            isChecked: false,
            photoRequired: false,
          },
          {
            pmChecklistId: pmDocRef.id,
            taskDescription:
              'Siết chặt bu-lông chân máy và kiểm tra độ chùng dây curoa',
            isChecked: false,
            photoRequired: true,
          },
        ];

        for (const item of pmItems) {
          await this.firebaseService.firestore
            .collection(this.pmChecklistItemsCollection)
            .add(item);
        }
      }

      // 3. Check & Seed Running Hours Logs (Usage Logs)
      const rhlSnap = await this.firebaseService.firestore
        .collection(this.runningHoursLogsCollection)
        .get();

      if (rhlSnap.empty) {
        this.logger.log(
          'Seeding collection: running_hours_logs into Firebase Firestore...',
        );
        await this.firebaseService.firestore
          .collection(this.runningHoursLogsCollection)
          .add({
            machineId: 'MC-101',
            machineCode: 'MC-101',
            previousHours: 800,
            newHours: 850,
            shift: 'END_SHIFT',
            loggedBy: 'Nguyễn Văn Nam (Operator)',
            timestamp: new Date().toISOString(),
          });
      }

      // 4. Check & Seed Spare Part Logs
      const splSnap = await this.firebaseService.firestore
        .collection(this.sparePartLogsCollection)
        .get();

      if (splSnap.empty) {
        this.logger.log(
          'Seeding collection: spare_part_logs into Firebase Firestore...',
        );
        await this.firebaseService.firestore
          .collection(this.sparePartLogsCollection)
          .add({
            workOrderId: 'wo-101',
            partName: 'Dầu bôi trơn tổng hợp ISO VG 68',
            quantity: 5,
            unit: 'Lít',
            loggedAt: new Date().toISOString(),
            loggedBy: 'Trần Minh Đức (ME)',
          });
      }

      // 5. Check & Seed Spare Parts Requests
      const sprSnap = await this.firebaseService.firestore
        .collection(this.sparePartsRequestsCollection)
        .get();

      if (sprSnap.empty) {
        this.logger.log(
          'Seeding collection: spare_parts_requests into Firebase Firestore...',
        );
        await this.firebaseService.firestore
          .collection(this.sparePartsRequestsCollection)
          .add({
            workOrderId: 'wo-101',
            requestedBy: 'Trần Minh Đức (ME)',
            partName: 'Vòng bi cao tốc 7014C',
            quantity: 2,
            unitPrice: 1200000,
            totalCost: 2400000,
            reason: 'Thay thế vòng bi kẹt hỏng trục chính Spindle',
            status: 'PENDING',
            createdAt: new Date().toISOString(),
          });
      }

      // 6. Check & Seed Workshop Configs
      const cfgSnap = await this.firebaseService.firestore
        .collection(this.workshopConfigsCollection)
        .get();

      if (cfgSnap.empty) {
        this.logger.log(
          'Seeding collection: workshop_configs into Firebase Firestore...',
        );
        await this.firebaseService.firestore
          .collection(this.workshopConfigsCollection)
          .add({
            workshopId: 'ws-main-01',
            machineModel: 'ALL',
            pmThresholdHours: [500, 1000, 2000, 5000],
            costApprovalThreshold: 2000000,
            updatedAt: new Date().toISOString(),
          });
      }

      this.logger.log(
        'All missing Firebase collections checked & seeded successfully!',
      );
    } catch (e) {
      this.logger.error(`Error seeding Firebase collections: ${e}`);
    }
  }
}
