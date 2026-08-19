import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class OperatorTicketService {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> createTicket({
    required String machineId,
    required String description,
    required String severity,
    List<String>? imagesUrls,
    String? downtimeStart,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'machine_id': machineId,
        'description': description,
        'severity': severity.toUpperCase(),
      };

      if (imagesUrls != null && imagesUrls.isNotEmpty) {
        requestData['images_urls'] = imagesUrls;
      }
      if (downtimeStart != null) {
        requestData['downtime_start'] = downtimeStart;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/operator/tickets',
        data: requestData,
      );

      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Không nhận được phản hồi từ máy chủ');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể tạo phiếu báo cáo sự cố');
    } catch (e) {
      throw Exception('Lỗi khi tạo phiếu sự cố: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMyTickets() async {
    try {
      final response = await _dio.get<List<dynamic>>('/operator/tickets');
      if (response.data != null) {
        return response.data!
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể tải danh sách phiếu của bạn');
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách phiếu: $e');
    }
  }

  Future<Map<String, dynamic>> getTicketById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/operator/tickets/$id',
      );
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Không tìm thấy thông tin phiếu sự cố');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể tải thông tin phiếu sự cố');
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin phiếu sự cố: $e');
    }
  }

  Future<Map<String, dynamic>> deleteTicket(String id) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/operator/tickets/$id',
      );
      if (response.data != null) {
        return response.data!;
      }
      return {'success': true};
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể xóa phiếu sự cố');
    } catch (e) {
      throw Exception('Lỗi khi xóa phiếu sự cố: $e');
    }
  }

  Future<Map<String, dynamic>> cancelTicket(String id, {String? reason}) async {
    return deleteTicket(id);
  }
}
