import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiClient.baseUrl}/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password.trim(),
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        final message = data['message'] ?? 'Đăng nhập thất bại';
        throw Exception(
          message is List ? message.join(', ') : message.toString(),
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Không thể kết nối đến máy chủ: $e');
    }
  }
}
