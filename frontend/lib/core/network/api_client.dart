import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  static final Dio _dio = _createDioInstance();
  static Dio get instance => _dio;

  static Dio _createDioInstance() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          String errorMessage = 'Không thể kết nối đến máy chủ';

          if (e.response != null) {
            final data = e.response?.data;
            if (data is Map && data['message'] != null) {
              final message = data['message'];
              errorMessage =
                  message is List ? message.join(', ') : message.toString();
            } else {
              errorMessage = 'Lỗi hệ thống (${e.response?.statusCode})';
            }
          }

          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: errorMessage,
              response: e.response,
              type: e.type,
            ),
          );
        },
      ),
    );

    return dio;
  }
}
