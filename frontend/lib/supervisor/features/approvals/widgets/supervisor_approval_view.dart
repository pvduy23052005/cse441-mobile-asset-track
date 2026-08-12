import 'package:flutter/material.dart';

class SupervisorApprovalView extends StatelessWidget {
  const SupervisorApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Danh Sách Cần Phê Duyệt',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.gavel_rounded, color: Colors.purple),
            title: const Text('Đề xuất mua 5 vòng bi SKF 6204'),
            subtitle: const Text('Người gửi: Kỹ sư Nguyễn Văn A'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: const Size(60, 36),
              ),
              onPressed: () {},
              child: const Text('Duyệt'),
            ),
          ),
        ),
      ],
    );
  }
}
