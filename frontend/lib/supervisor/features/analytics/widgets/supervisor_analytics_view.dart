import 'package:flutter/material.dart';

class SupervisorAnalyticsView extends StatelessWidget {
  const SupervisorAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân Tích KPI & Sức Khỏe Hệ Thống',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: const [
                        Text('Tỷ lệ sẵn sàng', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('98.5%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: const [
                        Text('Sự cố trong tháng', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('4 vụ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
