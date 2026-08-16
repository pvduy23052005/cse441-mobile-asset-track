import {
  Body,
  Controller,
  ForbiddenException,
  Get,
  Param,
  Patch,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { JwtAuthenticatedRequest } from '../modules/auth/jwt-auth.guard';
import { JwtAuthGuard } from '../modules/auth/jwt-auth.guard';
import {
  Machine,
  MachineQrCodeResponse,
  MachineService,
} from '../modules/machine/machine.service';
import { UserService } from '../modules/user/user.service';

@UseGuards(JwtAuthGuard)
@Controller('supervisor')
export class SupervisorController {
  constructor(
    private readonly machineService: MachineService,
    private readonly userService: UserService,
  ) {}

  @Get('machines')
  async getAllMachines(
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<Machine[]> {
    const userRole = req.user?.role?.toLowerCase();
    if (userRole !== 'supervisor') {
      throw new ForbiddenException(
        'Chỉ Quản đốc (Supervisor) mới có quyền truy cập danh sách toàn bộ máy móc',
      );
    }
    return this.machineService.getAllMachines();
  }

  @Get('operators')
  async getOperators(
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<any[]> {
    const userRole = req.user?.role?.toLowerCase();
    if (userRole !== 'supervisor') {
      throw new ForbiddenException(
        'Chỉ Quản đốc (Supervisor) mới có quyền truy cập danh sách nhân sự',
      );
    }
    const allUsers = await this.userService.getAllUsers();
    return allUsers.filter((u) => u.role?.toLowerCase() === 'operator');
  }

  @Get('machines/:id/qrcode')
  async getMachineQrCode(
    @Param('id') id: string,
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<MachineQrCodeResponse> {
    const userRole = req.user?.role?.toLowerCase();
    if (userRole !== 'supervisor') {
      throw new ForbiddenException(
        'Chỉ Quản đốc (Supervisor) mới có quyền tạo và xem mã QR của thiết bị',
      );
    }
    return this.machineService.generateMachineQrCode(id);
  }

  @Patch('machines/:id/assign-operator')
  async assignOperator(
    @Param('id') id: string,
    @Body('operator_id') operatorId: string,
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<Machine> {
    const userRole = req.user?.role?.toLowerCase();
    if (userRole !== 'supervisor') {
      throw new ForbiddenException(
        'Chỉ Quản đốc (Supervisor) mới có quyền phân công người vận hành',
      );
    }
    return this.machineService.assignOperator(id, operatorId);
  }
}
