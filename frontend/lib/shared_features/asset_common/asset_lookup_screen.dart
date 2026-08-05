import 'package:flutter/material.dart';

class AssetLookupScreen extends StatelessWidget {
  const AssetLookupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra Cứu Tài Sản'),
      ),
      body: const Center(
        child: Text('Asset Lookup Screen'),
      ),
    );
  }
}
