import 'package:flutter/material.dart';

class PhotoPickerWidget extends StatelessWidget {
  const PhotoPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.add_a_photo, size: 36, color: Colors.grey),
      ),
    );
  }
}
