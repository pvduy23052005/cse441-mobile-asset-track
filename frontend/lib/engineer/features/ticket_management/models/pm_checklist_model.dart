class PMChecklistItem {
  final String id;
  final String title;
  final bool isCompleted;

  PMChecklistItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory PMChecklistItem.fromJson(Map<String, dynamic> json) {
    return PMChecklistItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['task']?.toString() ?? 'Hạng mục kiểm tra',
      isCompleted: json['isCompleted'] == true || json['is_completed'] == true,
    );
  }

  PMChecklistItem copyWith({bool? isCompleted}) {
    return PMChecklistItem(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class PMChecklistModel {
  final String id;
  final String code;
  final String machineId;
  final String machineCode;
  final String machineName;
  final double scheduledHours;
  final String status;
  final List<PMChecklistItem> items;

  PMChecklistModel({
    required this.id,
    required this.code,
    required this.machineId,
    required this.machineCode,
    required this.machineName,
    required this.scheduledHours,
    required this.status,
    required this.items,
  });

  factory PMChecklistModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>?;
    List<PMChecklistItem> itemList = [];
    if (rawItems != null) {
      itemList = rawItems
          .map((i) => PMChecklistItem.fromJson(Map<String, dynamic>.from(i as Map)))
          .toList();
    } else {
      itemList = [
        PMChecklistItem(id: '1', title: 'Kiểm tra mức dầu bôi trơn & thay mới nếu sẫm màu', isCompleted: true),
        PMChecklistItem(id: '2', title: 'Siết lại toàn bộ bulong đỡ chân máy & quạt gió', isCompleted: false),
        PMChecklistItem(id: '3', title: 'Vệ sinh lưới lọc bụi khí nạp phía sau động cơ', isCompleted: false),
        PMChecklistItem(id: '4', title: 'Đo điện áp 3 pha đầu vào và dòng khởi động (Ampe)', isCompleted: false),
      ];
    }

    return PMChecklistModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? 'PM-2026-001',
      machineId: json['machine_id']?.toString() ?? json['machineId']?.toString() ?? '',
      machineCode: json['machine_code']?.toString() ?? json['machineCode']?.toString() ?? 'MC-001',
      machineName: json['machine_name']?.toString() ?? json['machineName']?.toString() ?? 'Thiết bị bảo trì',
      scheduledHours: (json['scheduled_hours'] as num?)?.toDouble() ?? (json['scheduledHours'] as num?)?.toDouble() ?? 500.0,
      status: json['status']?.toString() ?? 'PENDING',
      items: itemList,
    );
  }
}
