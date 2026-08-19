import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/machine_model.dart';
import '../features/machine/services/machine_service.dart';

final machineServiceProvider = Provider<MachineService>((ref) {
  return MachineService();
});

class OperatorMachinesNotifier
    extends AutoDisposeAsyncNotifier<List<MachineModel>> {
  @override
  Future<List<MachineModel>> build() async {
    return _fetchMachines();
  }

  Future<List<MachineModel>> _fetchMachines() async {
    final service = ref.read(machineServiceProvider);
    return service.getMachines();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMachines());
  }
}

final operatorMachinesProvider =
    AsyncNotifierProvider.autoDispose<
      OperatorMachinesNotifier,
      List<MachineModel>
    >(() {
      return OperatorMachinesNotifier();
    });

final operatorMachineSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final filteredOperatorMachinesProvider =
    Provider.autoDispose<AsyncValue<List<MachineModel>>>((ref) {
      final query = ref.watch(operatorMachineSearchQueryProvider).toLowerCase();
      final machinesAsync = ref.watch(operatorMachinesProvider);

      return machinesAsync.whenData((machines) {
        if (query.isEmpty) return machines;
        return machines.where((machine) {
          final name = machine.name.toLowerCase();
          final code = machine.code.toLowerCase();
          final location = machine.location.toLowerCase();
          return name.contains(query) ||
              code.contains(query) ||
              location.contains(query);
        }).toList();
      });
    });
