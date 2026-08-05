import 'package:flutter/material.dart';
import '../features/dashboard/widgets/supervisor_dashboard_view.dart';
import '../features/approvals/widgets/supervisor_approval_view.dart';
import '../features/analytics/widgets/supervisor_analytics_view.dart';
import '../features/asset_management/widgets/supervisor_asset_manage_view.dart';

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
    SupervisorApprovalView(),
    SupervisorAnalyticsView(),
    SupervisorAssetManageView(),
  ];

  final List<String> _titles = const [
    'Dashboard Quản Lý',
    'Danh Sách Phê Duyệt',
    'Biểu Đồ KPI & Sức Khỏe',
    'Quản Lý Tài Sản',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.approval_outlined),
            activeIcon: Icon(Icons.approval),
            label: 'Phê Duyệt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_outlined),
            activeIcon: Icon(Icons.inventory),
            label: 'Tài Sản',
          ),
        ],
      ),
    );
  }
}
