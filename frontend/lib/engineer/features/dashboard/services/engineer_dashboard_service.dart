import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/network/api_client.dart';
import '../models/work_order_model.dart';

class EngineerDashboardService {
  final Dio _dio = ApiClient.instance;

  Stream<List<WorkOrderModel>> streamWorkOrders() {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance
            .collection('tickets')
            .snapshots()
            .map((snapshot) {
          final list = snapshot.docs.map((doc) {
            final Map<String, dynamic> data = doc.data();

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
            } else if (statusStr == 'COMPLETED' || statusStr == 'PENDING_APPROVAL') {
              status = WorkOrderStatus.completed;
            } else if (statusStr == 'APPROVED' || statusStr == 'CLOSED') {
              status = WorkOrderStatus.approved;
            } else if (statusStr == 'REJECTED') {
              status = WorkOrderStatus.rejected;
            } else if (statusStr == 'CANCELLED') {
              status = WorkOrderStatus.cancelled;
            }

            String? imgUrl = data['imageUrl']?.toString();
            if (imgUrl == null && data['images_urls'] != null && (data['images_urls'] as List).isNotEmpty) {
              imgUrl = (data['images_urls'] as List).first.toString();
            }

            final String ticketId = doc.id;
            final String code = data['code']?.toString() ??
                (ticketId.length > 6 ? 'SOS-${ticketId.substring(0, 6).toUpperCase()}' : 'SOS-$ticketId');

            return WorkOrderModel(
              id: ticketId,
              code: code.isEmpty ? 'SOS-001' : code,
              machineId: data['machine_id']?.toString() ?? data['machineId']?.toString() ?? '',
              machineName: data['machine_name']?.toString() ?? data['machineName']?.toString() ?? 'Thiết bị nhà máy',
              severity: severity,
              status: status,
              description: data['description']?.toString() ?? '',
              imageUrl: imgUrl,
              assigneeName: data['engineer_name']?.toString() ?? data['assigneeName']?.toString(),
              rejectionReason: data['rejection_reason']?.toString() ?? data['rejectionReason']?.toString(),
              createdAt: data['created_at']?.toString() ?? data['createdAt']?.toString() ?? 'Vừa xong',
            );
          }).toList();

          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
      }
    } catch (_) {}
    return const Stream.empty();
  }

  Future<List<WorkOrderModel>> fetchWorkOrdersFromApi() async {
    try {
      final response = await _dio.get<List<dynamic>>('/tickets');
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
          } else if (statusStr == 'COMPLETED' || statusStr == 'PENDING_APPROVAL') {
            status = WorkOrderStatus.completed;
          } else if (statusStr == 'APPROVED' || statusStr == 'CLOSED') {
            status = WorkOrderStatus.approved;
          } else if (statusStr == 'REJECTED') {
            status = WorkOrderStatus.rejected;
          } else if (statusStr == 'CANCELLED') {
            status = WorkOrderStatus.cancelled;
          }

          // Handle image_url or images_urls array
          String? imgUrl = data['imageUrl']?.toString();
          if (imgUrl == null && data['images_urls'] != null && (data['images_urls'] as List).isNotEmpty) {
            imgUrl = (data['images_urls'] as List).first.toString();
          }

          final String ticketId = data['id']?.toString() ?? '';
          final String code = data['code']?.toString() ??
              (ticketId.length > 6 ? 'SOS-${ticketId.substring(0, 6).toUpperCase()}' : 'SOS-$ticketId');

          return WorkOrderModel(
            id: ticketId,
            code: code.isEmpty ? 'SOS-001' : code,
            machineId: data['machine_id']?.toString() ?? data['machineId']?.toString() ?? '',
            machineName: data['machine_name']?.toString() ?? data['machineName']?.toString() ?? 'Thiết bị nhà máy',
            severity: severity,
            status: status,
            description: data['description']?.toString() ?? '',
            imageUrl: imgUrl,
            assigneeName: data['engineer_name']?.toString() ?? data['assigneeName']?.toString(),
            rejectionReason: data['rejection_reason']?.toString() ?? data['rejectionReason']?.toString(),
            createdAt: data['created_at']?.toString() ?? data['createdAt']?.toString() ?? 'Vừa xong',
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
            machineId: data['machineId']?.toString() ?? data['machine_id']?.toString() ?? '',
            machineName: data['machineName']?.toString() ?? data['machine_name']?.toString() ?? 'Thiết bị nhà máy',
            scheduledHours: (data['scheduledHours'] as num?)?.toInt() ?? 500,
            status: status,
            itemCount: (data['itemCount'] as num?)?.toInt() ?? 6,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  // Claim Ticket in NestJS Backend (/tickets/:id/claim)
  Future<bool> updateWorkOrderStatus(String ticketId, String status) async {
    try {
      if (status.toUpperCase() == 'IN_PROGRESS') {
        await _dio.patch('/tickets/$ticketId/claim');
      } else if (status.toUpperCase() == 'COMPLETED') {
        await _dio.patch('/tickets/$ticketId/complete');
      } else {
        await _dio.patch('/tickets/$ticketId/claim');
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
