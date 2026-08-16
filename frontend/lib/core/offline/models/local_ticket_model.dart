import 'dart:convert';

enum SyncStatus {
  pending('PENDING'),
  synced('SYNCED'),
  failed('FAILED');

  final String value;
  const SyncStatus(this.value);

  static SyncStatus fromString(String? val) {
    if (val == null) return SyncStatus.pending;
    return SyncStatus.values.firstWhere(
      (e) => e.value == val.toUpperCase(),
      orElse: () => SyncStatus.pending,
    );
  }
}

class LocalTicketModel {
  final String id;
  final String machineId;
  final String? machineName;
  final String? machineCode;
  final String description;
  final String severity;
  final String status;
  final List<String> imagesUrls;
  final List<String> localImagePaths;
  final String? downtimeStart;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  LocalTicketModel({
    required this.id,
    required this.machineId,
    this.machineName,
    this.machineCode,
    required this.description,
    required this.severity,
    this.status = 'PENDING',
    this.imagesUrls = const [],
    this.localImagePaths = const [],
    this.downtimeStart,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPendingSync => syncStatus == SyncStatus.pending;
  bool get isSynced => syncStatus == SyncStatus.synced;
  bool get isFailedSync => syncStatus == SyncStatus.failed;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machine_id': machineId,
      'machine_name': machineName,
      'machine_code': machineCode,
      'description': description,
      'severity': severity,
      'status': status,
      'images_urls': jsonEncode(imagesUrls),
      'local_image_paths': jsonEncode(localImagePaths),
      'downtime_start': downtimeStart,
      'sync_status': syncStatus.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LocalTicketModel.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      if (raw is String && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {}
      }
      return [];
    }

    return LocalTicketModel(
      id: map['id']?.toString() ?? '',
      machineId: map['machine_id']?.toString() ?? '',
      machineName: map['machine_name']?.toString(),
      machineCode: map['machine_code']?.toString(),
      description: map['description']?.toString() ?? '',
      severity: map['severity']?.toString() ?? 'MEDIUM',
      status: map['status']?.toString() ?? 'PENDING',
      imagesUrls: parseList(map['images_urls']),
      localImagePaths: parseList(map['local_image_paths']),
      downtimeStart: map['downtime_start']?.toString(),
      syncStatus: SyncStatus.fromString(map['sync_status']?.toString()),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toDashboardTicketJson() {
    return {
      'id': id,
      'machine_id': machineId,
      'machine_name': machineName ?? machineCode ?? 'Thiết bị',
      'machine_code': machineCode ?? '',
      'description': description,
      'severity': severity,
      'status': status,
      'images_urls': imagesUrls.isNotEmpty ? imagesUrls : localImagePaths,
      'sync_status': syncStatus.value,
      'is_local': isPendingSync || isFailedSync,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LocalTicketModel copyWith({
    String? id,
    String? machineId,
    String? machineName,
    String? machineCode,
    String? description,
    String? severity,
    String? status,
    List<String>? imagesUrls,
    List<String>? localImagePaths,
    String? downtimeStart,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocalTicketModel(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      machineCode: machineCode ?? this.machineCode,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      imagesUrls: imagesUrls ?? this.imagesUrls,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      downtimeStart: downtimeStart ?? this.downtimeStart,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
