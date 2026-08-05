import 'package:flutter/material.dart';

class HealthChart extends StatelessWidget {
  const HealthChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.indigo.shade50,
      child: const Center(
        child: Text('Biểu Đồ Sức Khỏe Hệ Thống'),
      ),
    );
  }
}
