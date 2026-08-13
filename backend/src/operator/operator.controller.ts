import {
  Body,
  Controller,
  Get,
  Param,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import type { JwtAuthenticatedRequest } from '../modules/auth/jwt-auth.guard';
import { JwtAuthGuard } from '../modules/auth/jwt-auth.guard';
import { Ticket } from '../modules/tickets/interfaces/ticket.interface';
import { TicketsService } from '../modules/tickets/tickets.service';

@UseGuards(JwtAuthGuard)
@Controller('operator/tickets')
export class OperatorTicketController {
  constructor(private readonly ticketsService: TicketsService) { }

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
}
