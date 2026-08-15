import {
  Body,
  Controller,
  ForbiddenException,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '../common/constants/user-role.enum';
import type { JwtAuthenticatedRequest } from '../modules/auth/jwt-auth.guard';
import { JwtAuthGuard } from '../modules/auth/jwt-auth.guard';
import { TicketWsEvent } from '../modules/notifications/notification.event';
import { NotificationsGateway } from '../modules/notifications/notifications.gateway';
import { CreateTicketDto } from '../modules/tickets/dto/create-ticket.dto';
import { Ticket } from '../modules/tickets/interfaces/ticket.interface';
import { TicketsService } from '../modules/tickets/tickets.service';

@UseGuards(JwtAuthGuard)
@Controller('operator/tickets')
export class OperatorTicketController {
  constructor(
    private readonly ticketsService: TicketsService,
    private readonly notificationsGateway: NotificationsGateway,
  ) {}

  @Post()
  async createTicket(
    @Req() req: JwtAuthenticatedRequest,
    @Body() dto: CreateTicketDto,
  ): Promise<Ticket> {
    const userRole = req.user?.role?.toLowerCase();
    if (
      userRole &&
      userRole !== 'operator' &&
      userRole !== 'admin' &&
      userRole !== 'supervisor'
    ) {
      throw new ForbiddenException(
        'Chỉ người vận hành (Operator) mới có quyền tạo phiếu báo cáo sự cố tại đây',
      );
    }

    const reporterId = req.user?.uid || req.user?.id;
    if (!reporterId) {
      throw new UnauthorizedException(
        'Không tìm thấy ID người dùng từ thông tin xác thực JWT',
      );
    }

    const ticket = await this.ticketsService.create(reporterId, dto, req.user?.role);

    this.notificationsGateway.emitTicketEvent(
      TicketWsEvent.CREATED,
      {
        id: ticket.id,
        reporter_id: ticket.reporter_id,
        reporter_name: ticket.reporter_name || req.user?.fullName || '',
        severity: ticket.severity,
        created_at: ticket.created_at,
      },
      UserRole.ENGINEER,
    );

    return ticket;
  }

  @Get()
  async getMyTickets(@Req() req: JwtAuthenticatedRequest): Promise<Ticket[]> {
    const reporterId = req.user?.uid || req.user?.id;
    if (!reporterId) {
      throw new UnauthorizedException(
        'Không tìm thấy ID người dùng từ thông tin xác thực JWT',
      );
    }

    return this.ticketsService.getMyTickets(reporterId);
  }

  @Get(':id')
  async getTicketById(@Param('id') id: string): Promise<Ticket> {
    return this.ticketsService.getTicketById(id);
  }

  @Patch(':id/cancel')
  async cancelTicket(
    @Param('id') id: string,
    @Req() req: JwtAuthenticatedRequest,
    @Body('reason') reason?: string,
  ): Promise<Ticket> {
    const reporterId = req.user?.uid || req.user?.id;
    if (!reporterId) {
      throw new UnauthorizedException(
        'Không tìm thấy ID người dùng từ thông tin xác thực JWT',
      );
    }

    const ticket = await this.ticketsService.cancelTicket(id, reporterId, reason);
    this.notificationsGateway.emitTicketEvent(TicketWsEvent.CANCELLED, ticket);
    return ticket;
  }
}
