import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { FirebaseModule } from '../firebase/firebase.module';
import { MachineController } from './machine.controller';
import { MachineService } from './machine.service';

@Module({
  imports: [FirebaseModule, AuthModule],
  controllers: [MachineController],
  providers: [MachineService],
  exports: [MachineService],
})
export class MachineModule {}
