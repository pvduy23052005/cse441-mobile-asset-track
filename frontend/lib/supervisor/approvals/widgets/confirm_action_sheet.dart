import 'package:flutter/material.dart';

class ConfirmActionSheet extends StatelessWidget {
  final String actionTitle;
  final VoidCallback onConfirm;

  const ConfirmActionSheet({
    super.key,
    required this.actionTitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Xác nhận $actionTitle?', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
