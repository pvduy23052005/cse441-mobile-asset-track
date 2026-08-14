import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { FirestoreCollection } from '../../common/constants/firestore-collections.enum';
import { FirestoreUser } from '../auth/auth.service';
import { FirebaseService } from '../firebase/firebase.service';
import { FirestoreMachine } from '../machine/machine.service';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationTypeEnum } from '../notifications/interfaces/notification.interface';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { TicketSeverity } from './enums/ticket-severity.enum';
import { TicketStatus } from './enums/ticket-status.enum';
import { FirestoreTicket, Ticket } from './interfaces/ticket.interface';

@Injectable()
export class TicketsService {
  private readonly logger = new Logger(TicketsService.name);
  private readonly collectionName = FirestoreCollection.TICKETS;

  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async create(
    reporterId: string,
    dto: CreateTicketDto,
    userRole?: string,
  ): Promise<Ticket> {
    if (!reporterId) {
      throw new BadRequestException('Không tìm thấy thông tin người báo cáo');
    }

    const firestore = this.firebaseService.firestore;
    const machineId = dto.machine_id?.trim();

    if (!machineId) {
      throw new BadRequestException(
        'Vui lòng cung cấp mã thiết bị (machine_id)',
      );
    }

    let machineDoc = await firestore
      .collection(FirestoreCollection.MACHINES)
      .doc(machineId)
      .get();

    if (!machineDoc.exists) {
      const queryByCode = await firestore
        .collection(FirestoreCollection.MACHINES)
        .where('code', '==', machineId)
        .limit(1)
        .get();

      if (!queryByCode.empty) {
        machineDoc = queryByCode.docs[0];
      } else {
        throw new NotFoundException(
          `Không tìm thấy thiết bị với ID hoặc mã '${machineId}'`,
        );
      }
    }

    const machineData = (machineDoc.data() as FirestoreMachine) || {};
    const actualMachineId = machineDoc.id;

    let reporterName = '';
    let reporterEmail = '';
    try {
      const reporterDoc = await firestore
        .collection('users')
        .doc(reporterId)
        .get();

      if (reporterDoc.exists) {
        const userData = (reporterDoc.data() as FirestoreUser) || {};
        reporterName = userData.fullName || userData.full_name || '';
        reporterEmail = userData.email || '';
      }
    } catch (err) {
      this.logger.warn(`Không thể lấy thông tin user '${reporterId}': ${err}`);
    }

    const now = new Date().toISOString();
    const severity = dto.severity || TicketSeverity.MEDIUM;

    const ticketData: FirestoreTicket = {
      machine_id: actualMachineId,
      reporter_id: reporterId,
      engineer_id: null,
      severity,
      status: TicketStatus.OPEN,
      description: dto.description || '',
      images_urls: dto.images_urls || [],
      downtime_start: dto.downtime_start || now,
      downtime_end: null,
      claimed_at: null,
      rejection_reason: null,
      cancelled_at: null,
      cancelled_reason: null,
      machine_name: machineData.name || '',
      machine_code: machineData.code || '',
      reporter_name: reporterName,
      reporter_email: reporterEmail,
      engineer_name: '',
      created_at: now,
      updated_at: now,
    };

    const docRef = await firestore
      .collection(this.collectionName)
      .add(ticketData);

    this.logger.log(
      `Đã tạo Ticket mới với ID: ${docRef.id} cho thiết bị: ${actualMachineId} bởi User: ${reporterId} (Role: ${userRole || 'N/A'})`,
    );

    // Tự động tạo bản ghi thông báo thật trên Firestore collection 'notifications'
    try {
      const isCritical =
        severity === TicketSeverity.CRITICAL ||
        severity === TicketSeverity.HIGH;
      await this.notificationsService.createNotification({
        title: isCritical ? 'SỰ CỐ KHẨN CẤP (SOS)' : 'BÁO SỰ CỐ MỚI',
        message: `Máy ${machineData.code || actualMachineId} (${machineData.name || 'Thiết bị'}) vừa báo sự cố [${severity}]: ${dto.description || 'Cần xử lý'}`,
        type: isCritical
          ? NotificationTypeEnum.SOS
          : NotificationTypeEnum.SYSTEM,
        target_role: 'ME_ENGINEER',
        target_id: docRef.id,
      });
    } catch (notiErr) {
      this.logger.warn(
        `Không thể tạo notification tự động cho Ticket ${docRef.id}: ${notiErr}`,
      );
    }

    return {
      id: docRef.id,
      ...ticketData,
    };
  }

  async getAllTickets(filters?: {
    status?: TicketStatus;
    machine_id?: string;
    reporter_id?: string;
  }): Promise<Ticket[]> {
    try {
      let query: FirebaseFirestore.Query =
        this.firebaseService.firestore.collection(this.collectionName);

      if (filters?.status) {
        query = query.where('status', '==', filters.status);
      }
      if (filters?.machine_id) {
        query = query.where('machine_id', '==', filters.machine_id);
      }
      if (filters?.reporter_id) {
        query = query.where('reporter_id', '==', filters.reporter_id);
      }

      const snapshot = await query.get();

      const tickets = snapshot.docs.map((doc) => {
        const data = doc.data() as FirestoreTicket;
        return {
          id: doc.id,
          machine_id: data.machine_id || '',
          reporter_id: data.reporter_id || '',
          engineer_id: data.engineer_id ?? null,
          severity: data.severity || TicketSeverity.MEDIUM,
          status: data.status || TicketStatus.OPEN,
          description: data.description || '',
          images_urls: data.images_urls || [],
          downtime_start: data.downtime_start || '',
          downtime_end: data.downtime_end ?? null,
          claimed_at: data.claimed_at ?? null,
          rejection_reason: data.rejection_reason ?? null,
          cancelled_at: data.cancelled_at ?? null,
          cancelled_reason: data.cancelled_reason ?? null,
          machine_name: data.machine_name || '',
          machine_code: data.machine_code || '',
          reporter_name: data.reporter_name || '',
          reporter_email: data.reporter_email || '',
          engineer_name: data.engineer_name || '',
          created_at: data.created_at || '',
          updated_at: data.updated_at || '',
        };
      });

      return tickets.sort(
        (a, b) =>
          new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
      );
    } catch (error) {
      this.logger.error(`Error fetching tickets: ${error}`);
      return [];
    }
  }

