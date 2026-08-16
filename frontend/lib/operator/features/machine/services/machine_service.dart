import 'package:dio/dio.dart';
import '../../../../core/models/machine_model.dart';
import '../../../../core/network/api_client.dart';

class MachineService {
  final Dio _dio = ApiClient.instance;

  Future<List<MachineModel>> getMachines() async {
    try {
      final response = await _dio.get<List<dynamic>>('/machines');
      if (response.data != null) {
        return response.data!
            .map((item) =>
                MachineModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể tải danh sách máy móc');
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách máy móc: $e');
    }
  }

  Future<MachineModel> getMachineById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/machines/$id');
      if (response.data != null) {
        return MachineModel.fromJson(response.data!);
      }
      throw Exception('Không tìm thấy thông tin thiết bị');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể tải thông tin thiết bị');
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin máy móc: $e');
    }
  }

  Future<MachineModel> updateRunningHours(
    String id,
    double runningHours, {
    String? shift,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/machines/$id/running-hours',
        data: {
          'running_hours': runningHours,
          'shift': ?shift,
        },
      );
      if (response.data != null) {
        return MachineModel.fromJson(response.data!);
      }
      throw Exception('Cập nhật giờ máy chạy thất bại');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể cập nhật giờ máy chạy');
    } catch (e) {
      throw Exception('Lỗi khi cập nhật giờ máy chạy: $e');
    }
  }
}
