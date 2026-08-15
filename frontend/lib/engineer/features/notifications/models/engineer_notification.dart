enum EngineerNotificationType {
  sos,
  pm,
  approval,
  system,
}

class EngineerNotification {
  final String id;
  final String? userId;
  final String? targetRole;
  final String title;
  final String message;
  final EngineerNotificationType type;
  final String? targetId;
  final bool isRead;
  final DateTime createdAt;

  EngineerNotification({
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

  factory EngineerNotification.fromJson(Map<String, dynamic> json) {
    EngineerNotificationType parseType(String? rawType) {
      switch (rawType?.toUpperCase()) {
        case 'SOS':
          return EngineerNotificationType.sos;
        case 'PM':
          return EngineerNotificationType.pm;
        case 'APPROVAL':
          return EngineerNotificationType.approval;
        case 'SYSTEM':
        default:
          return EngineerNotificationType.system;
      }
    }

    DateTime parseDate(dynamic rawDate) {
      if (rawDate == null) return DateTime.now();
      if (rawDate is String) {
        return DateTime.tryParse(rawDate) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return EngineerNotification(
      id: json['id'] ?? '',
      userId: json['user_id'],
      targetRole: json['target_role'],
      title: json['title'] ?? 'Thông Báo Sự Cố',
      message: json['message'] ?? '',
      type: parseType(json['type']),
      targetId: json['target_id'],
      isRead: json['is_read'] ?? false,
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    String typeToString(EngineerNotificationType t) {
      switch (t) {
        case EngineerNotificationType.sos:
          return 'SOS';
        case EngineerNotificationType.pm:
          return 'PM';
        case EngineerNotificationType.approval:
          return 'APPROVAL';
        case EngineerNotificationType.system:
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
