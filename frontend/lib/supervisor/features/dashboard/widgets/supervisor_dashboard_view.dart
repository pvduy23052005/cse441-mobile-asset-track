import 'package:flutter/material.dart';

class SupervisorDashboardView extends StatelessWidget {
  const SupervisorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Quản Lý & Giám Sát',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.show_chart, color: Colors.blue),
              title: const Text('Tổng quan hoạt động hôm nay'),
              subtitle: const Text('Hệ thống vận hành ổn định'),
            ),
          ),
        ],
      ),
    );
  }
}
