import 'package:flutter/material.dart';

class ApprovalCard extends StatelessWidget {
  final String title;
  final String requester;

  const ApprovalCard({
    super.key,
    required this.title,
    required this.requester,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('Người đề xuất: $requester'),
      ),
    );
  }
}
