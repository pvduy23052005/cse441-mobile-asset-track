import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/offline/repositories/offline_ticket_repository.dart';
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
    final offlineRepo = ref.read(offlineTicketRepositoryProvider);
    return offlineRepo.getTicketsOfflineFirst();
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    if (previous != null) {
      state = AsyncValue.data(previous);
    }
    state = await AsyncValue.guard(() => _fetchTickets());
  }

  Future<Map<String, dynamic>> createTicket({
    required String machineId,
    String? machineName,
    String? machineCode,
    required String description,
    required String severity,
    List<XFile> imageFiles = const [],
    String? downtimeStart,
  }) async {
    final offlineRepo = ref.read(offlineTicketRepositoryProvider);
    final localTicket = await offlineRepo.createTicketOfflineFirst(
      machineId: machineId,
      machineName: machineName,
      machineCode: machineCode,
      description: description,
      severity: severity,
      imageFiles: imageFiles,
      downtimeStart: downtimeStart,
    );

    await refresh();
    return localTicket.toDashboardTicketJson();
  }

  Future<void> deleteTicket(String id, {bool isLocal = false}) async {
    final offlineRepo = ref.read(offlineTicketRepositoryProvider);
    await offlineRepo.deleteTicketOfflineFirst(id, isLocal: isLocal);
    await refresh();
  }

  Future<void> cancelTicket(String id, {String? reason, bool isLocal = false}) async {
    return deleteTicket(id, isLocal: isLocal);
  }
}

final operatorTicketsProvider =
    AsyncNotifierProvider.autoDispose<
      OperatorTicketsNotifier,
      List<Map<String, dynamic>>
    >(() {
      return OperatorTicketsNotifier();
    });
