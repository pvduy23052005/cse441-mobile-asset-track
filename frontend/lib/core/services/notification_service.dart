import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../network/api_client.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  /// Gọi REST API Backend NestJS lấy danh sách thông báo thật
  Future<List<AppNotification>> fetchNotificationsFromApi() async {
    try {
      final response = await ApiClient.instance.get('/notifications');
      if (response.statusCode == 200 && response.data is List) {
        final List list = response.data;
        return list.map((item) => AppNotification.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi fetch notifications từ API: $e');
      return [];
    }
  }

  /// Lắng nghe dữ liệu realtime từ Firestore collection 'notifications'
  Stream<List<AppNotification>> streamNotifications({String? userRole, String? userId}) {
    final fs = _firestore;
    if (fs == null) {
      return Stream.value([]);
    }

    return fs
        .collection('notifications')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AppNotification.fromJson(data);
      }).toList();

      // Sắp xếp thời gian giảm dần
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }).handleError((err) {
      debugPrint('Lỗi stream notifications: $err');
      return <AppNotification>[];
    });
  }

  /// Gọi REST API lấy số lượng chưa đọc
  Future<int> fetchUnreadCountFromApi() async {
    try {
      final response = await ApiClient.instance.get('/notifications/unread-count');
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['unreadCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Lỗi fetch unread count từ API: $e');
      return 0;
    }
  }

  /// Đánh dấu 1 thông báo đã đọc qua REST API & Firestore
  Future<bool> markAsRead(String notificationId) async {
    try {
      // 1. Cập nhật Firestore nếu có
      final fs = _firestore;
      if (fs != null) {
        await fs.collection('notifications').doc(notificationId).update({'is_read': true}).catchError((_) {});
      }

      // 2. Gọi API Backend
      await ApiClient.instance.patch('/notifications/$notificationId/read');
      return true;
    } catch (e) {
      debugPrint('Lỗi markAsRead: $e');
      return false;
    }
  }

  /// Đánh dấu tất cả thông báo là đã đọc
  Future<bool> markAllAsRead() async {
    try {
      // 1. Gọi REST API
      await ApiClient.instance.patch('/notifications/read-all');

      // 2. Cập nhật batch Firestore nếu có
      final fs = _firestore;
      if (fs != null) {
        final snapshot = await fs.collection('notifications').where('is_read', isEqualTo: false).get();
        final batch = fs.batch();
        for (var doc in snapshot.docs) {
          batch.update(doc.reference, {'is_read': true});
        }
        await batch.commit().catchError((_) {});
      }

      return true;
    } catch (e) {
      debugPrint('Lỗi markAllAsRead: $e');
      return false;
    }
  }
}
