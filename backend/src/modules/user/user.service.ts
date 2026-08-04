import { Injectable } from '@nestjs/common';
import { DecodedIdToken } from 'firebase-admin/auth';

@Injectable()
export class UserService {
  getUserProfile(user?: DecodedIdToken) {
    if (!user) {
      return null;
    }
    return {
      message: 'User profile retrieved successfully via Firebase Auth!',
      uid: user.uid,
      email: user.email,
      emailVerified: user.email_verified,
      authTime: user.auth_time
        ? new Date(user.auth_time * 1000).toISOString()
        : null,
    };
  }
}
