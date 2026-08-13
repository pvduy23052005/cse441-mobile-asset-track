import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Machine, MachineService } from './machine.service';

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
}
