import 'package:flutter/material.dart';

class ShiftCheckScreen extends StatelessWidget {
  const ShiftCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm Tra Ca Làm Việc'),
      ),
      body: const Center(
        child: Text('Shift Check Screen'),
      ),
    );
  }
}
