import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OperatorChecklistView extends StatelessWidget {
  const OperatorChecklistView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Danh Sách Kiểm Tra Ca',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.foregroundColor,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: CheckboxListTile(
            value: true,
            activeColor: AppTheme.primaryColor,
            onChanged: (val) {},
            title: const Text('Kiểm tra áp suất hệ thống bơm A'),
            subtitle: const Text('Áp suất tiêu chuẩn: 4.5 - 5.0 bar'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: CheckboxListTile(
            value: false,
            activeColor: AppTheme.primaryColor,
            onChanged: (val) {},
            title: const Text('Ghi nhận chỉ số điện năng tủ điều khiển B'),
            subtitle: const Text('Ghi lại thông số chỉ số KWh'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: CheckboxListTile(
            value: false,
            activeColor: AppTheme.primaryColor,
            onChanged: (val) {},
            title: const Text('Kiểm tra vệ sinh khu vực vận hành C'),
            subtitle: const Text('Đảm bảo vệ sinh an toàn lao động'),
          ),
        ),
      ],
    );
  }
}
