import 'package:flutter/material.dart';
import '../models/supervisor_dashboard_model.dart';
import '../services/supervisor_dashboard_service.dart';
import 'header/supervisor_header_bar.dart';
import 'cards/supervisor_kpi_cards.dart';
import 'cards/machine_status_distribution_card.dart';
import 'cards/pending_approvals_quick_card.dart';
import 'cards/top_downtime_machines_card.dart';
import '../../approvals/models/supervisor_approval_model.dart';
import '../../approvals/widgets/supervisor_digital_signoff_modal.dart';
import '../../machine_management/widgets/add_machine_modal.dart';
import '../../../../core/utils/storage_service.dart';

class SupervisorDashboardView extends StatefulWidget {
  const SupervisorDashboardView({super.key});

  @override
  State<SupervisorDashboardView> createState() =>
      _SupervisorDashboardViewState();
}

class _SupervisorDashboardViewState extends State<SupervisorDashboardView> {
  final SupervisorDashboardService _service = SupervisorDashboardService();

  SupervisorDashboardStats _stats = SupervisorDashboardStats(
    totalMachines: 12,
    activeCount: 9,
    repairingCount: 2,
    maintenanceCount: 1,
    stoppedCount: 0,
  );
  List<TopDowntimeMachineModel> _topMachines = [];
  List<SupervisorApprovalModel> _pendingApprovals = [];
  bool _isLoading = true;
  SupervisorTimeFilter _selectedFilter = SupervisorTimeFilter.today;
  double _costThreshold = 2000000.0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final pendingData = await _service.fetchPendingApprovals();
      final statsData = await _service.fetchDashboardStats(pendingData);
      final topData = await _service.fetchTopDowntimeMachines();

      if (mounted) {
        setState(() {
          _stats = statsData;
          _topMachines = topData;
          _pendingApprovals = pendingData;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openSignoffModal(SupervisorApprovalModel item) {
    SupervisorDigitalSignoffModal.show(
      context,
      item: item,
      onConfirmSign: (sig) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã ký nghiệm thu thành công phiếu ${item.code}!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        _loadDashboardData();
      },
      onReject: (reason) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã từ chối phiếu ${item.code}. Lý do: $reason'),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
        _loadDashboardData();
      },
    );
  }

  void _openAddMachineModal() {
    AddMachineModal.show(
      context,
      onAddMachine: (map) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm thiết bị mới thành công!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        _loadDashboardData();
      },
    );
  }

  void _openThresholdConfigModal() {
    final controller = TextEditingController(
        text: _costThreshold.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.tune_rounded, color: Color(0xFF0284C7)),
            SizedBox(width: 8),
            Text('Cấu Hình Ngưỡng Duyệt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập hạn mức chi phí linh kiện bắt buộc Quản đốc duyệt (VNĐ):',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'VD: 2000000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixText: 'VNĐ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 2000000.0;
              setState(() => _costThreshold = val);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Đã cập nhật ngưỡng duyệt chi phí linh kiện: ${val.toStringAsFixed(0)}đ'),
                  backgroundColor: const Color(0xFF059669),
                ),
              );
            },
            child: const Text('Lưu Cấu Hình'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0284C7),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: const Color(0xFF0284C7),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Bar
            SupervisorHeaderBar(
              supervisorName: StorageService.getUserFullName()?.isNotEmpty == true
                  ? StorageService.getUserFullName()!
                  : 'Quản Đốc Phân Xưởng',
              workshopName: 'WS-01 (Phân Xưởng Chế Tạo)',
              thresholdAmount: _costThreshold,
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() => _selectedFilter = filter);
                _loadDashboardData();
              },
              onOpenAddMachine: _openAddMachineModal,
              onOpenThresholdConfig: _openThresholdConfigModal,
            ),
            const SizedBox(height: 12),

            // 2. Native Mobile KPI Cards
            SupervisorKpiCards(stats: _stats),
            const SizedBox(height: 12),

            // 3. Machine Status Distribution Progress Bars
            MachineStatusDistributionCard(stats: _stats),
            const SizedBox(height: 12),

            // 4. Feed: Pending Sign-offs & Approval Items
            PendingApprovalsQuickCard(
              pendingItems: _pendingApprovals,
              onRefresh: _loadDashboardData,
              onOpenSignoff: _openSignoffModal,
            ),
            const SizedBox(height: 12),

            // 5. Top Downtime Machines Table Ranking
            TopDowntimeMachinesCard(topMachines: _topMachines),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
