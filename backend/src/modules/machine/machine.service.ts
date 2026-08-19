import {
  Injectable,
  Logger,
  NotFoundException,
  OnModuleInit,
} from '@nestjs/common';
import * as QRCode from 'qrcode';
import { FirebaseService } from '../firebase/firebase.service';

export interface MachineOperatorInfo {
  id: string;
  fullName: string;
  email: string;
  phone?: string;
  role?: string;
}

export interface Machine {
  id: string;
  code: string;
  name: string;
  model: string;
  location?: string;
  next_maintenance_hours?: number;
  specifications: Record<string, any>;
  quick_troubleshooting?: Array<{ issue: string; solution: string }>;
  status: string;
  running_hours: number;
  operator_id?: string;
  operator?: MachineOperatorInfo | null;
  createdAt?: string;
  updatedAt?: string;
}

export interface FirestoreMachine {
  code?: string;
  name?: string;
  model?: string;
  location?: string;
  next_maintenance_hours?: number;
  specifications?: Record<string, any>;
  quick_troubleshooting?: Array<{ issue: string; solution: string }>;
  status?: string;
  running_hours?: number;
  operator_id?: string;
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
  ticketId?: string;
  pmChecklistId?: string;
  partName: string;
  quantity: number;
  unit: string;
  loggedAt: string;
  loggedBy: string;
}

export interface SparePartsRequest {
  id: string;
  ticketId?: string;
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

