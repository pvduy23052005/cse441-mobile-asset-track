import { Module } from '@nestjs/common';
import { AuthModule } from '../modules/auth/auth.module';
import { TicketsModule } from '../modules/tickets/tickets.module';
import { OperatorTicketController } from './operator.controller';

@Module({
  imports: [AuthModule, TicketsModule],
  controllers: [OperatorTicketController],
})
export class OperatorModule { }
