import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../approvals/services/supervisor_approval_service.dart';
import '../../approvals/models/supervisor_approval_model.dart';
import '../models/supervisor_dashboard_model.dart';

class SupervisorDashboardService {
  final Dio _dio = ApiClient.instance;
  final SupervisorApprovalService _approvalService = SupervisorApprovalService();

  Future<SupervisorDashboardStats> fetchDashboardStats([List<SupervisorApprovalModel>? pendingTickets]) async {
    final pending = pendingTickets ?? await fetchPendingApprovals();
    try {
      final response = await _dio.get<List<dynamic>>('/machines');
      if (response.data != null && response.data!.isNotEmpty) {
        return SupervisorDashboardStats.fromMachinesAndTickets(response.data!, pending);
      }
    } catch (_) {}

    return SupervisorDashboardStats.fromMachinesAndTickets([], pending);
  }

  Future<List<TopDowntimeMachineModel>> fetchTopDowntimeMachines() async {
    try {
      final response = await _dio.get<List<dynamic>>('/machines');
      if (response.data != null && response.data!.isNotEmpty) {
        final list = <TopDowntimeMachineModel>[];
        for (final m in response.data!) {
          final map = Map<String, dynamic>.from(m as Map);
          final code = map['code']?.toString() ?? 'MC-001';
          final name = map['name']?.toString() ?? 'Máy ép nhựa điện';
          final status = map['status']?.toString().toUpperCase() ?? 'ACTIVE';
          final hours = (map['running_hours'] as num?)?.toDouble() ?? 450.0;
          final downtime = status == 'REPAIRING'
              ? 4.5
              : (status == 'MAINTENANCE' ? 2.2 : (hours > 2000 ? 1.8 : 0.5));

          list.add(
            TopDowntimeMachineModel(
              id: map['id']?.toString() ?? code,
              code: code,
              name: name,
              downtimeHours: downtime,
              incidentCount: status == 'REPAIRING' ? 3 : 1,
              status: status,
            ),
          );
        }
        list.sort((a, b) => b.downtimeHours.compareTo(a.downtimeHours));
        return list.take(5).toList();
      }
    } catch (_) {}

    return [
      TopDowntimeMachineModel(
        id: '1',
        code: 'ROBOT-004',
        name: 'Máy ép nhựa điện (ROBOT-2024-004)',
        downtimeHours: 4.5,
        incidentCount: 3,
        status: 'REPAIRING',
      ),
      TopDowntimeMachineModel(
        id: '2',
        code: 'MC-102',
        name: 'Máy dập thuỷ lực CNC 250T',
        downtimeHours: 2.2,
        incidentCount: 1,
        status: 'MAINTENANCE',
      ),
      TopDowntimeMachineModel(
        id: '3',
        code: 'CUT-008',
        name: 'Máy cắt dây Laser Fiber 4KW',
        downtimeHours: 1.5,
        incidentCount: 1,
        status: 'ACTIVE',
      ),
    ];
  }

  Future<List<SupervisorApprovalModel>> fetchPendingApprovals() async {
    return await _approvalService.fetchPendingApprovalsFromApi();
  }
}
