import 'package:flutter/material.dart';

class SystemAnalyticsScreen extends StatelessWidget {
  const SystemAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo & Thống Kê KPI'),
      ),
      body: const Center(
        child: Text('System Analytics Screen'),
      ),
    );
  }
}
