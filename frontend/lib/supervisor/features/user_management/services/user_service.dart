import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class UserService {
  final Dio _dio = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await _dio.get<List<dynamic>>('/users');
      if (response.data != null) {
        return response.data!.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể tải danh sách người dùng');
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách người dùng: $e');
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String email,
    required String fullName,
    required String role,
    String? password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/users',
        data: {
          'email': email.trim().toLowerCase(),
          'fullName': fullName.trim(),
          'role': role.trim().toLowerCase(),
          if (password != null && password.isNotEmpty) 'password': password.trim(),
        },
      );

      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Không nhận được phản hồi từ hệ thống');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể tạo tài khoản người dùng');
    } catch (e) {
      throw Exception('Lỗi khi tạo người dùng: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete('/users/$id');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không thể xóa tài khoản người dùng');
    } catch (e) {
      throw Exception('Lỗi khi xóa người dùng: $e');
    }
  }
}
