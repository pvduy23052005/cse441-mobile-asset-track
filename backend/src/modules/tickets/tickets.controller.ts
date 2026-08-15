import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import type { JwtAuthenticatedRequest } from '../auth/jwt-auth.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import {
  NotificationsGateway,
  TicketWsEvent,
} from '../notifications/notifications.gateway';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { TicketStatus } from './enums/ticket-status.enum';
import { Ticket } from './interfaces/ticket.interface';
import { TicketsService } from './tickets.service';

@UseGuards(JwtAuthGuard)
@Controller('tickets')
export class TicketsController {
  constructor(
    private readonly ticketsService: TicketsService,
    private readonly notificationsGateway: NotificationsGateway,
  ) {}

  @Post()
  async createTicket(
    @Req() req: JwtAuthenticatedRequest,
    @Body() dto: CreateTicketDto,
  ): Promise<Ticket> {
    const reporterId = req.user?.uid || req.user?.id;

    if (!reporterId) {
      throw new UnauthorizedException(
        'Không tìm thấy ID người dùng từ thông tin xác thực JWT',
      );
    }

    

    const ticket = await this.ticketsService.create(reporterId, dto, req.user?.role);

    this.notificationsGateway.emitTicketEvent(TicketWsEvent.CREATED, {
      id: ticket.id,
      reporter_id: ticket.reporter_id,
      reporter_name: ticket.reporter_name || req.user?.fullName || '',
      severity: ticket.severity,
      created_at: ticket.created_at,
    });

    return ticket;
  }

  @Get('my')
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

  @Get()
  async getAllTickets(
    @Query('status') status?: TicketStatus,
    @Query('machine_id') machineId?: string,
    @Query('reporter_id') reporterId?: string,
  ): Promise<Ticket[]> {
    return this.ticketsService.getAllTickets({
      status,
      machine_id: machineId,
      reporter_id: reporterId,
    });
  }

  @Patch(':id/claim')
  async claimTicket(
    @Param('id') id: string,
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<Ticket> {
    const engineerId = req.user?.uid || req.user?.id;

    if (!engineerId) {
      throw new UnauthorizedException(
        'Không tìm thấy ID Kỹ sư từ thông tin xác thực JWT',
      );
    }

    const ticket = await this.ticketsService.claimTicket(id, engineerId);
    this.notificationsGateway.emitTicketEvent(TicketWsEvent.UPDATED, ticket);
    return ticket;
  }

  @Patch(':id/complete')
  async completeTicket(
    @Param('id') id: string,
    @Req() req: JwtAuthenticatedRequest,
    @Body() body: { used_spare_parts?: any[] },
  ): Promise<Ticket> {
    const engineerId = req.user?.uid || req.user?.id;

    if (!engineerId) {
      throw new UnauthorizedException(
        'Không tìm thấy ID Kỹ sư từ thông tin xác thực JWT',
      );
    }

    const ticket = await this.ticketsService.completeTicket(
      id,
      engineerId,
      body?.used_spare_parts,
    );
    this.notificationsGateway.emitTicketEvent(TicketWsEvent.UPDATED, ticket);
    return ticket;
  }

  @Patch(':id/reject')
  async rejectTicket(
    @Param('id') id: string,
    @Body() body: { rejection_reason?: string },
  ): Promise<Ticket> {
    const ticket = await this.ticketsService.rejectTicket(id, body?.rejection_reason);
    this.notificationsGateway.emitTicketEvent(TicketWsEvent.UPDATED, ticket);
    return ticket;
  }
}
