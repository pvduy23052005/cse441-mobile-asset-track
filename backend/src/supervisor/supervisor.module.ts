import { Module } from '@nestjs/common';
import { AuthModule } from '../modules/auth/auth.module';
import { MachineModule } from '../modules/machine/machine.module';
import { SupervisorController } from './supervisor.controller';

@Module({
  imports: [AuthModule, MachineModule],
  controllers: [SupervisorController],
})
export class SupervisorModule {}
