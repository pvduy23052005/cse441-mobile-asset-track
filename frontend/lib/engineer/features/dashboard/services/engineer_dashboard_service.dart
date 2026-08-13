import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/work_order_model.dart';

class EngineerDashboardService {
  final Dio _dio = ApiClient.instance;

  // Real Backend NestJS + Firestore DB API Call for Work Orders
  Future<List<WorkOrderModel>> fetchWorkOrdersFromApi() async {
    try {
      final response = await _dio.get<List<dynamic>>('/machines/work-orders');
      if (response.data != null) {
        return response.data!.map((item) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(item as Map);

          WorkOrderSeverity severity = WorkOrderSeverity.medium;
          final sevStr = data['severity']?.toString().toUpperCase();
          if (sevStr == 'CRITICAL') {
            severity = WorkOrderSeverity.critical;
          } else if (sevStr == 'HIGH') {
            severity = WorkOrderSeverity.high;
          } else if (sevStr == 'LOW') {
            severity = WorkOrderSeverity.low;
          }

          WorkOrderStatus status = WorkOrderStatus.pending;
          final statusStr = data['status']?.toString().toUpperCase();
          if (statusStr == 'IN_PROGRESS') {
            status = WorkOrderStatus.inProgress;
          } else if (statusStr == 'COMPLETED') {
            status = WorkOrderStatus.completed;
          } else if (statusStr == 'APPROVED') {
            status = WorkOrderStatus.approved;
          } else if (statusStr == 'REJECTED') {
            status = WorkOrderStatus.rejected;
          }

          return WorkOrderModel(
            id: data['id']?.toString() ?? '',
            code: data['code']?.toString() ?? 'SOS-001',
            machineId: data['machineId']?.toString() ?? '',
            machineName: data['machineName']?.toString() ?? 'Thiết bị nhà máy',
            severity: severity,
            status: status,
            description: data['description']?.toString() ?? '',
            imageUrl: data['imageUrl']?.toString(),
            assigneeName: data['assigneeName']?.toString(),
            rejectionReason: data['rejectionReason']?.toString(),
            createdAt: data['createdAt']?.toString() ?? 'Vừa xong',
          );
        }).toList();
      }
    } catch (e) {
      // Return empty list if network error
    }
    return [];
  }

  // Real Backend NestJS + Firestore DB API Call for PM Checklists
  Future<List<PMChecklistModel>> fetchPMChecklistsFromApi() async {
    try {
      final response = await _dio.get<List<dynamic>>('/machines/pm-checklists');
      if (response.data != null) {
        return response.data!.map((item) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(item as Map);

          PMChecklistStatus status = PMChecklistStatus.pending;
          final statusStr = data['status']?.toString().toUpperCase();
          if (statusStr == 'IN_PROGRESS') {
            status = PMChecklistStatus.inProgress;
          } else if (statusStr == 'COMPLETED') {
            status = PMChecklistStatus.completed;
          } else if (statusStr == 'APPROVED') {
            status = PMChecklistStatus.approved;
          }

          return PMChecklistModel(
            id: data['id']?.toString() ?? '',
            code: data['code']?.toString() ?? 'PM-001',
            machineId: data['machineId']?.toString() ?? '',
            machineName: data['machineName']?.toString() ?? 'Thiết bị nhà máy',
            scheduledHours: (data['scheduledHours'] as num?)?.toInt() ?? 500,
            status: status,
            itemCount: (data['itemCount'] as num?)?.toInt() ?? 6,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  // Update WorkOrder Status in NestJS Backend + Firestore DB
  Future<bool> updateWorkOrderStatus(String workOrderId, String status) async {
    try {
      await _dio.patch(
        '/machines/work-orders/$workOrderId/status',
        data: {'status': status},
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
