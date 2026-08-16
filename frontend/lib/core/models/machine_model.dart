import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MachineOperatorModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? role;

  MachineOperatorModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.role,
  });

  factory MachineOperatorModel.fromJson(Map<String, dynamic> json) {
    return MachineOperatorModel(
      id: json['id']?.toString() ?? '',
      fullName:
          json['fullName']?.toString() ?? json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      role: json['role']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
    };
  }
}

class MachineModel {
  final String id;
  final String code;
  final String name;
  final String model;
  final String location;
  final num? nextMaintenanceHours;
  final String status;
  final num runningHours;
  final String? operatorId;
  final MachineOperatorModel? operator;
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
    this.operatorId,
    this.operator,
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
      final val = specs['next_maintenance'].toString().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      parsedNextMaint = num.tryParse(val);
    }

    return MachineModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      location:
          json['location']?.toString() ??
          specs['location']?.toString() ??
          specs['area']?.toString() ??
          '',
      nextMaintenanceHours: parsedNextMaint,
      status: json['status']?.toString() ?? 'ACTIVE',
      runningHours: json['running_hours'] as num? ?? 0,
      operatorId:
          json['operator_id']?.toString() ?? json['operatorId']?.toString(),
      operator: json['operator'] is Map
          ? MachineOperatorModel.fromJson(
              Map<String, dynamic>.from(json['operator'] as Map),
            )
          : null,
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
      if (nextMaintenanceHours != null)
        'next_maintenance_hours': nextMaintenanceHours,
      'status': status,
      'running_hours': runningHours,
      if (operatorId != null) 'operator_id': operatorId,
      if (operator != null) 'operator': operator!.toJson(),
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
      case 'STOPPED':
        return 'Dừng máy';
      case 'ERROR':
      case 'SOS':
      case 'CRITICAL':
        return 'Báo lỗi SOS';
      default:
        return status.isNotEmpty ? status : 'Không xác định';
    }
  }

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const Color(0xFF059669);
      case 'IN_PROGRESS':
      case 'REPAIRING':
        return const Color(0xFF0284C7);
      case 'PENDING':
        return const Color(0xFFD97706);
      case 'MAINTENANCE':
      case 'UNDER_MAINTENANCE':
        return const Color(0xFFEAB308);
      case 'INACTIVE':
      case 'STOPPED':
        return const Color(0xFF64748B);
      case 'ERROR':
      case 'SOS':
      case 'CRITICAL':
        return const Color(0xFFDC2626);
      default:
        return AppTheme.mutedForegroundColor;
    }
  }

  Color get statusBgColor {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const Color(0xFFECFDF5);
      case 'IN_PROGRESS':
      case 'REPAIRING':
        return const Color(0xFFE0F2FE);
      case 'PENDING':
        return const Color(0xFFFEF3C7);
      case 'MAINTENANCE':
      case 'UNDER_MAINTENANCE':
        return const Color(0xFFFEF9C3);
      case 'INACTIVE':
      case 'STOPPED':
        return const Color(0xFFF1F5F9);
      case 'ERROR':
      case 'SOS':
      case 'CRITICAL':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFF8FAFC);
    }
  }
}
