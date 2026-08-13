import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/machine_model.dart';

class EngineerMachineService {
  final Dio _dio = ApiClient.instance;

  Future<List<MachineModel>> fetchMachinesFromApi() async {
    try {
      final response = await _dio.get<List<dynamic>>('/machines');
      if (response.data != null) {
        return response.data!
            .map((item) => MachineModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
