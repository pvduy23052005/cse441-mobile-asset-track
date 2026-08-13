import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/ticket_model.dart';

class EngineerTicketService {
  final Dio _dio = ApiClient.instance;

  Future<List<TicketModel>> fetchTicketsFromApi() async {
    try {
      final response = await _dio.get<List<dynamic>>('/tickets');
      if (response.data != null) {
        return response.data!
            .map((item) => TicketModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<TicketModel?> claimTicket(String id) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>('/tickets/$id/claim');
      if (response.data != null) {
        return TicketModel.fromJson(Map<String, dynamic>.from(response.data!));
      }
    } catch (_) {}
    return null;
  }

  Future<TicketModel?> completeTicket(String id, {List<SparePartItem>? usedParts}) async {
    try {
      final payload = {
        'used_spare_parts': usedParts?.map((p) => p.toJson()).toList() ?? [],
      };
      final response = await _dio.patch<Map<String, dynamic>>(
        '/tickets/$id/complete',
        data: payload,
      );
      if (response.data != null) {
        return TicketModel.fromJson(Map<String, dynamic>.from(response.data!));
      }
    } catch (_) {}
    return null;
  }
}
