import 'package:flutter/material.dart';

class EngineerDashboardView extends StatelessWidget {
  const EngineerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Kỹ Thuật & Bảo Trì',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.build, color: Colors.orange),
              title: const Text('Ticket đang xử lý'),
              subtitle: const Text('2 ticket cần hoàn tất hôm nay'),
            ),
          ),
        ],
      ),
    );
  }
}
