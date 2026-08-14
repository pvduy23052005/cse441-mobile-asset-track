import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { FirestoreCollection } from '../../common/constants/firestore-collections.enum';
import { FirebaseService } from '../firebase/firebase.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
import {
  FirestoreNotification,
  NotificationItem,
} from './interfaces/notification.interface';
import { NotificationsGateway } from './notifications.gateway';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private readonly collectionName = FirestoreCollection.NOTIFICATIONS;

  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly notificationsGateway: NotificationsGateway,
  ) {}

  async createNotification(
    dto: CreateNotificationDto,
  ): Promise<NotificationItem> {
    const firestore = this.firebaseService.firestore;
    const createdAt = new Date().toISOString();

    const dataToSave: FirestoreNotification = {
      title: dto.title,
      message: dto.message,
      type: dto.type,
      is_read: false,
      created_at: createdAt,
    };

    if (dto.user_id) dataToSave.user_id = dto.user_id;
    if (dto.target_role) dataToSave.target_role = dto.target_role;
    if (dto.target_id) dataToSave.target_id = dto.target_id;

    const docRef = await firestore
      .collection(this.collectionName)
      .add(dataToSave);

    this.logger.log(`Tạo thông báo ID: ${docRef.id} thành công`);

    const result: NotificationItem = {
      id: docRef.id,
      ...dataToSave,
    };

    try {
      this.notificationsGateway.emitNotification(result);
    } catch (err) {
      this.logger.warn(`Lỗi bắn WebSocket notification: ${err}`);
    }

    return result;
  }

  async getNotificationsForUser(
    userId: string,
    userRole?: string,
  ): Promise<NotificationItem[]> {
    const firestore = this.firebaseService.firestore;
    const notificationsMap = new Map<string, NotificationItem>();

    if (userId) {
      const userSnapshot = await firestore
        .collection(this.collectionName)
        .where('user_id', '==', userId)
        .get();

      userSnapshot.forEach((doc) => {
        const data = doc.data() as FirestoreNotification;
        notificationsMap.set(doc.id, {
          id: doc.id,
          ...data,
        });
      });
    }

    if (userRole) {
      const roleSnapshot = await firestore
        .collection(this.collectionName)
        .where('target_role', '==', userRole)
        .get();

      roleSnapshot.forEach((doc) => {
        const data = doc.data() as FirestoreNotification;
        notificationsMap.set(doc.id, {
          id: doc.id,
          ...data,
        });
      });
    }

    if (notificationsMap.size === 0) {
      const globalSnapshot = await firestore
        .collection(this.collectionName)
        .limit(20)
        .get();

      globalSnapshot.forEach((doc) => {
        const data = doc.data() as FirestoreNotification;
        notificationsMap.set(doc.id, {
          id: doc.id,
          ...data,
        });
      });
    }

    const list = Array.from(notificationsMap.values());
    list.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );

    return list;
  }

  async getUnreadCount(userId: string, userRole?: string): Promise<number> {
    const notifications = await this.getNotificationsForUser(userId, userRole);
    return notifications.filter((item) => !item.is_read).length;
  }

  async markAsRead(notificationId: string): Promise<NotificationItem> {
    const firestore = this.firebaseService.firestore;
    const docRef = firestore
      .collection(this.collectionName)
      .doc(notificationId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new NotFoundException(
        `Không tìm thấy thông báo với ID '${notificationId}'`,
      );
    }

    await docRef.update({ is_read: true });
    const updatedData = (await docRef.get()).data() as FirestoreNotification;

    return {
      id: doc.id,
      ...updatedData,
      is_read: true,
    };
  }

  async markAllAsRead(
    userId: string,
    userRole?: string,
  ): Promise<{ updatedCount: number }> {
    const notifications = await this.getNotificationsForUser(userId, userRole);
    const unreadList = notifications.filter((item) => !item.is_read);

    if (unreadList.length === 0) {
      return { updatedCount: 0 };
    }

    const firestore = this.firebaseService.firestore;
    const batch = firestore.batch();

    unreadList.forEach((item) => {
      const docRef = firestore.collection(this.collectionName).doc(item.id);
      batch.update(docRef, { is_read: true });
    });

    await batch.commit();
    return { updatedCount: unreadList.length };
  }
}
