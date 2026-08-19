class ApprovalSparePartItem {
  final String id;
  final String code;
  final String name;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double totalCost;

  ApprovalSparePartItem({
    required this.id,
    required this.code,
    required this.name,
    required this.quantity,
    this.unit = 'Cái',
    this.unitPrice = 0.0,
    double? totalCost,
  }) : totalCost = totalCost ?? (quantity * unitPrice);

  factory ApprovalSparePartItem.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toInt() ?? 1;
    final price = (json['unit_price'] as num?)?.toDouble() ??
        (json['unitPrice'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        (json['unit_price_raw'] as num?)?.toDouble() ??
        500000.0;
    final cost = (json['total_cost'] as num?)?.toDouble() ??
        (json['totalCost'] as num?)?.toDouble() ??
        (qty * price);

    return ApprovalSparePartItem(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? 'PART-001',
      name: json['name']?.toString() ?? 'Linh kiện thay thế',
      quantity: qty,
      unit: json['unit']?.toString() ?? 'Cái',
      unitPrice: price,
      totalCost: cost,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'total_cost': totalCost,
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

  double get totalSparePartsCost {
    return usedSpareParts.fold(0.0, (sum, item) => sum + item.totalCost);
  }

  bool get requiresHighCostApproval {
    return totalSparePartsCost >= 2000000.0;
  }

  factory SupervisorApprovalModel.fromJson(Map<String, dynamic> json) {
    final rawParts = json['used_spare_parts'] as List<dynamic>? ??
        json['usedSpareParts'] as List<dynamic>?;
    List<ApprovalSparePartItem> parts = [];
    if (rawParts != null && rawParts.isNotEmpty) {
      parts = rawParts
          .map((p) =>
              ApprovalSparePartItem.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();
    } else {
      // Default demo spare parts with unit prices if empty
      parts = [
        ApprovalSparePartItem(
          id: 'sp-1',
          code: 'SP-VG68',
          name: 'Dầu bôi trơn công nghiệp ISO VG 68 (10L)',
          quantity: 2,
          unit: 'Cái',
          unitPrice: 650000.0,
          totalCost: 1300000.0,
        ),
        ApprovalSparePartItem(
          id: 'sp-2',
          code: 'SP-GK01',
          name: 'Bộ gioăng cao su chịu nhiệt đệm van khí nén',
          quantity: 1,
          unit: 'Cái',
          unitPrice: 450000.0,
          totalCost: 450000.0,
        ),
      ];
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
        'Kỹ Sư ME Trần Minh Đức';

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
