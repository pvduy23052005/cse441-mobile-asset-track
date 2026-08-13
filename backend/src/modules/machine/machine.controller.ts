import {
  Body,
  Controller,
  ForbiddenException,
  Get,
  Param,
  Patch,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { JwtAuthenticatedRequest } from '../auth/jwt-auth.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import {
  FirestoreMachine,
  Machine,
  MachineQrCodeResponse,
  MachineService,
} from './machine.service';

@UseGuards(JwtAuthGuard)
@Controller('machines')
export class MachineController {
  constructor(private readonly machineService: MachineService) {}

  @Get()
  async getAllMachines(): Promise<Machine[]> {
    return this.machineService.getAllMachines();
  }

  @Get(':id')
  async getMachineById(@Param('id') id: string): Promise<Machine> {
    return this.machineService.getMachineById(id);
  }

  @Get(':id/qrcode')
  async getMachineQrCode(
    @Param('id') id: string,
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<MachineQrCodeResponse> {
    const userRole = req.user?.role?.toLowerCase();
    if (userRole !== 'supervisor' && userRole !== 'admin') {
      throw new ForbiddenException(
        'Chỉ Quản đốc (Supervisor) mới có quyền tạo và xem mã QR của thiết bị',
      );
    }
    return this.machineService.generateMachineQrCode(id);
  }

  @Patch(':id/status')
  async updateMachineStatus(
    @Param('id') id: string,
    @Body('status') status: string,
  ): Promise<Machine> {
    return this.machineService.updateMachineStatus(id, status);
  }

  @Put(':id')
  async updateMachine(
    @Param('id') id: string,
    @Body() data: Partial<FirestoreMachine>,
  ): Promise<Machine> {
    return this.machineService.updateMachine(id, data);
  }
}
