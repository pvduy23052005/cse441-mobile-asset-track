import 'package:flutter/material.dart';

class ScanResultDialog extends StatelessWidget {
  final String result;

  const ScanResultDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kết Quả Quét'),
      content: Text(result),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
