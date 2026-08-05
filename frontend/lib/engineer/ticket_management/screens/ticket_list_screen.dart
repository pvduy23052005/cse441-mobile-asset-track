import 'package:flutter/material.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Ticket'),
      ),
      body: const Center(
        child: Text('Ticket List Screen'),
      ),
    );
  }
}
