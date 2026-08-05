import 'package:flutter/material.dart';

class ApprovalListScreen extends StatelessWidget {
  const ApprovalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyệt Đề Xuất / Ngân Sách'),
      ),
      body: const Center(
        child: Text('Approval List Screen'),
      ),
    );
  }
}
