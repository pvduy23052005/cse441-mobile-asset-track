import 'package:flutter/material.dart';

class OperatorHistoryView extends StatelessWidget {
  const OperatorHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Lịch Sử Vận Hành',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.blue),
            title: const Text('Bàn giao ca thành công'),
            subtitle: const Text('08:00 - Ca Sáng (05/08/2026)'),
            trailing: const Chip(label: Text('Hoàn tất')),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            title: const Text('Báo cáo sự cố Bơm A2'),
            subtitle: const Text('14:30 - Ca Chiều (04/08/2026)'),
            trailing: const Chip(label: Text('Đã gửi')),
          ),
        ),
      ],
    );
  }
}
