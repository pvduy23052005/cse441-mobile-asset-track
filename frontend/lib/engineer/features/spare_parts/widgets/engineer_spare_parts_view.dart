import 'package:flutter/material.dart';

class EngineerSparePartsView extends StatelessWidget {
  const EngineerSparePartsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Quản Lý & Yêu Cầu Phụ Tùng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.inventory_2_outlined, color: Colors.indigo),
            title: const Text('Vòng bi công nghiệp SKF 6204'),
            subtitle: const Text('Tồn kho: 15 bộ • Đang chờ duyệt: 2'),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {},
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.inventory_2_outlined, color: Colors.indigo),
            title: const Text('Cảm biến áp suất Danfoss MBS 3000'),
            subtitle: const Text('Tồn kho: 4 bộ • Cần nhập thêm'),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
