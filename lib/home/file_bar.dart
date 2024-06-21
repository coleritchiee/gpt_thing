import 'package:flutter/material.dart';

class FileBar extends StatelessWidget {
  const FileBar({
    super.key,
    required this.files,
  });

  final List<Icon> files;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: files.map((e) => e).toList(),
      ),
    );
  }
}
