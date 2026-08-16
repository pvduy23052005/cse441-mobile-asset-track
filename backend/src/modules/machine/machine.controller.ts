import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { JwtAuthenticatedRequest } from '../auth/jwt-auth.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import {
  FirestoreMachine,
  Machine,
  MachineService,
  PMChecklist,
} from './machine.service';

@UseGuards(JwtAuthGuard)
@Controller('machines')
export class MachineController {
  constructor(private readonly machineService: MachineService) {}

  @Get()
  async getAllMachines(
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<Machine[]> {
    const userRole = req.user?.role?.toLowerCase();
    const userId = req.user?.uid || req.user?.id;

    return this.machineService.getMachinesForUser(userRole, userId);
  }

  @Get('pm-checklists')
  async getPMChecklists(): Promise<PMChecklist[]> {
    return this.machineService.getPMChecklists();
  }

  @Get(':id')
  async getMachineById(@Param('id') id: string): Promise<Machine> {
    return this.machineService.getMachineById(id);
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

  @Post()
  async createMachine(
    @Body() data: Partial<FirestoreMachine>,
  ): Promise<Machine> {
    return this.machineService.createMachine(data);
  }

  @Post(':id/running-hours')
  async logRunningHours(
    @Param('id') id: string,
    @Body() body: { running_hours: number; shift?: string },
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<Machine> {
    const userProfile = req.user;
    const loggedByName =
      userProfile?.fullName ||
      userProfile?.full_name ||
      userProfile?.email ||
      'Operator';
    return this.machineService.logRunningHours(
      id,
      Number(body.running_hours),
      loggedByName,
      body.shift,
    );
  }
}
