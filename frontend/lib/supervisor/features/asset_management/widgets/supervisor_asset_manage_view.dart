import 'package:flutter/material.dart';

class SupervisorAssetManageView extends StatelessWidget {
  const SupervisorAssetManageView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Quản Lý Danh Mục Tài Sản',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.precision_manufacturing_outlined, color: Colors.blueGrey),
            title: const Text('Máy nén khí khu vực 1'),
            subtitle: const Text('Mã TS: TS-1002 • Trạng thái: Bình thường'),
            trailing: IconButton(
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
