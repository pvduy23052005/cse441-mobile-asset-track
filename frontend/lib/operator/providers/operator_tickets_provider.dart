import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/ticket/services/operator_ticket_service.dart';

final operatorTicketServiceProvider = Provider<OperatorTicketService>((ref) {
  return OperatorTicketService();
});

class OperatorTicketsNotifier
    extends AutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _fetchTickets();
  }

  Future<List<Map<String, dynamic>>> _fetchTickets() async {
    final service = ref.read(operatorTicketServiceProvider);
    return service.getMyTickets();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTickets());
  }

  Future<Map<String, dynamic>> createTicket({
    required String machineId,
    required String description,
    required String severity,
    List<String>? imagesUrls,
    String? downtimeStart,
  }) async {
    final service = ref.read(operatorTicketServiceProvider);
    final result = await service.createTicket(
      machineId: machineId,
      description: description,
      severity: severity,
      imagesUrls: imagesUrls,
      downtimeStart: downtimeStart,
    );

    // Tự động làm mới danh sách phiếu sau khi tạo thành công
    await refresh();
    return result;
  }

  Future<Map<String, dynamic>> cancelTicket(String id, {String? reason}) async {
    final service = ref.read(operatorTicketServiceProvider);
    final result = await service.cancelTicket(id, reason: reason);

    // Tự động làm mới danh sách phiếu sau khi hủy
    await refresh();
    return result;
  }
}

final operatorTicketsProvider = AsyncNotifierProvider.autoDispose<
    OperatorTicketsNotifier, List<Map<String, dynamic>>>(() {
  return OperatorTicketsNotifier();
});
