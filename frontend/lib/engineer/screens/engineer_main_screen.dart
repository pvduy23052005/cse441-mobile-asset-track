import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_router.dart';
import '../../core/utils/storage_service.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/role_header.dart';
import '../features/dashboard/widgets/engineer_dashboard_view.dart';
import '../features/machines/widgets/engineer_machines_view.dart';
import '../features/notifications/models/engineer_notification.dart';
import '../features/notifications/services/engineer_notification_service.dart';
import '../features/notifications/widgets/engineer_notifications_view.dart';
import '../features/ticket_management/widgets/engineer_ticket_list_view.dart';

class EngineerMainScreen extends StatefulWidget {
  final int initialIndex;
  const EngineerMainScreen({super.key, this.initialIndex = 0});

  @override
  State<EngineerMainScreen> createState() => _EngineerMainScreenState();
}

class _EngineerMainScreenState extends State<EngineerMainScreen> {
  late int _currentIndex;
  final EngineerNotificationService _notificationService =
      EngineerNotificationService();

  final List<Widget> _views = const [
    EngineerDashboardView(),
    EngineerMachinesView(),
    EngineerTicketListView(),
    EngineerNotificationsView(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = StorageService.getUserProfile();
    final displayName = userProfile['fullName']?.isNotEmpty == true
        ? userProfile['fullName']!
        : 'Kỹ Sư ME Trần Minh Đức';
    final displayEmail = userProfile['email']?.isNotEmpty == true
        ? userProfile['email']!
        : 'me.duc@factory.com';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: AppDrawer(
        userName: displayName,
        userEmail: displayEmail,
        roleLabel: 'Đội Kỹ Thuật Cơ Điện',
        roleBadge: 'ENGINEER',
        roleColor: const Color(0xFF0284C7),
        toolNavItems: [
          DrawerMenuItem(
            icon: Icons.manage_search_rounded,
            title: 'Tra Cứu Thiết Bị (Quét QR)',
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.assetLookup);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            RoleHeader(
              roleName: 'Kỹ Sư ME',
              userEmail: displayEmail,
              roleIcon: Icons.build_rounded,
              roleColor: const Color(0xFF0284C7),
              onChangeAccount: () async {
                await StorageService.clearSession();
                if (context.mounted) context.go(AppRoutes.loginPortal);
              },
            ),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _views),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StreamBuilder<List<EngineerNotification>>(
        stream: _notificationService.streamNotifications(),
        builder: (context, snapshot) {
          final unreadCount = snapshot.hasData
              ? snapshot.data!.where((n) => !n.isRead).length
              : 0;

          return AppBottomNavBar(
            currentIndex: _currentIndex,
            onItemSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            onQRTapped: () {
              context.push(AppRoutes.assetLookup);
            },
            pendingTasksCount: 0,
            unreadNotificationsCount: unreadCount,
          );
        },
      ),
    );
  }
}
