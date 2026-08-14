import 'package:flutter/material.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_service.dart';
import '../../core/widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/widgets/operator_dashboard_view.dart';
import '../features/machine/widgets/operator_machine_view.dart';
import '../features/checklist/widgets/operator_checklist_view.dart';
import '../features/history/widgets/operator_history_view.dart';
import '../widgets/operator_bottom_nav_bar.dart';
import '../widgets/operator_qr_scanner_sheet.dart';
import '../features/machine/widgets/machine_detail_modal.dart';

class OperatorMainScreen extends StatefulWidget {
  final int initialIndex;
  const OperatorMainScreen({super.key, this.initialIndex = 0});

  @override
  State<OperatorMainScreen> createState() => _OperatorMainScreenState();
}

class _OperatorMainScreenState extends State<OperatorMainScreen> {
  late int _currentIndex;

  final List<Widget> _views = const [
    OperatorDashboardView(),
    OperatorMachineView(),
    OperatorChecklistView(),
    OperatorHistoryView(),
  ];

  final List<String> _titles = const [
    'Trang Chủ',
    'Máy Móc',
    'Nhiệm Vụ',
    'Thông Báo',
  ];

  final int _pendingTasksCount = 2;
  final int _unreadNotificationsCount = 2;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _openQRScannerModal() async {
    final machine = await OperatorQRScannerSheet.show(context);
    if (machine != null && mounted) {
      MachineDetailModal.show(context, machine);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = StorageService.getUserProfile();
    final displayName = userProfile['fullName'];
    final displayEmail = userProfile['email'];

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => setState(() => _currentIndex = 3),
          ),
        ],
      ),
      drawer: AppDrawer(
        userName: displayName,
        userEmail: displayEmail,
        roleLabel: 'Tổ Vận Hành Máy',
        roleBadge: 'OPERATOR',
        roleColor: AppTheme.primaryColor,
        toolNavItems: [
          DrawerMenuItem(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Quét Mã QR Thiết Bị',
            onTap: () {
              Navigator.pop(context);
              _openQRScannerModal();
            },
          ),
          DrawerMenuItem(
            icon: Icons.manage_search_rounded,
            title: 'Tra Cứu Thiết Bị',
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.assetLookup);
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _views),
      bottomNavigationBar: OperatorBottomNavBar(
        currentIndex: _currentIndex,
        pendingTasksCount: _pendingTasksCount,
        unreadNotificationsCount: _unreadNotificationsCount,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        onQRTapped: _openQRScannerModal,
      ),
    );
  }
}
