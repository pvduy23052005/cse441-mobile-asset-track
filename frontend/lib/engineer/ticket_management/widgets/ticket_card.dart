import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  final String title;
  final String status;

  const TicketCard({
    super.key,
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('Trạng thái: $status'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
