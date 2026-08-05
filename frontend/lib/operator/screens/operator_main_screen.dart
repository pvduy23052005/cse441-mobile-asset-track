import 'package:flutter/material.dart';
import '../features/dashboard/widgets/operator_dashboard_view.dart';
import '../features/scan/widgets/operator_scan_qr_view.dart';
import '../features/checklist/widgets/operator_checklist_view.dart';
import '../features/history/widgets/operator_history_view.dart';

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
    OperatorScanQrView(),
    OperatorChecklistView(),
    OperatorHistoryView(),
  ];

  final List<String> _titles = const [
    'Dashboard Vận Hành',
    'Quét Mã QR / RFID',
    'Checklist Bàn Giao Ca',
    'Lịch Sử Vận Hành',
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
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Quét QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check),
            label: 'Checklist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
        ],
      ),
    );
  }
}
