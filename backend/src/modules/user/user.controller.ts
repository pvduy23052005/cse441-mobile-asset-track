import { Controller, Get, Request, UseGuards } from '@nestjs/common';
import type { AuthenticatedRequest } from '../firebase/firebase-auth.guard';
import { FirebaseAuthGuard } from '../firebase/firebase-auth.guard';
import { UserService } from './user.service';

@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get('profile')
  @UseGuards(FirebaseAuthGuard)
  getProfile(@Request() req: AuthenticatedRequest) {
    return this.userService.getUserProfile(req.user);
  }
}
