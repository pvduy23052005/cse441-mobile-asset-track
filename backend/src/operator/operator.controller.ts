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
import type { JwtAuthenticatedRequest } from '../modules/auth/jwt-auth.guard';
import { JwtAuthGuard } from '../modules/auth/jwt-auth.guard';
import { CreateTicketDto } from '../modules/tickets/dto/create-ticket.dto';
import { Ticket } from '../modules/tickets/interfaces/ticket.interface';
import { TicketsService } from '../modules/tickets/tickets.service';

@UseGuards(JwtAuthGuard)
@Controller('operator/tickets')
export class OperatorTicketController {
  constructor(private readonly ticketsService: TicketsService) {}

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

    return this.ticketsService.create(reporterId, dto, req.user?.role);
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

    return this.ticketsService.cancelTicket(id, reporterId, reason);
  }
}
