import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';
import { JwtService } from '@nestjs/jwt';
import { LoginDto } from './dto/login.dto';

export interface UserRoleData {
  uid: string;
  email: string;
  role: string;
  fullName?: string;
  password?: string;
}

export interface FirestoreUser {
  email?: string;
  role?: string;
  full_name?: string;
  fullName?: string;
  password?: string;
  createdAt?: string;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly jwtService: JwtService,
  ) {}

  async findUserInUsersCollection(email: string): Promise<UserRoleData | null> {
    const firestore = this.firebaseService.firestore;
    const cleanEmail = email.toLowerCase().trim();

    try {
      const querySnap = await firestore
        .collection('users')
        .where('email', '==', cleanEmail)
        .limit(1)
        .get();

      if (!querySnap.empty) {
        const doc = querySnap.docs[0];
        const data = doc.data() as FirestoreUser;

        return {
          uid: doc.id,
          email: data.email || cleanEmail,
          role: data.role || '',
          fullName: data.full_name || '',
          password: data.password,
        };
      }
    } catch (err) {
      this.logger.warn(
        `Error querying 'users' collection by email (${cleanEmail}): ${err}`,
      );
    }

    return null;
  }

  async login(loginDto: LoginDto) {
    const email = loginDto.email?.trim();
    const password = loginDto.password?.trim();

    if (!email || !password) {
      throw new UnauthorizedException('Vui lòng nhập đầy đủ Email và Mật khẩu');
    }

    const userData = await this.findUserInUsersCollection(email);

    if (!userData) {
      throw new UnauthorizedException('Tài khoản không tồn tại trên hệ thống');
    }

    if (userData.password && userData.password !== password) {
      throw new UnauthorizedException('Mật khẩu không chính xác');
    }

    const payload = {
      uid: userData.uid,
      email: userData.email,
      role: userData.role,
      fullName: userData.fullName || '',
    };

    const accessToken = this.jwtService.sign(payload);

    return {
      statusCode: 200,
      message: 'Đăng nhập thành công',
      accessToken,
      user: {
        uid: userData.uid,
        email: userData.email,
        role: userData.role,
        fullName: userData.fullName || '',
      },
    };
  }
}
