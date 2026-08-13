enum TicketStatus {
  open, // OPEN / PENDING (Chờ tiếp nhận)
  inProgress, // IN_PROGRESS (Đang xử lý)
  pendingApproval, // PENDING_APPROVAL / COMPLETED (Hoàn thành - Chờ nghiệm thu)
  closed, // CLOSED / APPROVED (Đã nghiệm thu)
  rejected, // REJECTED (Quản đốc từ chối nghiệm thu)
  cancelled, // CANCELLED (Đã hủy)
}

enum TicketSeverity {
  critical, // NGHIÊM TRỌNG (CRITICAL)
  medium, // VỪA (MEDIUM)
  low, // THẤP (LOW)
}

class SparePartItem {
  final String id;
  final String code;
  final String name;
  final int quantity;
  final String unit;
  final double unitPrice;

  SparePartItem({
    required this.id,
    required this.code,
    required this.name,
    required this.quantity,
    this.unit = 'Cái',
    this.unitPrice = 0.0,
  });

  factory SparePartItem.fromJson(Map<String, dynamic> json) {
    return SparePartItem(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? 'PART-001',
      name: json['name']?.toString() ?? 'Linh kiện thay thế',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unit: json['unit']?.toString() ?? 'Cái',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
    };
  }
}

class TicketModel {
  final String id;
  final String code;
  final String machineId;
  final String machineCode;
  final String machineName;
  final String description;
  final TicketSeverity severity;
  final TicketStatus status;
  final String? imageUrl;
  final String? rejectionReason;
  final String? reporterName;
  final String? engineerName;
  final String createdAt;
  final List<SparePartItem> usedSpareParts;

  TicketModel({
    required this.id,
    required this.code,
    required this.machineId,
    required this.machineCode,
    required this.machineName,
    required this.description,
    required this.severity,
    required this.status,
    this.imageUrl,
    this.rejectionReason,
    this.reporterName,
    this.engineerName,
    required this.createdAt,
    this.usedSpareParts = const [],
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final rawParts = json['used_spare_parts'] as List<dynamic>? ?? json['usedSpareParts'] as List<dynamic>?;
    List<SparePartItem> parts = [];
    if (rawParts != null) {
      parts = rawParts
          .map((p) => SparePartItem.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();
    }

    return TicketModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? json['machine_code']?.toString() ?? 'SOS-2026-001',
      machineId: json['machine_id']?.toString() ?? json['machineId']?.toString() ?? '',
      machineCode: json['machine_code']?.toString() ?? json['machineCode']?.toString() ?? 'MC-001',
      machineName: json['machine_name']?.toString() ?? json['machineName']?.toString() ?? 'Thiết bị nhà máy',
      description: json['description']?.toString() ?? 'Cảnh báo sự cố khẩn cấp',
      severity: _parseSeverity(json['severity']?.toString()),
      status: _parseStatus(json['status']?.toString()),
      imageUrl: (json['images_urls'] is List && (json['images_urls'] as List).isNotEmpty)
          ? (json['images_urls'] as List).first.toString()
          : json['imageUrl']?.toString(),
      rejectionReason: json['rejection_reason']?.toString() ?? json['rejectionReason']?.toString(),
      reporterName: json['reporter_name']?.toString() ?? json['reporterName']?.toString(),
      engineerName: json['engineer_name']?.toString() ?? json['engineerName']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? 'Vừa xong',
      usedSpareParts: parts,
    );
  }

  static TicketStatus _parseStatus(String? str) {
    switch (str?.toUpperCase()) {
      case 'IN_PROGRESS':
        return TicketStatus.inProgress;
      case 'PENDING_APPROVAL':
      case 'COMPLETED':
      case 'SUBMITTED':
        return TicketStatus.pendingApproval;
      case 'CLOSED':
      case 'APPROVED':
        return TicketStatus.closed;
      case 'REJECTED':
        return TicketStatus.rejected;
      case 'CANCELLED':
        return TicketStatus.cancelled;
      default:
        return TicketStatus.open;
    }
  }

  static TicketSeverity _parseSeverity(String? str) {
    switch (str?.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return TicketSeverity.critical;
      case 'LOW':
        return TicketSeverity.low;
      default:
        return TicketSeverity.medium;
    }
  }
}
