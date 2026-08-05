import 'package:flutter/material.dart';

class OperatorScanQrView extends StatelessWidget {
  const OperatorScanQrView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner_rounded,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Quét Mã QR / RFID Tài Sản',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Đưa camera tới mã QR trên thiết bị để kiểm tra',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
