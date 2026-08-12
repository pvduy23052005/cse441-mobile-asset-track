import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OperatorScanQrView extends StatelessWidget {
  const OperatorScanQrView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quét Mã QR / RFID Tài Sản',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.foregroundColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Đưa camera tới mã QR trên thiết bị để kiểm tra',
            style: TextStyle(color: AppTheme.mutedForegroundColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
