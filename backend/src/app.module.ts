import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppService } from './app.service';
import { AuthModule } from './modules/auth/auth.module';
import { FirebaseModule } from './modules/firebase/firebase.module';
import { MachineModule } from './modules/machine/machine.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { TicketsModule } from './modules/tickets/tickets.module';
import { OperatorModule } from './operator/operator.module';
import { SupervisorModule } from './supervisor/supervisor.module';
import { UserModule } from './modules/user/user.module';
import { UploadModule } from './modules/upload/upload.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    FirebaseModule,
    AuthModule,
    UserModule,
    MachineModule,
    TicketsModule,
    OperatorModule,
    SupervisorModule,
    NotificationsModule,
    UploadModule,
  ],
  providers: [AppService],
})
export class AppModule {}
