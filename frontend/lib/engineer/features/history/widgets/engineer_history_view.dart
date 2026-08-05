import 'package:flutter/material.dart';

class EngineerHistoryView extends StatelessWidget {
  const EngineerHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Lịch Sử Bảo Trì & Sửa Chữa',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.check_circle_rounded, color: Colors.green),
            title: const Text('Bảo dưỡng định kỳ tủ điện A1'),
            subtitle: const Text('Hoàn tất lúc 16:30 (04/08/2026)'),
            trailing: const Chip(label: Text('Thành công')),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.check_circle_rounded, color: Colors.green),
            title: const Text('Thay dầu bôi trơn động cơ chính'),
            subtitle: const Text('Hoàn tất lúc 10:15 (02/08/2026)'),
            trailing: const Chip(label: Text('Thành công')),
          ),
        ),
      ],
    );
  }
}
