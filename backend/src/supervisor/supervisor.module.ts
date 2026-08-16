import { Module } from '@nestjs/common';
import { AuthModule } from '../modules/auth/auth.module';
import { MachineModule } from '../modules/machine/machine.module';
import { UserModule } from '../modules/user/user.module';
import { SupervisorController } from './supervisor.controller';

@Module({
  imports: [AuthModule, MachineModule, UserModule],
  controllers: [SupervisorController],
})
export class SupervisorModule {}
