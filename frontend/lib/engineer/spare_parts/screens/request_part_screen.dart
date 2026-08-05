import 'package:flutter/material.dart';

class RequestPartScreen extends StatelessWidget {
  const RequestPartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu Cầu Linh Kiện'),
      ),
      body: const Center(
        child: Text('Request Part Screen'),
      ),
    );
  }
}
