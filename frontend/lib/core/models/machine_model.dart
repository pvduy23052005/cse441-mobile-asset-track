import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MachineModel {
  final String id;
  final String code;
  final String name;
  final String model;
  final String location;
  final num? nextMaintenanceHours;
  final String status;
  final num runningHours;
  final Map<String, dynamic> specifications;
  final String? createdAt;
  final String? updatedAt;

  MachineModel({
    required this.id,
    required this.code,
    required this.name,
    this.model = '',
    this.location = '',
    this.nextMaintenanceHours,
    required this.status,
    this.runningHours = 0,
    this.specifications = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    final specs = json['specifications'] is Map
        ? Map<String, dynamic>.from(json['specifications'] as Map)
        : <String, dynamic>{};

    num? parsedNextMaint;
    if (json['next_maintenance_hours'] != null) {
      parsedNextMaint = json['next_maintenance_hours'] as num?;
    } else if (specs['next_maintenance_hours'] != null) {
      parsedNextMaint = specs['next_maintenance_hours'] as num?;
    } else if (specs['next_maintenance'] != null) {
      final val = specs['next_maintenance'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      parsedNextMaint = num.tryParse(val);
    }

    return MachineModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      location: json['location']?.toString() ??
          specs['location']?.toString() ??
          specs['area']?.toString() ??
          '',
      nextMaintenanceHours: parsedNextMaint,
      status: json['status']?.toString() ?? 'ACTIVE',
      runningHours: json['running_hours'] as num? ?? 0,
      specifications: specs,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'model': model,
      'location': location,
      if (nextMaintenanceHours != null) 'next_maintenance_hours': nextMaintenanceHours,
      'status': status,
      'running_hours': runningHours,
      'specifications': specifications,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Hoạt động';
      case 'IN_PROGRESS':
      case 'REPAIRING':
        return 'Đang xử lý';
      case 'PENDING':
        return 'Chờ tiếp nhận';
      case 'MAINTENANCE':
      case 'UNDER_MAINTENANCE':
        return 'Bảo trì';
      case 'INACTIVE':
        return 'Tạm dừng';
      case 'ERROR':
        return 'Lỗi / Cần sửa';
      default:
        return status.isNotEmpty ? status : 'Không xác định';
    }
  }

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AppTheme.primaryColor;
      case 'IN_PROGRESS':
      case 'REPAIRING':
        return const Color(0xFF0284C7); // Cyan / Blue
      case 'PENDING':
        return const Color(0xFFD97706); // Amber
      case 'MAINTENANCE':
      case 'UNDER_MAINTENANCE':
        return const Color(0xFFEA580C); // Orange
      case 'INACTIVE':
        return AppTheme.mutedForegroundColor;
      case 'ERROR':
        return AppTheme.errorColor;
      default:
        return AppTheme.mutedForegroundColor;
    }
  }

  Color get statusBgColor {
    return statusColor.withValues(alpha: 0.12);
  }

  IconData get statusIcon {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Icons.grid_view_rounded;
      case 'IN_PROGRESS':
      case 'REPAIRING':
        return Icons.precision_manufacturing_rounded;
      case 'PENDING':
        return Icons.memory_rounded;
      case 'MAINTENANCE':
      case 'UNDER_MAINTENANCE':
        return Icons.build_rounded;
      case 'ERROR':
        return Icons.memory_rounded;
      case 'INACTIVE':
      default:
        return Icons.power_settings_new_rounded;
    }
  }
}
