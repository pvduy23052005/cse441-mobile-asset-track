import 'package:flutter/material.dart';

class OperatorDashboardView extends StatelessWidget {
  const OperatorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng Quan Vận Hành',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: const Text('Trạng thái ca làm việc'),
              subtitle: const Text('Ca sáng - Đang hoạt động'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.pending_actions, color: Colors.orange),
              title: const Text('Checklist cần thực hiện'),
              subtitle: const Text('3 mục cần kiểm tra hôm nay'),
            ),
          ),
        ],
      ),
    );
  }
}
