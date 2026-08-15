import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_service.dart';
import '../../core/widgets/app_drawer.dart';
import '../features/checklist/widgets/operator_checklist_view.dart';
import '../features/dashboard/widgets/operator_dashboard_view.dart';
import '../features/machine/widgets/machine_detail_modal.dart';
import '../features/machine/widgets/operator_machine_view.dart';
import '../features/notifications/services/operator_notification_service.dart';
import '../features/notifications/widgets/operator_notifications_view.dart';
import '../widgets/operator_bottom_nav_bar.dart';
import '../widgets/operator_qr_scanner_sheet.dart';

class OperatorMainScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const OperatorMainScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<OperatorMainScreen> createState() => _OperatorMainScreenState();
}

class _OperatorMainScreenState extends ConsumerState<OperatorMainScreen> {
  late int _currentIndex;
  final OperatorNotificationService _notificationService =
      OperatorNotificationService();

  final List<Widget> _views = const [
    OperatorDashboardView(),
    OperatorMachineView(),
    OperatorChecklistView(),
    OperatorNotificationsView(),
  ];

  final List<String> _titles = const [
    'Trang Chủ',
    'Máy Móc',
    'Nhiệm Vụ',
    'Thông Báo',
  ];

  final int _pendingTasksCount = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    if (_currentIndex >= _views.length) {
      _currentIndex = 0;
    }
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
    final displayName = userProfile['fullName'] ?? userProfile['full_name'];
    final displayEmail = userProfile['email'];

    return StreamBuilder<int>(
      stream: _notificationService.streamUnreadCount(),
      builder: (context, unreadSnapshot) {
        final unreadCount = unreadSnapshot.data ?? 0;

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
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () => setState(() => _currentIndex = 3),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
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
            ],
          ),
          body: IndexedStack(index: _currentIndex, children: _views),
          bottomNavigationBar: OperatorBottomNavBar(
            currentIndex: _currentIndex,
            pendingTasksCount: _pendingTasksCount,
            unreadNotificationsCount: unreadCount,
            onItemSelected: (index) => setState(() => _currentIndex = index),
            onQRTapped: _openQRScannerModal,
          ),
        );
      },
    );
  }
}
