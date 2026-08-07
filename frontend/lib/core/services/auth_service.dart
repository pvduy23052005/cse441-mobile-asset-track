import 'package:dio/dio.dart';
import '../network/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password.trim(),
        },
      );

      if (response.data != null) {
        return response.data!;
      } else {
        throw Exception('Không nhận được dữ liệu từ hệ thống');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Đăng nhập thất bại');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }
}
