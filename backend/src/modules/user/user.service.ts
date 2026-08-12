import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
} from '@nestjs/common';
import { DecodedIdToken } from 'firebase-admin/auth';
import { FirebaseService } from '../firebase/firebase.service';
import { CreateUserDto } from './dto/create-user.dto';
import { FirestoreUser } from '../auth/auth.service';

@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  constructor(private readonly firebaseService: FirebaseService) {}

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

  async getAllUsers() {
    try {
      const snapshot = await this.firebaseService.firestore
        .collection('users')
        .get();

      return snapshot.docs.map((doc) => {
        const data = doc.data() as FirestoreUser;
        return {
          id: doc.id,
          uid: doc.id,
          email: data.email || '',
          fullName: data.full_name || data.fullName || '',
          role: data.role || 'operator',
          createdAt: data.createdAt || new Date().toISOString(),
        };
      });
    } catch (err) {
      this.logger.error(`Error fetching all users: ${err}`);
      return [];
    }
  }

  async createUser(dto: CreateUserDto) {
    const cleanEmail = dto.email?.toLowerCase().trim();
    const cleanPassword = dto.password?.trim() || '123456';
    const cleanFullName = dto.fullName?.trim();
    const cleanRole = dto.role?.toLowerCase().trim();

    if (!cleanEmail || !cleanFullName || !cleanRole) {
      throw new BadRequestException(
        'Vui lòng nhập đầy đủ Email, Họ tên và Vai trò',
      );
    }

    const firestore = this.firebaseService.firestore;

    // Check if user already exists
    const existingSnap = await firestore
      .collection('users')
      .where('email', '==', cleanEmail)
      .limit(1)
      .get();

    if (!existingSnap.empty) {
      throw new ConflictException(
        'Email này đã được sử dụng cho một tài khoản khác',
      );
    }

    const userData = {
      email: cleanEmail,
      password: cleanPassword,
      full_name: cleanFullName,
      fullName: cleanFullName,
      role: cleanRole,
      createdAt: new Date().toISOString(),
    };

    const docRef = await firestore.collection('users').add(userData);

    return {
      statusCode: 201,
      message: 'Tạo tài khoản người dùng thành công',
      user: {
        id: docRef.id,
        uid: docRef.id,
        ...userData,
      },
    };
  }

  async deleteUser(id: string) {
    try {
      await this.firebaseService.firestore.collection('users').doc(id).delete();
      return {
        statusCode: 200,
        message: 'Đã xóa tài khoản người dùng thành công',
      };
    } catch (err) {
      throw new BadRequestException(`Không thể xóa tài khoản: ${err}`);
    }
  }
}
