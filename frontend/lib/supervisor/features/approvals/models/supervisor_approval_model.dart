class ApprovalSparePartItem {
  final String id;
  final String code;
  final String name;
  final int quantity;
  final String unit;

  ApprovalSparePartItem({
    required this.id,
    required this.code,
    required this.name,
    required this.quantity,
    this.unit = 'Cái',
  });

  factory ApprovalSparePartItem.fromJson(Map<String, dynamic> json) {
    return ApprovalSparePartItem(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? 'PART-001',
      name: json['name']?.toString() ?? 'Linh kiện thay thế',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unit: json['unit']?.toString() ?? 'Cái',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class SupervisorApprovalModel {
  final String id;
  final String code;
  final String title;
  final String machineId;
  final String machineCode;
  final String machineName;
  final String engineerName;
  final String downtimeDuration;
  final List<ApprovalSparePartItem> usedSpareParts;
  final String description;
  final String status; // 'COMPLETED', 'APPROVED', 'REJECTED'
  final String? rejectionReason;
  final String? signatureUrl;
  final String createdAt;
  final DateTime? actionTimestamp;

  SupervisorApprovalModel({
    required this.id,
    required this.code,
    required this.title,
    required this.machineId,
    required this.machineCode,
    required this.machineName,
    required this.engineerName,
    required this.downtimeDuration,
    required this.usedSpareParts,
    required this.description,
    required this.status,
    this.rejectionReason,
    this.signatureUrl,
    required this.createdAt,
    this.actionTimestamp,
  });

  factory SupervisorApprovalModel.fromJson(Map<String, dynamic> json) {
    final rawParts = json['used_spare_parts'] as List<dynamic>? ??
        json['usedSpareParts'] as List<dynamic>?;
    List<ApprovalSparePartItem> parts = [];
    if (rawParts != null) {
      parts = rawParts
          .map((p) =>
              ApprovalSparePartItem.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();
    }

    final ticketCode = json['code']?.toString() ??
        json['ticket_code']?.toString() ??
        json['machine_code']?.toString() ??
        'SOS-TICKET';

    final mCode = json['machine_code']?.toString() ??
        json['machineCode']?.toString() ??
        json['machine']?['code']?.toString() ??
        'MC-N/A';

    final mName = json['machine_name']?.toString() ??
        json['machineName']?.toString() ??
        json['machine']?['name']?.toString() ??
        'Thiết bị nhà xưởng';

    final engName = json['engineer_name']?.toString() ??
        json['engineerName']?.toString() ??
        json['assignee']?['fullName']?.toString() ??
        'Kỹ sư ME';

    final downtime = json['downtime_duration']?.toString() ??
        json['downtimeDuration']?.toString() ??
        'N/A';

    final actionTimeRaw = json['updated_at']?.toString() ?? json['updatedAt']?.toString();
    final actionTime = actionTimeRaw != null ? DateTime.tryParse(actionTimeRaw) : null;

    return SupervisorApprovalModel(
      id: json['id']?.toString() ?? '',
      code: ticketCode,
      title: json['title']?.toString() ?? 'Nghiệm Thu Phiếu: $ticketCode',
      machineId: json['machine_id']?.toString() ?? json['machineId']?.toString() ?? '',
      machineCode: mCode,
      machineName: mName,
      engineerName: engName,
      downtimeDuration: downtime,
      usedSpareParts: parts,
      description: json['description']?.toString() ?? 'Báo cáo sự cố bảo trì',
      status: json['status']?.toString().toUpperCase() ?? 'COMPLETED',
      rejectionReason: json['rejection_reason']?.toString() ?? json['rejectionReason']?.toString(),
      signatureUrl: json['supervisor_signature_url']?.toString() ?? json['signatureUrl']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? 'Vừa xong',
      actionTimestamp: actionTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'machine_id': machineId,
      'machine_code': machineCode,
      'machine_name': machineName,
      'engineer_name': engineerName,
      'downtime_duration': downtimeDuration,
      'used_spare_parts': usedSpareParts.map((p) => p.toJson()).toList(),
      'description': description,
      'status': status,
      'rejection_reason': rejectionReason,
      'supervisor_signature_url': signatureUrl,
      'created_at': createdAt,
    };
  }
}
