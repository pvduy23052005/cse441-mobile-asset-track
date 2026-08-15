import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { FirestoreCollection } from '../../common/constants/firestore-collections.enum';
import { FirebaseService } from '../firebase/firebase.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
import {
  FirestoreNotification,
  NotificationItem,
} from './interfaces/notification.interface';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private readonly collectionName = FirestoreCollection.NOTIFICATIONS;

  constructor(private readonly firebaseService: FirebaseService) {}

  private get collection() {
    return this.firebaseService.firestore.collection(this.collectionName);
  }

  async createNotification(
    dto: CreateNotificationDto,
  ): Promise<NotificationItem> {
    const dataToSave: FirestoreNotification = {
      title: dto.title,
      message: dto.message,
      type: dto.type,
      is_read: false,
      created_at: new Date().toISOString(),
      ...(dto.user_id && { user_id: dto.user_id }),
      ...(dto.target_role && { target_role: dto.target_role }),
      ...(dto.target_id && { target_id: dto.target_id }),
    };

    const documentReference = await this.collection.add(dataToSave);
    return { id: documentReference.id, ...dataToSave };
  }

  async getNotificationsForUser(
    userId: string,
    userRole?: string,
  ): Promise<NotificationItem[]> {
    const notificationsMap = new Map<string, NotificationItem>();

    if (userId) {
      const userQuerySnapshot = await this.collection
        .where('user_id', '==', userId)
        .get();
      userQuerySnapshot.forEach((documentSnapshot) => {
        notificationsMap.set(documentSnapshot.id, {
          id: documentSnapshot.id,
          ...(documentSnapshot.data() as FirestoreNotification),
        });
      });
    }

    if (userRole) {
      const roleQuerySnapshot = await this.collection
        .where('target_role', '==', userRole)
        .get();
      roleQuerySnapshot.forEach((documentSnapshot) => {
        notificationsMap.set(documentSnapshot.id, {
          id: documentSnapshot.id,
          ...(documentSnapshot.data() as FirestoreNotification),
        });
      });
    }

    if (notificationsMap.size === 0) {
      const globalQuerySnapshot = await this.collection.limit(20).get();
      globalQuerySnapshot.forEach((documentSnapshot) => {
        notificationsMap.set(documentSnapshot.id, {
          id: documentSnapshot.id,
          ...(documentSnapshot.data() as FirestoreNotification),
        });
      });
    }

    return Array.from(notificationsMap.values()).sort(
      (firstNotification, secondNotification) =>
        new Date(secondNotification.created_at).getTime() -
        new Date(firstNotification.created_at).getTime(),
    );
  }

  async getUnreadCount(userId: string, userRole?: string): Promise<number> {
    const notificationsList = await this.getNotificationsForUser(
      userId,
      userRole,
    );
    return notificationsList.filter((notification) => !notification.is_read)
      .length;
  }

  async markAsRead(notificationId: string): Promise<NotificationItem> {
    const documentReference = this.collection.doc(notificationId);
    const documentSnapshot = await documentReference.get();

    if (!documentSnapshot.exists) {
      throw new NotFoundException(
        `Không tìm thấy thông báo '${notificationId}'`,
      );
    }

    await documentReference.update({ is_read: true });
    return {
      id: documentSnapshot.id,
      ...(documentSnapshot.data() as FirestoreNotification),
      is_read: true,
    };
  }

  async markAllAsRead(
    userId: string,
    userRole?: string,
  ): Promise<{ updatedCount: number }> {
    const notificationsList = await this.getNotificationsForUser(
      userId,
      userRole,
    );
    const unreadNotifications = notificationsList.filter(
      (notification) => !notification.is_read,
    );

    if (unreadNotifications.length === 0) return { updatedCount: 0 };

    const batch = this.firebaseService.firestore.batch();
    unreadNotifications.forEach((notification) => {
      batch.update(this.collection.doc(notification.id), { is_read: true });
    });

    await batch.commit();
    return { updatedCount: unreadNotifications.length };
  }
}
