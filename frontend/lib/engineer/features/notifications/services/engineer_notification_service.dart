import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/engineer_notification.dart';

class EngineerNotificationService {
  static final EngineerNotificationService _instance =
      EngineerNotificationService._internal();
  factory EngineerNotificationService() => _instance;
  EngineerNotificationService._internal();

  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  Future<List<EngineerNotification>> fetchNotificationsFromApi() async {
    try {
      final response = await ApiClient.instance.get('/notifications');
      if (response.statusCode == 200 && response.data is List) {
        final List list = response.data;
        return list
            .map((item) => EngineerNotification.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi fetch notifications từ Backend API: $e');
      return [];
    }
  }

  Stream<List<EngineerNotification>> streamNotifications() {
    final fs = _firestore;
    if (fs == null) {
      return Stream.value([]);
    }

    final userProfile = StorageService.getUserProfile();
    final currentUserId = userProfile['uid'] ?? userProfile['id'] ?? '';

    return fs.collection('notifications').snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EngineerNotification.fromJson(data);
      }).where((notification) {
        final role = notification.targetRole?.toLowerCase();
        final isForEngineer = role == 'engineer' || role == 'me_engineer';
        final isForCurrentUser =
            notification.userId != null && notification.userId == currentUserId;
        final isGlobal = notification.targetRole == null && notification.userId == null;

        return isForEngineer || isForCurrentUser || isGlobal;
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }).handleError((err) {
      debugPrint('Lỗi stream notifications: $err');
      return <EngineerNotification>[];
    });
  }

  Future<int> fetchUnreadCountFromApi() async {
    try {
      final response =
          await ApiClient.instance.get('/notifications/unread-count');
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['unreadCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Lỗi fetch unread count: $e');
      return 0;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        await fs
            .collection('notifications')
            .doc(notificationId)
            .update({'is_read': true}).catchError((_) {});
      }

      await ApiClient.instance.patch('/notifications/$notificationId/read');
      return true;
    } catch (e) {
      debugPrint('Lỗi markAsRead: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await ApiClient.instance.patch('/notifications/read-all');

      final fs = _firestore;
      if (fs != null) {
        final snapshot = await fs
            .collection('notifications')
            .where('is_read', isEqualTo: false)
            .get();
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
