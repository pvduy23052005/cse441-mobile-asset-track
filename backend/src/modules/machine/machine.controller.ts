import { Body, Controller, Get, Param, Patch, Put, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { FirestoreMachine, Machine, MachineService } from './machine.service';

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
