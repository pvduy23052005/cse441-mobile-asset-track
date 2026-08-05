import 'package:flutter/material.dart';

class LoginPortalScreen extends StatelessWidget {
  const LoginPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Portal'),
      ),
      body: const Center(
        child: Text('Login Portal Screen'),
      ),
    );
  }
}
