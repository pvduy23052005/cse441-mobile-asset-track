import 'package:flutter/material.dart';

class EngineerTicketListView extends StatelessWidget {
  const EngineerTicketListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Danh Sách Ticket Bảo Trì',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.build_circle_outlined, color: Colors.orange),
            title: const Text('Ticket #TK-104: Sửa chữa máy nén khí B'),
            subtitle: const Text('Mức độ: Cao • Vị trí: Khu vực 2'),
            trailing: const Chip(
              label: Text('Đang xử lý'),
              backgroundColor: Color(0xFFFEF3C7),
            ),
          ),
        ),
      ],
    );
  }
}
