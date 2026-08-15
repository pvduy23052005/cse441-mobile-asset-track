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

  private get collection() {
    return this.firebaseService.firestore.collection(this.collectionName);
  }

  async createNotification(dto: CreateNotificationDto): Promise<NotificationItem> {
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

    const docRef = await this.collection.add(dataToSave);
    const result: NotificationItem = { id: docRef.id, ...dataToSave };

    this.notificationsGateway.emitNotification(result);
    return result;
  }

  async getNotificationsForUser(userId: string, userRole?: string): Promise<NotificationItem[]> {
    const notificationsMap = new Map<string, NotificationItem>();

    if (userId) {
      const snap = await this.collection.where('user_id', '==', userId).get();
      snap.forEach((doc) => {
        notificationsMap.set(doc.id, { id: doc.id, ...(doc.data() as FirestoreNotification) });
      });
    }

    if (userRole) {
      const snap = await this.collection.where('target_role', '==', userRole).get();
      snap.forEach((doc) => {
        notificationsMap.set(doc.id, { id: doc.id, ...(doc.data() as FirestoreNotification) });
      });
    }

    if (notificationsMap.size === 0) {
      const snap = await this.collection.limit(20).get();
      snap.forEach((doc) => {
        notificationsMap.set(doc.id, { id: doc.id, ...(doc.data() as FirestoreNotification) });
      });
    }

    return Array.from(notificationsMap.values()).sort(
      (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
  }

  async getUnreadCount(userId: string, userRole?: string): Promise<number> {
    const list = await this.getNotificationsForUser(userId, userRole);
    return list.filter((item) => !item.is_read).length;
  }

  async markAsRead(notificationId: string): Promise<NotificationItem> {
    const docRef = this.collection.doc(notificationId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new NotFoundException(`Không tìm thấy thông báo '${notificationId}'`);
    }

    await docRef.update({ is_read: true });
    return { id: doc.id, ...(doc.data() as FirestoreNotification), is_read: true };
  }

  async markAllAsRead(userId: string, userRole?: string): Promise<{ updatedCount: number }> {
    const list = await this.getNotificationsForUser(userId, userRole);
    const unreadList = list.filter((item) => !item.is_read);

    if (unreadList.length === 0) return { updatedCount: 0 };

    const batch = this.firebaseService.firestore.batch();
    unreadList.forEach((item) => {
      batch.update(this.collection.doc(item.id), { is_read: true });
    });

    await batch.commit();
    return { updatedCount: unreadList.length };
  }
}
