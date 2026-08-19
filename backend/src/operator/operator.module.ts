import { Module } from '@nestjs/common';
import { AuthModule } from '../modules/auth/auth.module';
import { MachineModule } from '../modules/machine/machine.module';
import { TicketsModule } from '../modules/tickets/tickets.module';
import { OperatorController } from './operator.controller';

@Module({
  imports: [AuthModule, TicketsModule, MachineModule],
  controllers: [OperatorController],
})
export class OperatorModule {}
