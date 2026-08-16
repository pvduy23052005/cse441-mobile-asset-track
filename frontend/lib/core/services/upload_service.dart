import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../network/api_client.dart';

final uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService();
});

class UploadService {
  final Dio _dio = ApiClient.instance;

  Future<String> uploadImage(
    dynamic file, {
    String folder = 'tickets',
  }) async {
    try {
      String filePath;
      String fileName;

      if (file is XFile) {
        filePath = file.path;
        fileName = file.name;
      } else if (file is File) {
        filePath = file.path;
        fileName = file.path.split(Platform.pathSeparator).last;
      } else if (file is String) {
        filePath = file;
        fileName = file.split(Platform.pathSeparator).last;
      } else {
        throw Exception('Định dạng file không được hỗ trợ');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/upload',
        queryParameters: {'folder': folder},
        data: formData,
      );

      if (response.data != null && response.data!['url'] != null) {
        return response.data!['url'].toString();
      }
      throw Exception('Không nhận được đường dẫn ảnh từ máy chủ');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Lỗi khi tải ảnh lên máy chủ');
    } catch (e) {
      throw Exception('Lỗi upload ảnh: $e');
    }
  }

  Future<List<String>> uploadMultipleImages(
    List<dynamic> files, {
    String folder = 'tickets',
  }) async {
    if (files.isEmpty) return [];

    final uploadFutures = files.map((file) => uploadImage(file, folder: folder));
    return Future.wait(uploadFutures);
  }
}
