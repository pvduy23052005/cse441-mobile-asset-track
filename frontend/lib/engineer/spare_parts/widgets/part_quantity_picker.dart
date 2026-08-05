import 'package:flutter/material.dart';

class PartQuantityPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const PartQuantityPicker({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: value > 1 ? () => onChanged?.call(value - 1) : null,
        ),
        Text('$value', style: const TextStyle(fontSize: 16)),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged?.call(value + 1),
        ),
      ],
    );
  }
}
