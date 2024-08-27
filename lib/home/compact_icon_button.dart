import 'dart:async';
import 'package:flutter/material.dart';

class CompactIconButton extends StatefulWidget {
  const CompactIconButton(
      {super.key,
      required this.icon,
      this.showConfirm = true,
      this.showLoading = false,
      this.onPressed,
      this.tooltip,
      this.color,
      this.iconSize});

  final Icon icon;
  final bool showConfirm;
  final bool showLoading;
  final Future<bool> Function()? onPressed;
  final String? tooltip;
  final Color? color;
  final double? iconSize;

  @override
  State<CompactIconButton> createState() => _CompactIconButtonState();
}

class _CompactIconButtonState extends State<CompactIconButton> {
  var actionPerformed = false;
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: ConstrainedBox(
            constraints: widget.iconSize != null
                ? BoxConstraints(
                    maxHeight: widget.iconSize! - 8, minHeight: widget.iconSize! - 8)
                : const BoxConstraints(maxHeight: 16, maxWidth: 16),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: widget.color,
            )),
      );
    } else {
      return MouseRegion(
        onEnter: (val) {
          setState(() {
            actionPerformed = false;
          });
        },
        child: IconButton(
          icon: actionPerformed ? const Icon(Icons.check_rounded) : widget.icon,
          tooltip: widget.tooltip,
          onPressed: widget.onPressed == null
              ? null
              : () async {
                  if (widget.showLoading) {
                    setState(() {
                      isLoading = true;
                    });
                  }
                  final result = await widget.onPressed!();
                  if (widget.showConfirm && result) {
                    setState(() {
                      isLoading = false;
                      actionPerformed = true;
                      Timer(const Duration(seconds: 3), () {
                        setState(() {
                          actionPerformed = false;
                        });
                      });
                    });
                  } else {
                    setState(() {
                      isLoading = false;
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
}
