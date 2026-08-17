import '../../../../core/network/api_client.dart';
import '../../../../core/offline/repositories/offline_engineer_repository.dart';
import '../models/ticket_model.dart';

class EngineerTicketService {
  final OfflineEngineerRepository _offlineRepo;

  EngineerTicketService([OfflineEngineerRepository? repo])
      : _offlineRepo = repo ??
            OfflineEngineerRepository(
              ApiClient.instance,
            );

  Future<List<TicketModel>> fetchTicketsFromApi() async {
    return _offlineRepo.getTicketsOfflineFirst();
  }

  Future<TicketModel?> claimTicket(String id) async {
    return _offlineRepo.claimTicketOfflineFirst(id);
  }

  Future<TicketModel?> completeTicket(String id, {List<SparePartItem>? usedParts}) async {
    return _offlineRepo.completeTicketOfflineFirst(id, usedParts: usedParts);
  }
}
