import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { FirestoreCollection } from '../../common/constants/firestore-collections.enum';
import { FirestoreUser } from '../auth/auth.service';
import { FirebaseService } from '../firebase/firebase.service';
import { FirestoreMachine } from '../machine/machine.service';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { TicketSeverity } from './enums/ticket-severity.enum';
import { TicketStatus } from './enums/ticket-status.enum';
import { FirestoreTicket, Ticket } from './interfaces/ticket.interface';

@Injectable()
export class TicketsService {
  private readonly logger = new Logger(TicketsService.name);
  private readonly collectionName = FirestoreCollection.TICKETS;

  constructor(private readonly firebaseService: FirebaseService) {}

  /**
   * Operator tạo phiếu sự cố cho thiết bị
   */
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
      throw new BadRequestException('Vui lòng cung cấp mã thiết bị (machine_id)');
    }

    // 1. Kiểm tra thiết bị có tồn tại trong Firestore hay không
    let machineDoc = await firestore
      .collection(FirestoreCollection.MACHINES)
      .doc(machineId)
      .get();

    // Nếu không tìm thấy theo Document ID, thử tìm theo trường "code"
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

    // 2. Lấy thông tin người báo cáo (Reporter) từ Firestore
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

    // 3. Chuẩn bị dữ liệu ticket theo đúng Schema
    const now = new Date().toISOString();
    const ticketData: FirestoreTicket = {
      machine_id: actualMachineId,
      reporter_id: reporterId,
      engineer_id: null,
      severity: dto.severity || TicketSeverity.MEDIUM,
      status: TicketStatus.OPEN,
      description: dto.description.trim(),
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
      let query: FirebaseFirestore.Query = this.firebaseService.firestore.collection(
        this.collectionName,
      );

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

      // Sắp xếp giảm dần theo thời gian tạo
      return tickets.sort(
        (a, b) =>
          new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
      );
    } catch (error) {
      this.logger.error(`Error fetching tickets: ${error}`);
      return [];
    }
  }

  /**
   * Lấy chi tiết một Ticket theo ID
   */
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

  /**
   * Lấy danh sách ticket do chính người dùng hiện tại báo cáo
   */
  async getMyTickets(reporterId: string): Promise<Ticket[]> {
    return this.getAllTickets({ reporter_id: reporterId });
  }
}
