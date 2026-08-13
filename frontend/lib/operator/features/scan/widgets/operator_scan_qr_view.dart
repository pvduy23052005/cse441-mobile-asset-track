import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/operator_qr_scanner_sheet.dart';

class OperatorScanQrView extends StatelessWidget {
  const OperatorScanQrView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              'Đưa camera tới mã QR trên thiết bị hoặc tải ảnh lên để kiểm tra nhanh',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.mutedForegroundColor, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => OperatorQRScannerSheet.show(context),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
              label: const Text(
                'Mở Quét QR / Tải ảnh',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
