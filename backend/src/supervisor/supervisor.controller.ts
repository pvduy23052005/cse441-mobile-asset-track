import {
  Controller,
  ForbiddenException,
  Get,
  Param,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { JwtAuthenticatedRequest } from '../modules/auth/jwt-auth.guard';
import { JwtAuthGuard } from '../modules/auth/jwt-auth.guard';
import {
  MachineQrCodeResponse,
  MachineService,
} from '../modules/machine/machine.service';

@UseGuards(JwtAuthGuard)
@Controller('supervisor')
export class SupervisorController {
  constructor(private readonly machineService: MachineService) {}

  @Get('machines/:id/qrcode')
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
}
