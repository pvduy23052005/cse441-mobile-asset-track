import 'package:dio/dio.dart';
import '../../../../core/models/machine_model.dart';
import '../../../../core/network/api_client.dart';

class MachineService {
  final Dio _dio = ApiClient.instance;

  Future<List<MachineModel>> getMachines() async {
    try {
      final response = await _dio.get<List<dynamic>>('/supervisor/machines');
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
      final response =
          await _dio.get<Map<String, dynamic>>('/machines/$id');
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

  Future<Map<String, dynamic>> getMachineQrCode(String id) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/supervisor/machines/$id/qrcode');
      if (response.data != null) {
        return Map<String, dynamic>.from(response.data!);
      }
      throw Exception('Không nhận được dữ liệu mã QR');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể tạo mã QR cho thiết bị');
    } catch (e) {
      throw Exception('Lỗi khi sinh mã QR: $e');
    }
  }

  Future<MachineModel> updateMachineStatus(String id, String status) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/machines/$id/status',
        data: {'status': status.toUpperCase()},
      );
      if (response.data != null) {
        return MachineModel.fromJson(response.data!);
      }
      throw Exception('Không nhận được dữ liệu phản hồi');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể cập nhật trạng thái thiết bị');
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái: $e');
    }
  }

  Future<MachineModel> updateMachine(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/machines/$id',
        data: data,
      );
      if (response.data != null) {
        return MachineModel.fromJson(response.data!);
      }
      throw Exception('Không nhận được dữ liệu phản hồi');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể cập nhật thông tin thiết bị');
    } catch (e) {
      throw Exception('Lỗi khi cập nhật máy móc: $e');
    }
  }

  Future<List<MachineOperatorModel>> getOperators() async {
    try {
      final response =
          await _dio.get<List<dynamic>>('/supervisor/operators');
      if (response.data != null) {
        return response.data!
            .map((item) => MachineOperatorModel.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể tải danh sách người vận hành');
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách Operator: $e');
    }
  }

  Future<MachineModel> assignOperator(
      String machineId, String operatorId) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/supervisor/machines/$machineId/assign-operator',
        data: {'operator_id': operatorId},
      );
      if (response.data != null) {
        return MachineModel.fromJson(response.data!);
      }
      throw Exception('Không nhận được dữ liệu sau khi phân công');
    } on DioException catch (e) {
      throw Exception(
          e.error ?? 'Không thể phân công người vận hành cho thiết bị');
    } catch (e) {
      throw Exception('Lỗi khi phân công Operator: $e');
    }
  }
}
