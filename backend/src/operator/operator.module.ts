import { Module } from '@nestjs/common';
import { AuthModule } from '../modules/auth/auth.module';
import { NotificationsModule } from '../modules/notifications/notifications.module';
import { TicketsModule } from '../modules/tickets/tickets.module';
import { OperatorTicketController } from './operator.controller';

@Module({
  imports: [AuthModule, TicketsModule, NotificationsModule],
  controllers: [OperatorTicketController],
})
export class OperatorModule {}
