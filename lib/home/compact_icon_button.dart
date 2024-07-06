import 'dart:async';
import 'package:flutter/material.dart';

class CompactIconButton extends StatefulWidget {
  const CompactIconButton(
      {super.key,
      required this.icon,
      this.showConfirm = true,
      this.onPressed,
      this.tooltip,
      this.color,
      this.iconSize});

  final Icon icon;
  final bool showConfirm;
  final Function()? onPressed;
  final String? tooltip;
  final Color? color;
  final double? iconSize;

  @override
  State<CompactIconButton> createState() => _CompactIconButtonState();
}

class _CompactIconButtonState extends State<CompactIconButton> {
  var actionPerformed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (val) {
        setState(() {
          actionPerformed = false;
        });
      },
      child: IconButton(
        icon: actionPerformed
            ? const Icon(Icons.check_rounded)
            : widget.icon,
        tooltip: widget.tooltip,
        onPressed: widget.onPressed == null ? null : () {
          widget.onPressed!();
          if (widget.showConfirm) {
            setState(() {
              actionPerformed = true;
              Timer(const Duration(seconds: 3), () {
                setState(() {
                  actionPerformed = false;
                });
              });
            });
          }
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
