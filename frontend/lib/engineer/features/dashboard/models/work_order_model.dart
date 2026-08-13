enum WorkOrderSeverity { critical, high, medium, low }

enum WorkOrderStatus { pending, inProgress, completed, rejected, approved, cancelled }

enum PMChecklistStatus { pending, inProgress, completed, approved }

class WorkOrderModel {
  final String id;
  final String code;
  final String machineId;
  final String machineName;
  final WorkOrderSeverity severity;
  final WorkOrderStatus status;
  final String description;
  final String? imageUrl;
  final String? rejectionReason;
  final String? assigneeName;
  final String createdAt;

  WorkOrderModel({
    required this.id,
    required this.code,
    required this.machineId,
    required this.machineName,
    required this.severity,
    required this.status,
    required this.description,
    this.imageUrl,
    this.rejectionReason,
    this.assigneeName,
    required this.createdAt,
  });

  String get severityLabel {
    switch (severity) {
      case WorkOrderSeverity.critical:
        return 'Nghiêm Trọng (CRITICAL)';
      case WorkOrderSeverity.high:
        return 'Cao (HIGH)';
      case WorkOrderSeverity.medium:
        return 'Trung Bình (MEDIUM)';
      case WorkOrderSeverity.low:
        return 'Thấp (LOW)';
    }
  }

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? 'WO-2026',
      machineId: json['machineId']?.toString() ?? '',
      machineName: json['machineName']?.toString() ?? 'Thiết bị không xác định',
      severity: _parseSeverity(json['severity']?.toString()),
      status: _parseStatus(json['status']?.toString()),
      description: json['description']?.toString() ?? 'Chưa có mô tả hư hỏng',
      imageUrl: json['imageUrl']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      assigneeName: json['assigneeName']?.toString(),
      createdAt: json['createdAt']?.toString() ?? 'Hôm nay',
    );
  }

  static WorkOrderSeverity _parseSeverity(String? str) {
    switch (str?.toUpperCase()) {
      case 'CRITICAL':
        return WorkOrderSeverity.critical;
      case 'HIGH':
        return WorkOrderSeverity.high;
      case 'MEDIUM':
        return WorkOrderSeverity.medium;
      default:
        return WorkOrderSeverity.low;
    }
  }

  static WorkOrderStatus _parseStatus(String? str) {
    switch (str?.toUpperCase()) {
      case 'IN_PROGRESS':
        return WorkOrderStatus.inProgress;
      case 'COMPLETED':
        return WorkOrderStatus.completed;
      case 'REJECTED':
        return WorkOrderStatus.rejected;
      case 'APPROVED':
        return WorkOrderStatus.approved;
      case 'CANCELLED':
        return WorkOrderStatus.cancelled;
      default:
        return WorkOrderStatus.pending;
    }
  }
}

class PMChecklistModel {
  final String id;
  final String code;
  final String machineId;
  final String machineName;
  final int scheduledHours;
  final PMChecklistStatus status;
  final int itemCount;

  PMChecklistModel({
    required this.id,
    required this.code,
    required this.machineId,
    required this.machineName,
    required this.scheduledHours,
    required this.status,
    required this.itemCount,
  });
}
