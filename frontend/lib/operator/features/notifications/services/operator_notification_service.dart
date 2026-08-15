import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../engineer/features/notifications/models/engineer_notification.dart';

class OperatorNotificationService {
  static final OperatorNotificationService _instance =
      OperatorNotificationService._internal();
  factory OperatorNotificationService() => _instance;
  OperatorNotificationService._internal();

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
        final isForOperator = role == 'operator';
        final isForCurrentUser =
            notification.userId != null && notification.userId == currentUserId;
        final isGlobal =
            notification.targetRole == null && notification.userId == null;

        return isForOperator || isForCurrentUser || isGlobal;
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<int> streamUnreadCount() {
    return streamNotifications().map((list) {
      return list.where((n) => !n.isRead).length;
    });
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await ApiClient.instance.patch('/notifications/$notificationId/read');
    } catch (_) {
      try {
        await _firestore
            ?.collection('notifications')
            .doc(notificationId)
            .update({'is_read': true});
      } catch (_) {}
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiClient.instance.patch('/notifications/read-all');
    } catch (_) {
      final userProfile = StorageService.getUserProfile();
      final currentUserId = userProfile['uid'] ?? userProfile['id'] ?? '';

      try {
        final snapshot =
            await _firestore?.collection('notifications').get();
        if (snapshot != null) {
          final batch = _firestore!.batch();
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final role = data['target_role']?.toString().toLowerCase();
            final uid = data['user_id']?.toString();
            if ((role == 'operator' || uid == currentUserId) &&
                data['is_read'] != true) {
              batch.update(doc.reference, {'is_read': true});
            }
          }
          await batch.commit();
        }
      } catch (_) {}
    }
  }
}
