import { Module } from '@nestjs/common';
import { AuthModule } from '../modules/auth/auth.module';
import { MachineModule } from '../modules/machine/machine.module';
import { TicketsModule } from '../modules/tickets/tickets.module';
import { EngineerController } from './engineer.controller';

@Module({
  imports: [AuthModule, TicketsModule, MachineModule],
  controllers: [EngineerController],
})
export class EngineerModule {}
