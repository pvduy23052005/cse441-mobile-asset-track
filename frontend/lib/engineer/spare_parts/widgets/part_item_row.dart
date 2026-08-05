import 'package:flutter/material.dart';

class PartItemRow extends StatelessWidget {
  final String partName;
  final int quantity;

  const PartItemRow({
    super.key,
    required this.partName,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(partName),
      trailing: Text('SL: $quantity'),
    );
  }
}
