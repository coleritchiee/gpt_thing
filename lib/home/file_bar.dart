import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';

class FileBar extends StatefulWidget {
  const FileBar({
    super.key,
    required this.data,
  });

  final ChatData data;

  @override
  State<FileBar> createState() => _FileBarState();
}

class _FileBarState extends State<FileBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.data.userFiles.map((file) {
            return Tooltip(
              message: file.name,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    widget.data.removeUserFile(file);
                  });
                },
                child: Icon(
                  file.icon,
                  color: file.color,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
