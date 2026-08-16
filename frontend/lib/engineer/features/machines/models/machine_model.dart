enum MachineStatus { active, repairing, maintenance, inactive }

class TroubleshootingItem {
  final String issue;
  final String solution;

  TroubleshootingItem({
    required this.issue,
    required this.solution,
  });

  factory TroubleshootingItem.fromJson(Map<String, dynamic> json) {
    return TroubleshootingItem(
      issue: json['issue']?.toString() ?? '',
      solution: json['solution']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issue': issue,
      'solution': solution,
    };
  }
}

class MachineModel {
  final String id;
  final String code;
  final String name;
  final String model;
  final String location;
  final MachineStatus status;
  final double runningHours;
  final double nextMaintenanceHours;
  final String lastMaintenanceDate;
  final double lastMaintenanceHours;
  final String trackingUnit;
  final Map<String, dynamic> specifications;
  final List<TroubleshootingItem> quickTroubleshooting;

  MachineModel({
    required this.id,
    required this.code,
    required this.name,
    required this.model,
    required this.location,
    required this.status,
    required this.runningHours,
    required this.nextMaintenanceHours,
    required this.lastMaintenanceDate,
    required this.lastMaintenanceHours,
    this.trackingUnit = 'HOURS',
    required this.specifications,
    required this.quickTroubleshooting,
  });

  String get unitLabel => trackingUnit == 'KM' ? 'Số Km vận hành' : 'Số giờ vận hành';

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    final specs = (json['specifications'] as Map<String, dynamic>?) ?? {
      'power': '37 kW',
      'voltage': '380V / 50Hz',
      'manufacturer': 'Mazak Japan',
      'year': '2023',
    };

    final rawTrouble = json['quickTroubleshooting'] as List<dynamic>? ??
        json['quick_troubleshooting'] as List<dynamic>?;
    List<TroubleshootingItem> troubleList = [];
    if (rawTrouble != null) {
      troubleList = rawTrouble
          .map((item) => TroubleshootingItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return MachineModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? 'MC-001',
      name: json['name']?.toString() ?? 'Thiết bị nhà máy',
      model: json['model']?.toString() ?? 'Standard Model',
      location: json['location']?.toString() ?? 'Phân Xưởng Cơ Khí',
      status: _parseStatus(json['status']?.toString()),
      runningHours: (json['running_hours'] as num?)?.toDouble() ?? (json['runningHours'] as num?)?.toDouble() ?? 850.0,
      nextMaintenanceHours: (json['next_maintenance_hours'] as num?)?.toDouble() ?? (json['nextMaintenanceHours'] as num?)?.toDouble() ?? 1000.0,
      lastMaintenanceDate: json['lastMaintenanceDate']?.toString() ?? '12/06/2026',
      lastMaintenanceHours: (json['lastMaintenanceHours'] as num?)?.toDouble() ?? 500.0,
      trackingUnit: json['trackingUnit']?.toString() ?? json['tracking_unit']?.toString() ?? 'HOURS',
      specifications: specs,
      quickTroubleshooting: troubleList,
    );
  }

  static MachineStatus _parseStatus(String? str) {
    switch (str?.toUpperCase()) {
      case 'REPAIRING':
        return MachineStatus.repairing;
      case 'MAINTENANCE':
        return MachineStatus.maintenance;
      case 'INACTIVE':
        return MachineStatus.inactive;
      default:
        return MachineStatus.active;
    }
  }
}
