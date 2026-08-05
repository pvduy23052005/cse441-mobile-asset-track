import 'package:flutter/material.dart';
import '../features/dashboard/widgets/engineer_dashboard_view.dart';
import '../features/ticket_management/widgets/engineer_ticket_list_view.dart';
import '../features/spare_parts/widgets/engineer_spare_parts_view.dart';
import '../features/history/widgets/engineer_history_view.dart';

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
    EngineerTicketListView(),
    EngineerSparePartsView(),
    EngineerHistoryView(),
  ];

  final List<String> _titles = const [
    'Dashboard Kỹ Thuật',
    'Danh Sách Ticket Bảo Trì',
    'Yêu Cầu & Quản Lý Phụ Tùng',
    'Lịch Sử Bảo Trì',
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
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'Phụ Tùng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Lịch Sử',
          ),
        ],
      ),
    );
  }
}
