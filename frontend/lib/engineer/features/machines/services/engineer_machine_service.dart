import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/offline/repositories/offline_engineer_repository.dart';
import '../models/machine_model.dart';

class EngineerMachineService {
  final OfflineEngineerRepository _offlineRepo;

  EngineerMachineService([OfflineEngineerRepository? repo])
      : _offlineRepo = repo ??
            OfflineEngineerRepository(
              ProviderContainer(),
              ApiClient.instance,
            );

  Future<List<MachineModel>> fetchMachinesFromApi() async {
    return _offlineRepo.getMachinesOfflineFirst();
  }

  Future<MachineModel?> fetchMachineById(String id) async {
    final machines = await _offlineRepo.getMachinesOfflineFirst();
    final match = machines.where((m) => m.id == id);
    if (match.isNotEmpty) return match.first;
    return null;
  }
  Future<bool> updateTroubleshooting(String machineId, List<TroubleshootingItem> items) async {
    return _offlineRepo.updateTroubleshootingOfflineFirst(machineId, items);
  }
}
