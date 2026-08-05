import 'package:flutter/material.dart';

class SupervisorMachineManageView extends StatelessWidget {
  const SupervisorMachineManageView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Quản Lý Máy Móc & Thiết Bị',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.precision_manufacturing_outlined, color: Colors.blueGrey),
            title: const Text('Máy nén khí khu vực 1'),
            subtitle: const Text('Mã máy: MM-1002 • Trạng thái: Bình thường'),
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