  async getTicketById(id: string): Promise<Ticket> {
    const doc = await this.firebaseService.firestore
      .collection(this.collectionName)
      .doc(id)
      .get();

    if (!doc.exists) {
      throw new NotFoundException(`Ticket with ID '${id}' not found`);
    }

    const data = doc.data() as FirestoreTicket;
    return {
      id: doc.id,
      machine_id: data.machine_id || '',
      reporter_id: data.reporter_id || '',
      engineer_id: data.engineer_id ?? null,
      severity: data.severity || TicketSeverity.MEDIUM,
      status: data.status || TicketStatus.OPEN,
      description: data.description || '',
      images_urls: data.images_urls || [],
      downtime_start: data.downtime_start || '',
      downtime_end: data.downtime_end ?? null,
      claimed_at: data.claimed_at ?? null,
      rejection_reason: data.rejection_reason ?? null,
      cancelled_at: data.cancelled_at ?? null,
      cancelled_reason: data.cancelled_reason ?? null,
      machine_name: data.machine_name || '',
      machine_code: data.machine_code || '',
      reporter_name: data.reporter_name || '',
      reporter_email: data.reporter_email || '',
      engineer_name: data.engineer_name || '',
      created_at: data.created_at || '',
      updated_at: data.updated_at || '',
    };
  }

  async getMyTickets(reporterId: string): Promise<Ticket[]> {
    return this.getAllTickets({ reporter_id: reporterId });
  }

  async cancelTicket(
    id: string,
    reporterId: string,
    reason?: string,
  ): Promise<Ticket> {
    const docRef = this.firebaseService.firestore
      .collection(this.collectionName)
      .doc(id);

    const doc = await docRef.get();
    if (!doc.exists) {
      throw new NotFoundException(`Ticket with ID '${id}' not found`);
    }

    const data = doc.data() as FirestoreTicket;
    if (data.reporter_id !== reporterId) {
      throw new ForbiddenException(
        'Bạn chỉ có thể hủy phiếu sự cố do chính mình tạo ra',
      );
    }

    if (data.status !== TicketStatus.OPEN) {
      throw new BadRequestException(
        'Chỉ có thể hủy phiếu sự cố khi đang ở trạng thái OPEN',
      );
    }

    const now = new Date().toISOString();
    await docRef.update({
      status: TicketStatus.CANCELLED,
      cancelled_at: now,
      cancelled_reason: reason || 'Người vận hành hủy báo nhầm',
      updated_at: now,
    });

    return this.getTicketById(id);
  }

  async claimTicket(id: string, engineerId: string): Promise<Ticket> {
    const docRef = this.firebaseService.firestore
      .collection(this.collectionName)
      .doc(id);

    const doc = await docRef.get();
    if (!doc.exists) {
      throw new NotFoundException(`Ticket with ID '${id}' not found`);
    }

    let engineerName = '';
    try {
      const userDoc = await this.firebaseService.firestore
        .collection('users')
        .doc(engineerId)
        .get();
      if (userDoc.exists) {
        const u = userDoc.data() || {};
        engineerName = u.fullName || u.full_name || u.email || '';
      }
    } catch (_) {}

    const now = new Date().toISOString();
    await docRef.update({
      status: TicketStatus.IN_PROGRESS,
      engineer_id: engineerId,
      engineer_name: engineerName,
      claimed_at: now,
      updated_at: now,
    });

    this.logger.log(
      `Ticket '${id}' đã được Kỹ sư '${engineerId}' tiếp nhận xử lý.`,
    );
    return this.getTicketById(id);
  }

  async completeTicket(
    id: string,
    engineerId: string,
    usedSpareParts?: any[],
  ): Promise<Ticket> {
    const docRef = this.firebaseService.firestore
      .collection(this.collectionName)
      .doc(id);

    const doc = await docRef.get();
    if (!doc.exists) {
      throw new NotFoundException(`Ticket with ID '${id}' not found`);
    }

    const now = new Date().toISOString();
    await docRef.update({
      status: TicketStatus.PENDING_APPROVAL,
      downtime_end: now,
      used_spare_parts: usedSpareParts || [],
      updated_at: now,
    });

    this.logger.log(
      `Ticket '${id}' đã được Kỹ sư '${engineerId}' hoàn thành và gửi nghiệm thu.`,
    );
    return this.getTicketById(id);
  }

  async rejectTicket(id: string, rejectionReason?: string): Promise<Ticket> {
    const docRef = this.firebaseService.firestore
      .collection(this.collectionName)
      .doc(id);

    const doc = await docRef.get();
    if (!doc.exists) {
      throw new NotFoundException(`Ticket with ID '${id}' not found`);
    }

    const now = new Date().toISOString();
    await docRef.update({
      status: TicketStatus.REJECTED,
      rejection_reason: rejectionReason || 'Chưa đạt yêu cầu nghiệm thu',
      updated_at: now,
    });

    this.logger.log(`Ticket '${id}' đã bị Quản đốc từ chối nghiệm thu.`);
    return this.getTicketById(id);
  }
}
