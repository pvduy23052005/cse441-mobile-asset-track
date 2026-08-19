class SupervisorDashboardStats {
  final int totalMachines;
  final int activeCount;
  final int repairingCount;
  final int maintenanceCount;
  final int stoppedCount;
  final double oeePercentage;
  final double totalDowntimeHours;

  SupervisorDashboardStats({
    required this.totalMachines,
    required this.activeCount,
    required this.repairingCount,
    required this.maintenanceCount,
    required this.stoppedCount,
    this.oeePercentage = 94.2,
    this.totalDowntimeHours = 0.0,
  });

  int get activePercent =>
      totalMachines > 0 ? ((activeCount / totalMachines) * 100).round() : 0;
  int get repairingPercent =>
      totalMachines > 0 ? ((repairingCount / totalMachines) * 100).round() : 0;
  int get maintenancePercent => totalMachines > 0
      ? ((maintenanceCount / totalMachines) * 100).round()
      : 0;
  int get stoppedPercent => totalMachines > 0
      ? ((stoppedCount / totalMachines) * 100).round()
      : 0;

  factory SupervisorDashboardStats.fromMachinesAndTickets(
    List<dynamic> machines,
    List<dynamic> pendingTickets,
  ) {
    // Collect unique machine identifiers for SOS breakdown and PM maintenance
    final Set<String> sosMachineIds = {};
    final Set<String> pmMachineIds = {};

    for (final t in pendingTickets) {
      dynamic code = '';
      dynamic title = '';
      dynamic machineCode = '';
      dynamic machineId = '';
      try {
        code = t.code;
        title = t.title;
        machineCode = t.machineCode;
        machineId = t.machineId;
      } catch (_) {
        code = t['code'];
        title = t['title'];
        machineCode = t['machineCode'] ?? t['machine_code'];
        machineId = t['machineId'] ?? t['machine_id'];
      }

      final cStr = (code ?? '').toString().toUpperCase();
      final tStr = (title ?? '').toString().toUpperCase();
      final mCodeStr = (machineCode ?? '').toString().toUpperCase();
      final mIdStr = (machineId ?? '').toString().toUpperCase();

      final isPM = cStr.startsWith('PM') || tStr.contains('PM') || tStr.contains('BẢO TRÌ');
      if (isPM) {
        if (mCodeStr.isNotEmpty) pmMachineIds.add(mCodeStr);
        if (mIdStr.isNotEmpty) pmMachineIds.add(mIdStr);
      } else {
        if (mCodeStr.isNotEmpty) sosMachineIds.add(mCodeStr);
        if (mIdStr.isNotEmpty) sosMachineIds.add(mIdStr);
      }
    }

    int active = 0;
    int repairing = 0;
    int maintenance = 0;
    int stopped = 0;

    if (machines.isNotEmpty) {
      for (final m in machines) {
        dynamic mCode = '';
        dynamic mId = '';
        dynamic dbStatus = '';
        try {
          mCode = m.code;
          mId = m.id;
          dbStatus = m.status;
        } catch (_) {
          mCode = m['code'];
          mId = m['id'];
          dbStatus = m['status'];
        }
        final codeStr = (mCode ?? '').toString().toUpperCase();
        final idStr = (mId ?? '').toString().toUpperCase();
        final statusStr = (dbStatus ?? '').toString().toUpperCase();

        final isSos = (codeStr.isNotEmpty && sosMachineIds.contains(codeStr)) ||
            (idStr.isNotEmpty && sosMachineIds.contains(idStr)) ||
            statusStr == 'REPAIRING' ||
            statusStr == 'FAILED' ||
            statusStr == 'SOS';

        final isPm = (codeStr.isNotEmpty && pmMachineIds.contains(codeStr)) ||
            (idStr.isNotEmpty && pmMachineIds.contains(idStr)) ||
            statusStr == 'MAINTENANCE' ||
            statusStr == 'PM';

        if (isSos) {
          repairing++;
        } else if (isPm) {
          maintenance++;
        } else if (statusStr == 'STOPPED' || statusStr == 'INACTIVE' || statusStr == 'DISABLED') {
          stopped++;
        } else {
          active++;
        }
      }
    } else {
      repairing = sosMachineIds.length;
      maintenance = pmMachineIds.where((id) => !sosMachineIds.contains(id)).length;
      active = 0;
      stopped = 0;
    }

    final total = machines.isEmpty ? (repairing + maintenance + stopped) : machines.length;
    final realTotal = total == 0 ? 1 : total;

    return SupervisorDashboardStats(
      totalMachines: realTotal,
      activeCount: active,
      repairingCount: repairing,
      maintenanceCount: maintenance,
      stoppedCount: stopped,
      oeePercentage: realTotal > 0 ? (90.0 + (active / realTotal) * 9.5) : 94.2,
      totalDowntimeHours: (repairing * 2.5) + (maintenance * 1.5),
    );
  }

  factory SupervisorDashboardStats.fromMachines(List<dynamic> machines) {
    return SupervisorDashboardStats.fromMachinesAndTickets(machines, []);
  }
}

class TopDowntimeMachineModel {
  final String id;
  final String code;
  final String name;
  final double downtimeHours;
  final int incidentCount;
  final String status;

  TopDowntimeMachineModel({
    required this.id,
    required this.code,
    required this.name,
    required this.downtimeHours,
    required this.incidentCount,
    required this.status,
  });
}

class PendingSignoffItemModel {
  final String id;
  final String code;
  final String title;
  final String machineCode;
  final String machineName;
  final String engineerName;
  final String downtimeDuration;
  final String type; // 'SOS' | 'PM'
  final String status; // 'COMPLETED', 'PENDING_APPROVAL'
  final bool requiresHighCostApproval;
  final double totalPartsCost;

  PendingSignoffItemModel({
    required this.id,
    required this.code,
    required this.title,
    required this.machineCode,
    required this.machineName,
    required this.engineerName,
    required this.downtimeDuration,
    required this.type,
    required this.status,
    this.requiresHighCostApproval = false,
    this.totalPartsCost = 0.0,
  });
}
