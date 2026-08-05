import 'package:flutter/material.dart';

class TicketDetailScreen extends StatelessWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Ticket #$ticketId'),
      ),
      body: Center(
        child: Text('Ticket Detail: $ticketId'),
      ),
    );
  }
}
