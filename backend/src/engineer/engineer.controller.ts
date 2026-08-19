import {
  Body,
  Controller,
  ForbiddenException,
  Get,
  Param,
  Patch,
  Query,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import type { JwtAuthenticatedRequest } from '../modules/auth/jwt-auth.guard';
import { JwtAuthGuard } from '../modules/auth/jwt-auth.guard';
import { Machine, MachineService } from '../modules/machine/machine.service';
import { TicketStatus } from '../modules/tickets/enums/ticket-status.enum';
import { Ticket } from '../modules/tickets/interfaces/ticket.interface';
import { TicketsService } from '../modules/tickets/tickets.service';

@UseGuards(JwtAuthGuard)
@Controller('engineer')
export class EngineerController {
  constructor(
    private readonly ticketsService: TicketsService,
    private readonly machineService: MachineService,
  ) {}

  @Get('tickets')
  async getAllEngineerTickets(
    @Req() req: JwtAuthenticatedRequest,
    @Query('status') status?: TicketStatus,
  ): Promise<Ticket[]> {
    const userRole = req.user?.role?.toLowerCase();
    if (userRole && userRole !== 'engineer' && userRole !== 'supervisor') {
      throw new ForbiddenException(
        'Chỉ Kỹ sư (Engineer) hoặc Quản đốc mới có quyền truy cập danh sách công việc kỹ thuật',
      );
    }
    return this.ticketsService.getAllTickets({ status });
  }

  @Get('tickets/my')
  async getMyAssignedTickets(
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<Ticket[]> {
    const engineerId = req.user?.uid || req.user?.id;
    if (!engineerId) {
      throw new UnauthorizedException(
        'Không tìm thấy ID Kỹ sư từ thông tin xác thực JWT',
      );
    }
    return this.ticketsService.getTicketsForEngineer(engineerId);
  }

  @Get('tickets/:id')
  async getTicketById(@Param('id') id: string): Promise<Ticket> {
    return this.ticketsService.getTicketById(id);
  }

  @Patch('tickets/:id/claim')
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
    return this.ticketsService.claimTicket(id, engineerId);
  }

  @Patch('tickets/:id/complete')
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
    return this.ticketsService.completeTicket(
      id,
      engineerId,
      body?.used_spare_parts,
    );
  }

  @Get('machines')
  async getAssignedMachines(
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<Machine[]> {
    const engineerId = req.user?.uid || req.user?.id;
    if (!engineerId) {
      throw new UnauthorizedException(
        'Không tìm thấy ID Kỹ sư từ thông tin xác thực JWT',
      );
    }
    return this.machineService.getMachinesForUser('engineer', engineerId);
  }
}