  private async getOperatorInfo(
    operatorId?: string,
  ): Promise<MachineOperatorInfo | null> {
    if (!operatorId) return null;
    try {
      const userDoc = await this.firebaseService.firestore
        .collection('users')
        .doc(operatorId)
        .get();

      if (userDoc.exists) {
        const userData = (userDoc.data() || {}) as Record<string, unknown>;
        return {
          id: userDoc.id,
          fullName:
            (typeof userData['full_name'] === 'string'
              ? userData['full_name']
              : typeof userData['fullName'] === 'string'
                ? userData['fullName']
                : typeof userData['name'] === 'string'
                  ? userData['name']
                  : '') || '',
          email: typeof userData['email'] === 'string' ? userData['email'] : '',
          phone:
            typeof userData['phone'] === 'string'
              ? userData['phone']
              : typeof userData['phoneNumber'] === 'string'
                ? userData['phoneNumber']
                : undefined,
          role:
            typeof userData['role'] === 'string'
              ? userData['role']
              : 'operator',
        };
      }
      return null;
    } catch (e) {
      this.logger.warn(`Error fetching operator info for ${operatorId}: ${e}`);
      return null;
    }
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
          quick_troubleshooting: data.quick_troubleshooting || [],
          status: data.status || 'ACTIVE',
          running_hours: data.running_hours ?? 0,
          operator_id: data.operator_id || undefined,
          createdAt: data.createdAt,
          updatedAt: data.updatedAt,
        };
      });
    } catch (error) {
      this.logger.error(`Error fetching machines from Firestore: ${error}`);
      return [];
    }
  }

  async getMachinesForUser(
    role?: string,
    userId?: string,
  ): Promise<Machine[]> {
    const allMachines = await this.getAllMachines();
    const normalizedRole = role?.toLowerCase();

    if (normalizedRole !== 'operator') {
      return allMachines;
    }

    if (!userId) {
      return [];
    }

    const cleanUserId = userId.trim();
    return allMachines.filter((machine) => machine.operator_id === cleanUserId);
  }

  async getMachineById(id: string): Promise<Machine> {
    const cleanId = (id || '').trim();
    if (!cleanId) {
      throw new NotFoundException('Mã hoặc ID thiết bị không được để trống');
    }

    const docRef = this.firebaseService.firestore
      .collection(this.machinesCollection)
      .doc(cleanId);
    const doc = await docRef.get();

    if (!doc.exists) {
      // 1. Try exact code match
      let querySnapshot = await this.firebaseService.firestore
        .collection(this.machinesCollection)
        .where('code', '==', cleanId)
        .limit(1)
        .get();

      if (querySnapshot.empty) {
        querySnapshot = await this.firebaseService.firestore
          .collection(this.machinesCollection)
          .where('code', '==', cleanId.toUpperCase())
          .limit(1)
          .get();
      }

      if (querySnapshot.empty) {
        querySnapshot = await this.firebaseService.firestore
          .collection(this.machinesCollection)
          .where('code', '==', cleanId.toLowerCase())
          .limit(1)
          .get();
      }

      if (!querySnapshot.empty) {
        const foundDoc = querySnapshot.docs[0];
        const data = foundDoc.data() as FirestoreMachine;
        const operator = await this.getOperatorInfo(data.operator_id);
        return {
          id: foundDoc.id,
          code: data.code || '',
          name: data.name || '',
          model: data.model || '',
          location: data.location || '',
          next_maintenance_hours: data.next_maintenance_hours,
          specifications: data.specifications || {},
          quick_troubleshooting: data.quick_troubleshooting || [],
          status: data.status || 'ACTIVE',
          running_hours: data.running_hours ?? 0,
          operator_id: data.operator_id || undefined,
          operator,
          createdAt: data.createdAt,
          updatedAt: data.updatedAt,
        };
      }

      const all = await this.getAllMachines();
      const lower = cleanId.toLowerCase();
      const strippedLower = lower.replace(/[^a-z0-9]/g, '');

      const found = all.find(
        (m) =>
          m.id.toLowerCase() === lower ||
          m.code.toLowerCase() === lower ||
          m.name.toLowerCase() === lower ||
          (strippedLower.length >= 2 &&
            m.code.toLowerCase().replace(/[^a-z0-9]/g, '') === strippedLower),
      );

      if (found) {
        const operator = await this.getOperatorInfo(found.operator_id);
        return { ...found, operator };
      }

      throw new NotFoundException(`Machine with ID or Code '${cleanId}' not found`);
    }

    const data = doc.data() as FirestoreMachine;
    const operator = await this.getOperatorInfo(data.operator_id);
    return {
      id: doc.id,
      code: data.code || '',
      name: data.name || '',
      model: data.model || '',
      location: data.location || '',
      next_maintenance_hours: data.next_maintenance_hours,
      specifications: data.specifications || {},
      quick_troubleshooting: data.quick_troubleshooting || [],
      status: data.status || 'ACTIVE',
      running_hours: data.running_hours ?? 0,
      operator_id: data.operator_id || undefined,
      operator,
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
      const querySnapshot = await this.firebaseService.firestore
        .collection(this.machinesCollection)
        .where('code', '==', id)
        .limit(1)
        .get();

      if (querySnapshot.empty) {
        throw new NotFoundException(`Machine with ID or Code '${id}' not found`);
      }

      const foundDoc = querySnapshot.docs[0];
      const updatedAt = new Date().toISOString();
      await foundDoc.ref.update({
        status: status.toUpperCase(),
        updatedAt,
      });

      return this.getMachineById(foundDoc.id);
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
      const querySnapshot = await this.firebaseService.firestore
        .collection(this.machinesCollection)
        .where('code', '==', id)
        .limit(1)
        .get();

      if (querySnapshot.empty) {
        throw new NotFoundException(`Machine with ID or Code '${id}' not found`);
      }

      const foundDoc = querySnapshot.docs[0];
      const updatedAt = new Date().toISOString();
      await foundDoc.ref.update({
        ...data,
        updatedAt,
      });

      return this.getMachineById(foundDoc.id);
    }

    const updatedAt = new Date().toISOString();
    await docRef.update({
      ...data,
      updatedAt,
    });

    return this.getMachineById(id);
  }

  async assignOperator(id: string, operatorId: string): Promise<Machine> {
    const docRef = this.firebaseService.firestore
      .collection(this.machinesCollection)
      .doc(id);

    let doc = await docRef.get();
    let machineId = id;

    if (!doc.exists) {
      const querySnapshot = await this.firebaseService.firestore
        .collection(this.machinesCollection)
        .where('code', '==', id)
        .limit(1)
        .get();

      if (querySnapshot.empty) {
        throw new NotFoundException(`Machine with ID or Code '${id}' not found`);
      }

      doc = querySnapshot.docs[0];
      machineId = doc.id;
    }

    const updatedAt = new Date().toISOString();
    await doc.ref.update({
      operator_id: operatorId ? operatorId.trim() : null,
      updatedAt,
    });

    return this.getMachineById(machineId);
  }

  async createMachine(data: Partial<FirestoreMachine>): Promise<Machine> {
    const now = new Date().toISOString();
    const code = data.code ? data.code.trim().toUpperCase() : `MC-${Date.now()}`;
    const docRef = this.firebaseService.firestore
      .collection(this.machinesCollection)
      .doc();

    const machineDoc: FirestoreMachine = {
      code,
      name: data.name ? data.name.trim() : 'Thiết bị mới',
      model: data.model
        ? data.model.trim()
        : ((data.specifications?.category as string) || 'Chưa xác định'),
      location: data.location ? data.location.trim() : 'Phân Xưởng Sản Xuất',
      status: (data.status || 'ACTIVE').toUpperCase(),
      running_hours: Number(data.running_hours ?? 0),
      next_maintenance_hours: Number(data.next_maintenance_hours ?? 500),
      quick_troubleshooting: data.quick_troubleshooting || [],
      specifications: data.specifications || {},
      createdAt: now,
      updatedAt: now,
    };

    await docRef.set(machineDoc);
    this.logger.log(`Đã tạo hồ sơ máy mới: [${code}] ${machineDoc.name}`);

    return this.getMachineById(docRef.id);
  }

  async logRunningHours(
    id: string,
    runningHours: number,
    loggedBy?: string,
    shift?: string,
  ): Promise<Machine> {
    const docRef = this.firebaseService.firestore
      .collection(this.machinesCollection)
      .doc(id);

    let doc = await docRef.get();
    let machineId = id;

    if (!doc.exists) {
      const querySnapshot = await this.firebaseService.firestore
        .collection(this.machinesCollection)
        .where('code', '==', id)
        .limit(1)
        .get();

      if (querySnapshot.empty) {
        throw new NotFoundException(`Machine with ID or Code '${id}' not found`);
      }

      doc = querySnapshot.docs[0];
      machineId = doc.id;
    }

    const machineData = doc.data() as FirestoreMachine;
    const previousHours = machineData.running_hours ?? 0;
    const newHours = Number(runningHours);
    const nextMaint = machineData.next_maintenance_hours ?? 500;

    const updatedAt = new Date().toISOString();

    await doc.ref.update({
      running_hours: newHours,
      updatedAt,
    });

    await this.firebaseService.firestore
      .collection(this.runningHoursLogsCollection)
      .add({
        machineId: machineId,
        machineCode: machineData.code || machineId,
        machineName: machineData.name || '',
        previousHours: previousHours,
        newHours: newHours,
        shift: shift || 'CA_HIEN_TAI',
        loggedBy: loggedBy || 'Operator',
        timestamp: updatedAt,
      });

    this.logger.log(
      `Đã cập nhật giờ chạy máy ${machineData.code || machineId}: ${previousHours}h -> ${newHours}h bởi ${loggedBy || 'Operator'}`,
    );

    // Auto-trigger PM Checklist creation if running hours reach or exceed next maintenance threshold
    if (newHours >= nextMaint) {
      const nextThreshold = nextMaint + 500;
      const pmCode = `PM-2026-${Math.round(nextMaint)}H`;

      const pmCheckSnap = await this.firebaseService.firestore
        .collection(this.pmChecklistsCollection)
        .where('code', '==', pmCode)
        .limit(1)
        .get();

      if (pmCheckSnap.empty) {
        const pmDocRef = await this.firebaseService.firestore
          .collection(this.pmChecklistsCollection)
          .add({
            code: pmCode,
            machineId: machineId,
            machineName: machineData.name || 'Thiết bị nhà xưởng',
            scheduledHours: nextMaint,
            status: 'PENDING',
            itemCount: 3,
            createdAt: updatedAt,
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

        this.logger.log(
          `⚡ TỰ ĐỘNG KÍCH HOẠT: Tạo phiếu PM mới ${pmCode} cho máy ${machineData.code || machineId} (${newHours}h >= ${nextMaint}h)!`,
        );
      }

      await doc.ref.update({
        next_maintenance_hours: nextThreshold,
        status: 'MAINTENANCE',
      });
    }

    return this.getMachineById(machineId);
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

  async submitPMChecklist(
    id: string,
    body: {
      items?: any[];
      used_spare_parts?: any[];
      engineer_name?: string;
    },
  ): Promise<any> {
    const docRef = this.firebaseService.firestore
      .collection(this.pmChecklistsCollection)
      .doc(id);

    const doc = await docRef.get();
    const currentTime = new Date().toISOString();

    let code = id.startsWith('PM') ? id : 'PM-2026-0500H';
    let machineId = 'm4';
    const machineCode = 'ROBOT-2024-004';
    let machineName = 'Dây Chuyền Hàn Robot Tự Động';

    if (doc.exists) {
      const data = doc.data() as FirestorePMChecklist;
      code = data.code || code;
      machineId = data.machineId || machineId;
      machineName = data.machineName || machineName;
      await docRef.update({
        status: 'COMPLETED',
        items: body.items || data.items || [],
        updatedAt: currentTime,
      });
    } else {
      // Fallback: search by code query if doc.id didn't match directly
      const byCodeSnap = await this.firebaseService.firestore
        .collection(this.pmChecklistsCollection)
        .where('code', '==', id)
        .limit(1)
        .get();

      if (!byCodeSnap.empty) {
        const foundDoc = byCodeSnap.docs[0];
        const data = foundDoc.data() as FirestorePMChecklist;
        code = data.code || code;
        machineId = data.machineId || machineId;
        machineName = data.machineName || machineName;
        await foundDoc.ref.update({
          status: 'COMPLETED',
          items: body.items || data.items || [],
          updatedAt: currentTime,
        });
      }
    }

    // Connect to tickets collection so Supervisor approval list sees this PM checklist
    const ticketsCollection = this.firebaseService.firestore.collection('tickets');
    const existingTicketQuery = await ticketsCollection
      .where('code', '==', code)
      .limit(1)
      .get();

    let ticketId = id;
    const ticketPayload = {
      code: code,
      title: `Nghiệm Thu Bảo Trì: ${code}`,
      machine_id: machineId,
      machine_code: machineCode,
      machine_name: machineName,
      description: `Bảo trì định kỳ mốc 1000h cho ${machineName}`,
      severity: 'MEDIUM',
      status: 'PENDING_APPROVAL',
      engineer_name: body.engineer_name || 'Kỹ Sư ME Trần Minh Đức',
      used_spare_parts: body.used_spare_parts || [],
      updated_at: currentTime,
      downtime_start: currentTime,
      downtime_end: currentTime,
    };

    if (!existingTicketQuery.empty) {
      const tDoc = existingTicketQuery.docs[0];
      ticketId = tDoc.id;
      await tDoc.ref.update(ticketPayload);
    } else {
      const newRef = await ticketsCollection.add({
        ...ticketPayload,
        created_at: currentTime,
      });
      ticketId = newRef.id;
    }

    return {
      id,
      ticketId,
      code,
      status: 'COMPLETED',
      message: 'Đã gửi nghiệm thu PM thành công!',
    };
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
      // 1. Check & Seed PM Checklists & Items
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

      // 2. Check & Seed Running Hours Logs (Usage Logs)
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

      // 3. Check & Seed Spare Part Logs
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
            ticketId: 'ticket-101',
            partName: 'Dầu bôi trơn tổng hợp ISO VG 68',
            quantity: 5,
            unit: 'Lít',
            loggedAt: new Date().toISOString(),
            loggedBy: 'Trần Minh Đức (ME)',
          });
      }

      // 4. Check & Seed Spare Parts Requests
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
            ticketId: 'ticket-101',
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

      // 5. Check & Seed Workshop Configs
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
