import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_router.dart';
import '../../core/utils/storage_service.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/role_header.dart';
import '../features/dashboard/widgets/engineer_dashboard_view.dart';
import '../features/history/widgets/engineer_history_view.dart';
import '../features/machines/widgets/engineer_machines_view.dart';
import '../features/ticket_management/widgets/engineer_ticket_list_view.dart';

class EngineerMainScreen extends StatefulWidget {
  final int initialIndex;
  const EngineerMainScreen({super.key, this.initialIndex = 0});

  @override
  State<EngineerMainScreen> createState() => _EngineerMainScreenState();
}

class _EngineerMainScreenState extends State<EngineerMainScreen> {
  late int _currentIndex;

  final List<Widget> _views = const [
    EngineerDashboardView(),
    EngineerMachinesView(),
    EngineerTicketListView(),
    EngineerHistoryView(),
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
            // 1. Role Header dùng chung chuẩn Wireframe UI
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

            // 2. Nội dung các tab (IndexedStack)
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _views),
            ),
          ],
        ),
      ),

      // 3. Navigation Bar dùng chung chuẩn Wireframe UI (có nút Quét QR nổi ở giữa)
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onQRTapped: () {
          context.push(AppRoutes.assetLookup);
        },
        pendingTasksCount: 2,
        unreadNotificationsCount: 2,
      ),
    );
  }
}
