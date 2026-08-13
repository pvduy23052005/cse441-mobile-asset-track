import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import type { JwtAuthenticatedRequest } from '../auth/jwt-auth.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { TicketStatus } from './enums/ticket-status.enum';
import { Ticket } from './interfaces/ticket.interface';
import { TicketsService } from './tickets.service';

@UseGuards(JwtAuthGuard)
@Controller('tickets')
export class TicketsController {
  constructor(private readonly ticketsService: TicketsService) {}

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

    return this.ticketsService.create(reporterId, dto, req.user?.role);
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
}
