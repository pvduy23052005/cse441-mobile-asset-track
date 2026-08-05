import 'package:flutter/material.dart';

class ReportIncidentScreen extends StatelessWidget {
  const ReportIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo Sự Cố Nhanh'),
      ),
      body: const Center(
        child: Text('Report Incident Screen'),
      ),
    );
  }
}
