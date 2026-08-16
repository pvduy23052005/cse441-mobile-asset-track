import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_service.dart';
import '../../core/widgets/app_drawer.dart';
import '../../operator/features/machine/widgets/machine_detail_modal.dart';
import '../../operator/widgets/operator_qr_scanner_sheet.dart';
import '../features/dashboard/widgets/supervisor_dashboard_view.dart';
import '../features/approvals/widgets/supervisor_approval_view.dart';
import '../features/analytics/widgets/supervisor_analytics_view.dart';
import '../features/machine_management/widgets/supervisor_machine_manage_view.dart';
import '../features/user_management/widgets/supervisor_user_manage_view.dart';

class SupervisorMainScreen extends StatefulWidget {
  final int initialIndex;
  const SupervisorMainScreen({super.key, this.initialIndex = 0});

  @override
  State<SupervisorMainScreen> createState() => _SupervisorMainScreenState();
}

class _SupervisorMainScreenState extends State<SupervisorMainScreen> {
  late int _currentIndex;

  final List<Widget> _views = const [
    SupervisorDashboardView(),
    SupervisorMachineManageView(),
    SupervisorApprovalView(),
    SupervisorUserManageView(),
  ];

  final List<String> _titles = const [
    'Trang Chủ Quản Đốc',
    'Quản Lý Máy Móc',
    'Nhiệm Vụ & Phê Duyệt',
    'Quản Lý Nhân Sự Phân Xưởng',
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
            tooltip: 'Thông Báo & KPI',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Thông Báo & Giám Sát KPI'),
                    ),
                    body: const SupervisorAnalyticsView(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        userName: displayName,
        userEmail: displayEmail,
        roleLabel: 'Phân Xưởng Sản Xuất',
        roleBadge: 'QUẢN ĐỐC',
        roleColor: AppTheme.primaryColor,
        toolNavItems: [
          DrawerMenuItem(
            icon: Icons.notifications_active_rounded,
            title: 'Thông Báo & Giám Sát KPI',
            badgeCount: _unreadNotificationsCount,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Thông Báo & Giám Sát')),
                    body: const SupervisorAnalyticsView(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _views),
      bottomNavigationBar: _buildCustomBottomBar(),
    );
  }

  Widget _buildCustomBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: const Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.foregroundColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Trang Chủ',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _buildNavItem(
                icon: Icons.memory_rounded,
                activeIcon: Icons.memory_rounded,
                label: 'Máy Móc',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _buildCenterQRButton(),
              _buildNavItem(
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment_rounded,
                label: 'Nhiệm Vụ',
                isSelected: _currentIndex == 2,
                badgeCount: _pendingTasksCount,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _buildNavItem(
                icon: Icons.people_outline_rounded,
                activeIcon: Icons.people_rounded,
                label: 'Nhân Sự',
                isSelected: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final Color color = isSelected
        ? AppTheme.primaryColor
        : AppTheme.mutedForegroundColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(isSelected ? activeIcon : icon, size: 24, color: color),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterQRButton() {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _openQRScannerModal,
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -18,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.cardColor, width: 3.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.38),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 8,
                child: Text(
                  'Quét QR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
