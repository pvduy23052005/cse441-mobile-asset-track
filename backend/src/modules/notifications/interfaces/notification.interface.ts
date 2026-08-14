export enum NotificationTypeEnum {
  SOS = 'SOS',
  PM = 'PM',
  APPROVAL = 'APPROVAL',
  SYSTEM = 'SYSTEM',
}

export type NotificationType = 'SOS' | 'PM' | 'APPROVAL' | 'SYSTEM';

export interface NotificationItem {
  id: string;
  user_id?: string;
  target_role?: string;
  title: string;
  message: string;
  type: NotificationType;
  target_id?: string;
  is_read: boolean;
  created_at: string;
}

export interface FirestoreNotification {
  user_id?: string;
  target_role?: string;
  title: string;
  message: string;
  type: NotificationType;
  target_id?: string;
  is_read: boolean;
  created_at: string;
}
