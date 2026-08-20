import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { FirestoreCollection } from '../../common/constants/firestore-collections.enum';
import { UserRole } from '../../common/constants/user-role.enum';
import { FirestoreUser } from '../auth/auth.service';
import { FirebaseService } from '../firebase/firebase.service';
import { FirestoreMachine } from '../machine/machine.service';
import { NotificationTypeEnum } from '../notifications/interfaces/notification.interface';
import { NotificationsService } from '../notifications/notifications.service';
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

  private get collection() {
    return this.firebaseService.firestore.collection(this.collectionName);
  }

  private mapTicket(
    documentSnapshot: FirebaseFirestore.DocumentSnapshot,
  ): Ticket {
    const data = (documentSnapshot.data() as FirestoreTicket) || {};
    return {
      id: documentSnapshot.id,
      code: data.code || '',
      title: data.title || '',
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
      used_spare_parts: data.used_spare_parts || [],
      created_at: data.created_at || '',
      updated_at: data.updated_at || '',
    };
  }

  async create(
    reporterId: string,
    dto: CreateTicketDto,
    userRole?: string,
  ): Promise<Ticket> {
    if (!reporterId) {
      throw new BadRequestException('Không tìm thấy thông tin người báo cáo');
    }

    const machineId = dto.machine_id?.trim();
    if (!machineId) {
      throw new BadRequestException(
        'Vui lòng cung cấp mã thiết bị (machine_id)',
      );
    }

    const firestore = this.firebaseService.firestore;
    const machinesCollection = firestore.collection(
      FirestoreCollection.MACHINES,
    );
    let machineDoc = await machinesCollection.doc(machineId).get();

    if (!machineDoc.exists) {
      const machineQuery = await machinesCollection
        .where('code', '==', machineId)
        .limit(1)
        .get();
      if (machineQuery.empty) {
        throw new NotFoundException(
          `Không tìm thấy thiết bị với ID hoặc mã '${machineId}'`,
        );
      }
      machineDoc = machineQuery.docs[0];
    }

    const machineData = (machineDoc.data() as FirestoreMachine) || {};

    const reporterDoc = await firestore
      .collection('users')
      .doc(reporterId)
      .get();
    const reporterData = (reporterDoc.data() as FirestoreUser) || {};

    const currentTime = new Date().toISOString();
    const severity = dto.severity || TicketSeverity.MEDIUM;

    const ticketData: FirestoreTicket = {
      machine_id: machineDoc.id,
      reporter_id: reporterId,
      engineer_id: null,
      severity,
      status: TicketStatus.OPEN,
      description: dto.description || '',
      images_urls: dto.images_urls || [],
      downtime_start: dto.downtime_start || currentTime,
      downtime_end: null,
      claimed_at: null,
      rejection_reason: null,
      cancelled_at: null,
      cancelled_reason: null,
      machine_name: machineData.name || '',
      machine_code: machineData.code || '',
      reporter_name: reporterData.fullName || reporterData.full_name || '',
      reporter_email: reporterData.email || '',
      engineer_name: '',
      created_at: currentTime,
      updated_at: currentTime,
    };

    const documentReference = await this.collection.add(ticketData);
    this.logger.log(
      `Đã tạo Ticket ${documentReference.id} cho máy ${machineDoc.id} bởi user ${reporterId} (${userRole || 'N/A'})`,
    );

    try {
      await machineDoc.ref.update({
        status: 'PENDING',
        updatedAt: currentTime,
      });
    } catch (e) {
      this.logger.warn(
        `Không thể cập nhật trạng thái máy ${machineDoc.id}: ${e}`,
      );
    }

    const isCritical =
      severity === TicketSeverity.CRITICAL || severity === TicketSeverity.HIGH;
    await this.notificationsService.createNotification({
      title: isCritical ? 'SỰ CỐ KHẨN CẤP (SOS)' : 'BÁO SỰ CỐ MỚI',
      message: `Máy ${machineData.code || machineDoc.id} (${machineData.name || 'Thiết bị'}) vừa báo sự cố [${severity}]: ${dto.description || 'Cần xử lý'}`,
      type: isCritical ? NotificationTypeEnum.SOS : NotificationTypeEnum.SYSTEM,
      target_role: UserRole.ENGINEER,
      target_id: documentReference.id,
    });

    return { id: documentReference.id, ...ticketData };
  }

  async getAllTickets(filters?: {
    status?: TicketStatus;
    machine_id?: string;
    reporter_id?: string;
  }): Promise<Ticket[]> {
    let query: FirebaseFirestore.Query = this.collection;

    if (filters?.status) query = query.where('status', '==', filters.status);
    if (filters?.machine_id)
      query = query.where('machine_id', '==', filters.machine_id);
    if (filters?.reporter_id)
      query = query.where('reporter_id', '==', filters.reporter_id);

    const snapshot = await query.get();
    return snapshot.docs
      .map((documentSnapshot) => this.mapTicket(documentSnapshot))
      .sort(
        (firstTicket, secondTicket) =>
          new Date(secondTicket.created_at).getTime() -
          new Date(firstTicket.created_at).getTime(),
      );
  }

  async getTicketById(id: string): Promise<Ticket> {
    const documentSnapshot = await this.collection.doc(id).get();
    if (!documentSnapshot.exists) {
      throw new NotFoundException(`Ticket with ID '${id}' not found`);
    }
    return this.mapTicket(documentSnapshot);
  }

  async getMyTickets(reporterId: string): Promise<Ticket[]> {
    return this.getAllTickets({ reporter_id: reporterId });
  }

  async getTicketsForEngineer(engineerId: string): Promise<Ticket[]> {
    const snapshot = await this.collection
      .where('engineer_id', '==', engineerId)
      .get();
    return snapshot.docs
      .map((documentSnapshot) => this.mapTicket(documentSnapshot))
      .sort(
        (firstTicket, secondTicket) =>
          new Date(secondTicket.created_at).getTime() -
          new Date(firstTicket.created_at).getTime(),
      );
  }

  async cancelTicket(
    id: string,
    reporterId: string,
    reason?: string,
  ): Promise<Ticket> {
    const documentReference = this.collection.doc(id);
    const documentSnapshot = await documentReference.get();
    if (!documentSnapshot.exists) {
      throw new NotFoundException(`Ticket with ID '${id}' not found`);
    }

    const ticketData = documentSnapshot.data() as FirestoreTicket;
    if (ticketData.reporter_id !== reporterId) {
      throw new ForbiddenException(
        'Bạn chỉ có thể hủy phiếu sự cố do chính mình tạo ra',
      );
    }
    if (ticketData.status !== TicketStatus.OPEN) {
      throw new BadRequestException(
        'Chỉ có thể hủy phiếu sự cố khi đang ở trạng thái OPEN',
      );
    }

    const currentTime = new Date().toISOString();
    await documentReference.update({
      status: TicketStatus.CANCELLED,
      cancelled_at: currentTime,
      cancelled_reason: reason || 'Người vận hành hủy báo nhầm',
      updated_at: currentTime,
    });

    return this.getTicketById(id);
  }

  async deleteTicket(
    id: string,
    reporterId: string,
  ): Promise<{ success: boolean; message: string; id: string }> {
    const documentReference = this.collection.doc(id);
    const documentSnapshot = await documentReference.get();
    if (!documentSnapshot.exists) {
      throw new NotFoundException(`Phiếu sự cố với ID '${id}' không tồn tại`);
    }

    const ticketData = documentSnapshot.data() as FirestoreTicket;
    if (ticketData.reporter_id !== reporterId) {
      throw new ForbiddenException(
        'Bạn chỉ có quyền xóa phiếu sự cố do chính mình tạo ra',
      );
    }

    if (
      ticketData.status !== TicketStatus.OPEN &&
      ticketData.status !== TicketStatus.CANCELLED &&
      ticketData.status !== TicketStatus.REJECTED
    ) {
      throw new BadRequestException(
        'Không thể xóa phiếu sự cố đang được xử lý hoặc đã hoàn thành',
      );
    }

    await documentReference.delete();
    this.logger.log(`Đã xóa Ticket '${id}' bởi user ${reporterId}`);

    if (ticketData.machine_id) {
      try {
        const otherTicketsQuery = await this.collection
          .where('machine_id', '==', ticketData.machine_id)
          .where('status', 'in', [TicketStatus.OPEN, TicketStatus.IN_PROGRESS])
          .limit(1)
          .get();

        if (otherTicketsQuery.empty) {
          const machineRef = this.firebaseService.firestore
            .collection(FirestoreCollection.MACHINES)
            .doc(ticketData.machine_id);
          const machineSnap = await machineRef.get();
          if (machineSnap.exists) {
            const currentStatus = (machineSnap.data() as FirestoreMachine)
              ?.status;
            if (currentStatus === 'PENDING') {
              await machineRef.update({
                status: 'ACTIVE',
                updatedAt: new Date().toISOString(),
              });
            }
          }
        }
      } catch (e) {
        this.logger.warn(
          `Không thể cập nhật trạng thái máy khi xóa ticket: ${e}`,
        );
      }
    }

    return {
      success: true,
      message: 'Đã xóa phiếu sự cố thành công',
      id,
    };
  }

  async claimTicket(id: string, engineerId: string): Promise<Ticket> {
    const documentReference = this.collection.doc(id);
    const documentSnapshot = await documentReference.get();
    if (!documentSnapshot.exists) {
      throw new NotFoundException(`Ticket with ID '${id}' not found`);
    }

    const engineerDoc = await this.firebaseService.firestore
      .collection('users')
      .doc(engineerId)
      .get();
    const engineerData = (engineerDoc.data() as FirestoreUser) || {};
    const engineerName =
      engineerData.fullName ||
      engineerData.full_name ||
      engineerData.email ||
      '';

    const currentTime = new Date().toISOString();
    await documentReference.update({
      status: TicketStatus.IN_PROGRESS,
      engineer_id: engineerId,
      engineer_name: engineerName,
      claimed_at: currentTime,
      updated_at: currentTime,
    });

    const ticketData = documentSnapshot.data() as FirestoreTicket;
    if (ticketData.machine_id) {
      try {
        const machinesCollection = this.firebaseService.firestore.collection(
          FirestoreCollection.MACHINES,
        );
        const mRef = machinesCollection.doc(ticketData.machine_id);
        const mSnap = await mRef.get();
        if (mSnap.exists) {
          await mRef.update({
            status: 'IN_PROGRESS',
            updatedAt: currentTime,
          });
        } else {
          const query = await machinesCollection
            .where('code', '==', ticketData.machine_id)
            .limit(1)
            .get();
          if (!query.empty) {
            await query.docs[0].ref.update({
              status: 'IN_PROGRESS',
              updatedAt: currentTime,
            });
          }
        }
      } catch (e) {
        this.logger.warn(
          `Không thể cập nhật trạng thái máy ${ticketData.machine_id}: ${e}`,
        );
      }
    }

    await this.notificationsService.createNotification({
      title: 'KỸ SƯ ĐÃ TIẾP NHẬN SỰ CỐ',
      message: `Kỹ sư ${engineerName || 'Kỹ thuật'} đã tiếp nhận xử lý sự cố máy ${ticketData.machine_code || ''} (${ticketData.machine_name || 'Thiết bị'}). Trạng thái: ĐANG XỬ LÝ.`,
      type: NotificationTypeEnum.SYSTEM,
      target_role: UserRole.OPERATOR,
      ...(ticketData.reporter_id && { user_id: ticketData.reporter_id }),
      target_id: id,
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
    const documentReference = this.collection.doc(id);
    const documentSnapshot = await documentReference.get();
    if (!documentSnapshot.exists) {
      throw new NotFoundException(`Ticket with ID '${id}' not found`);
    }

    const ticketData = documentSnapshot.data() as FirestoreTicket;
    const engineerDoc = await this.firebaseService.firestore
      .collection('users')
      .doc(engineerId)
      .get();
    const engineerData = (engineerDoc.data() as FirestoreUser) || {};
    const engineerName =
      engineerData.fullName ||
      engineerData.full_name ||
      engineerData.email ||
      '';

    const currentTime = new Date().toISOString();
    await documentReference.update({
      status: TicketStatus.PENDING_APPROVAL,
      downtime_end: currentTime,
      used_spare_parts: usedSpareParts || [],
      updated_at: currentTime,
    });

    await this.notificationsService.createNotification({
      title: 'SỰ CỐ ĐÃ ĐƯỢC XỬ LÝ XONG',
      message: `Kỹ sư ${engineerName || 'Kỹ thuật'} đã sửa chữa xong máy ${ticketData.machine_code || ''} (${ticketData.machine_name || 'Thiết bị'}) và gửi nghiệm thu.`,
      type: NotificationTypeEnum.SYSTEM,
      target_role: UserRole.OPERATOR,
      ...(ticketData.reporter_id && { user_id: ticketData.reporter_id }),
      target_id: id,
    });

    this.logger.log(
      `Ticket '${id}' đã được Kỹ sư '${engineerId}' hoàn thành và gửi nghiệm thu.`,
    );

    return this.getTicketById(id);
  }

  async rejectTicket(id: string, rejectionReason?: string): Promise<Ticket> {
    const documentReference = this.collection.doc(id);
    const documentSnapshot = await documentReference.get();
    if (!documentSnapshot.exists) {
      throw new NotFoundException(`Ticket with ID '${id}' not found`);
    }

    const currentTime = new Date().toISOString();
    await documentReference.update({
      status: TicketStatus.REJECTED,
      rejection_reason: rejectionReason || 'Chưa đạt yêu cầu nghiệm thu',
      updated_at: currentTime,
    });

    this.logger.log(`Ticket '${id}' đã bị Quản đốc từ chối nghiệm thu.`);

    return this.getTicketById(id);
  }

  async approveTicket(id: string): Promise<Ticket> {
    const documentReference = this.collection.doc(id);
    const documentSnapshot = await documentReference.get();
    if (!documentSnapshot.exists) {
      throw new NotFoundException(`Ticket with ID '${id}' not found`);
    }

    const ticketData = documentSnapshot.data() as FirestoreTicket;
    const currentTime = new Date().toISOString();
    await documentReference.update({
      status: TicketStatus.CLOSED,
      closed_at: currentTime,
      updated_at: currentTime,
    });

    if (ticketData.machine_id) {
      try {
        const machinesCollection = this.firebaseService.firestore.collection(
          FirestoreCollection.MACHINES,
        );
        const mRef = machinesCollection.doc(ticketData.machine_id);
        const mSnap = await mRef.get();
        if (mSnap.exists) {
          await mRef.update({
            status: 'ACTIVE',
            updatedAt: currentTime,
          });
        }
      } catch (e) {
        this.logger.warn(`Không thể cập nhật trạng thái máy: ${e}`);
      }
    }

    await this.notificationsService.createNotification({
      title: 'PHIẾU SỰ CỐ ĐÃ NGHIỆM THU',
      message: `Máy ${ticketData.machine_code || ''} (${ticketData.machine_name || 'Thiết bị'}) đã được Quản đốc nghiệm thu và đóng phiếu thành công.`,
      type: NotificationTypeEnum.SYSTEM,
      target_role: UserRole.OPERATOR,
      ...(ticketData.reporter_id && { user_id: ticketData.reporter_id }),
      target_id: id,
    });

    this.logger.log(`Ticket '${id}' đã được Quản đốc nghiệm thu & đóng phiếu.`);
    return this.getTicketById(id);
  }
}
