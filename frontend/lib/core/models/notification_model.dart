enum NotificationType {
  sos,
  pm,
  approval,
  system,
}

class AppNotification {
  final String id;
  final String? userId;
  final String? targetRole;
  final String title;
  final String message;
  final NotificationType type;
  final String? targetId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    this.userId,
    this.targetRole,
    required this.title,
    required this.message,
    required this.type,
    this.targetId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    NotificationType parseType(String? rawType) {
      switch (rawType?.toUpperCase()) {
        case 'SOS':
          return NotificationType.sos;
        case 'PM':
          return NotificationType.pm;
        case 'APPROVAL':
          return NotificationType.approval;
        case 'SYSTEM':
        default:
          return NotificationType.system;
      }
    }

    DateTime parseDate(dynamic rawDate) {
      if (rawDate == null) return DateTime.now();
      if (rawDate is String) {
        return DateTime.tryParse(rawDate) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return AppNotification(
      id: json['id'] ?? '',
      userId: json['user_id'],
      targetRole: json['target_role'],
      title: json['title'] ?? 'Thông Báo',
      message: json['message'] ?? '',
      type: parseType(json['type']),
      targetId: json['target_id'],
      isRead: json['is_read'] ?? false,
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    String typeToString(NotificationType t) {
      switch (t) {
        case NotificationType.sos:
          return 'SOS';
        case NotificationType.pm:
          return 'PM';
        case NotificationType.approval:
          return 'APPROVAL';
        case NotificationType.system:
          return 'SYSTEM';
      }
    }

    return {
      'id': id,
      'user_id': userId,
      'target_role': targetRole,
      'title': title,
      'message': message,
      'type': typeToString(type),
      'target_id': targetId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
