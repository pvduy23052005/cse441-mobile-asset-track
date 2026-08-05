import 'package:flutter/material.dart';

class ShiftInfoCard extends StatelessWidget {
  const ShiftInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Thông tin Ca Làm Việc'),
      ),
    );
  }
}
