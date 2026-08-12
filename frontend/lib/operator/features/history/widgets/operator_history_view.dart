import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OperatorHistoryView extends StatelessWidget {
  const OperatorHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Lịch Sử Vận Hành',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.foregroundColor,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history, color: AppTheme.primaryColor),
            ),
            title: const Text('Bàn giao ca thành công'),
            subtitle: const Text('08:00 - Ca Sáng (05/08/2026)'),
            trailing: Chip(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              side: BorderSide.none,
              label: const Text(
                'Hoàn tất',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
            ),
            title: const Text('Báo cáo sự cố Bơm A2'),
            subtitle: const Text('14:30 - Ca Chiều (04/08/2026)'),
            trailing: Chip(
              backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
              side: BorderSide.none,
              label: const Text(
                'Đã gửi',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
