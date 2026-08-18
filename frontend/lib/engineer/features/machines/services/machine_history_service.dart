import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/engineer/features/ticket_management/models/ticket_model.dart';

class MachineHistoryService {
  final Dio _dio = ApiClient.instance;

  /// Lấy danh sách lịch sử bảo trì (tất cả phiếu) của một máy theo machine_id
  Future<List<TicketModel>> fetchHistoryForMachine(String machineId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/tickets',
        queryParameters: {'machine_id': machineId},
      );
      if (response.data != null) {
        final all = response.data!
            .map((item) =>
                TicketModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();

        // Lọc ra chỉ những phiếu đã đóng/nghiệm thu, từ chối, và chờ nghiệm thu
        // (tức là các phiếu đã qua giai đoạn sửa chữa)
        return all.where((t) {
          return t.status == TicketStatus.closed ||
              t.status == TicketStatus.rejected ||
              t.status == TicketStatus.pendingApproval;
        }).toList();
      }
    } catch (_) {}
    return [];
  }
}
