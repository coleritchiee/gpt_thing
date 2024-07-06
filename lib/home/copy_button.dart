import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyButton extends StatefulWidget {
  const CopyButton(
      {super.key,
      required this.text,
      required this.tooltip,
      this.color,
      this.iconSize});

  final String text;
  final String tooltip;
  final Color? color;
  final double? iconSize;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  var copied = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (val) {
        setState(() {
          copied = false;
        });
      },
      child: IconButton(
        icon: copied
            ? const Icon(Icons.check_rounded)
            : const Icon(Icons.copy_rounded),
        tooltip: widget.tooltip,
        onPressed: () {
          Clipboard.setData(ClipboardData(text: widget.text));
          setState(() {
            copied = true;
            Timer(const Duration(seconds: 3), () {
              setState(() {
                copied = false;
              });
            });
          });
        },
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        color: widget.color,
        iconSize: widget.iconSize,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(),
      ),
    );
  }
}
