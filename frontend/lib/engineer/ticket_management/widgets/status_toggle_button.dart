import 'package:flutter/material.dart';

class StatusToggleButton extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String>? onStatusChanged;

  const StatusToggleButton({
    super.key,
    required this.currentStatus,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onStatusChanged?.call(currentStatus),
      child: Text('Trạng thái: $currentStatus'),
    );
  }
}
