import 'dart:convert';

enum SyncTaskStatus {
  pending('PENDING'),
  processing('PROCESSING'),
  failed('FAILED'),
  completed('COMPLETED');

  final String value;
  const SyncTaskStatus(this.value);

  static SyncTaskStatus fromString(String? val) {
    if (val == null) return SyncTaskStatus.pending;
    return SyncTaskStatus.values.firstWhere(
      (e) => e.value == val.toUpperCase(),
      orElse: () => SyncTaskStatus.pending,
    );
  }
}

class SyncTaskModel {
  final String id;
  final String actionType;
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;
  final String? localRecordId;
  final int retryCount;
  final int maxRetries;
  final SyncTaskStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  SyncTaskModel({
    required this.id,
    required this.actionType,
    required this.endpoint,
    this.method = 'POST',
    required this.payload,
    this.localRecordId,
    this.retryCount = 0,
    this.maxRetries = 5,
    this.status = SyncTaskStatus.pending,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get canRetry => retryCount < maxRetries;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action_type': actionType,
      'endpoint': endpoint,
      'method': method,
      'payload': jsonEncode(payload),
      'local_record_id': localRecordId,
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'status': status.value,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SyncTaskModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> parsePayload(dynamic raw) {
      if (raw is Map) return Map<String, dynamic>.from(raw);
      if (raw is String && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }
      return {};
    }

    return SyncTaskModel(
      id: map['id']?.toString() ?? '',
      actionType: map['action_type']?.toString() ?? 'CREATE_TICKET',
      endpoint: map['endpoint']?.toString() ?? '/operator/tickets',
      method: map['method']?.toString() ?? 'POST',
      payload: parsePayload(map['payload']),
      localRecordId: map['local_record_id']?.toString(),
      retryCount: (map['retry_count'] as num?)?.toInt() ?? 0,
      maxRetries: (map['max_retries'] as num?)?.toInt() ?? 5,
      status: SyncTaskStatus.fromString(map['status']?.toString()),
      errorMessage: map['error_message']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  SyncTaskModel copyWith({
    String? id,
    String? actionType,
    String? endpoint,
    String? method,
    Map<String, dynamic>? payload,
    String? localRecordId,
    int? retryCount,
    int? maxRetries,
    SyncTaskStatus? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyncTaskModel(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      payload: payload ?? this.payload,
      localRecordId: localRecordId ?? this.localRecordId,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
