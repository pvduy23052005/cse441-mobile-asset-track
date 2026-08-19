import {
  Body,
  Controller,
  Delete,
  ForbiddenException,
  Get,
  Param,
  Post,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import type { JwtAuthenticatedRequest } from '../modules/auth/jwt-auth.guard';
import { JwtAuthGuard } from '../modules/auth/jwt-auth.guard';
import {
  Machine,
  MachineService,
} from '../modules/machine/machine.service';
import { CreateTicketDto } from '../modules/tickets/dto/create-ticket.dto';
import { Ticket } from '../modules/tickets/interfaces/ticket.interface';
import { TicketsService } from '../modules/tickets/tickets.service';

@UseGuards(JwtAuthGuard)
@Controller('operator')
export class OperatorController {
  constructor(
    private readonly machineService: MachineService,
    private readonly ticketsService: TicketsService,
  ) {}

  @Get('machines')
  async getMyMachines(
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<Machine[]> {
    const userRole = req.user?.role?.toLowerCase();
    if (userRole && userRole !== 'operator' && userRole !== 'supervisor') {
      throw new ForbiddenException(
        'Chỉ người vận hành (Operator) mới có quyền truy cập danh sách máy phụ trách',
      );
    }

    const operatorId = req.user?.uid || req.user?.id;
    if (!operatorId) {
      throw new UnauthorizedException(
        'Không tìm thấy ID người dùng từ thông tin xác thực JWT',
      );
    }

    return this.machineService.getMachinesForUser('operator', operatorId);
  }

  @Post('tickets')
  async createTicket(
    @Req() req: JwtAuthenticatedRequest,
    @Body() dto: CreateTicketDto,
  ): Promise<Ticket> {
    const userRole = req.user?.role?.toLowerCase();
    if (
      userRole &&
      userRole !== 'operator' &&
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

  @Get('tickets')
  async getMyTickets(@Req() req: JwtAuthenticatedRequest): Promise<Ticket[]> {
    const reporterId = req.user?.uid || req.user?.id;
    if (!reporterId) {
      throw new UnauthorizedException(
        'Không tìm thấy ID người dùng từ thông tin xác thực JWT',
      );
    }

    return this.ticketsService.getMyTickets(reporterId);
  }

  @Get('tickets/:id')
  async getTicketById(@Param('id') id: string): Promise<Ticket> {
    return this.ticketsService.getTicketById(id);
  }

  @Delete('tickets/:id')
  async deleteTicket(
    @Param('id') id: string,
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<{ success: boolean; message: string; id: string }> {
    const reporterId = req.user?.uid || req.user?.id;
    if (!reporterId) {
      throw new UnauthorizedException(
        'Không tìm thấy ID người dùng từ thông tin xác thực JWT',
      );
    }

    return this.ticketsService.deleteTicket(id, reporterId);
  }
}
