import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatSidebarButton extends StatefulWidget {
  final String title;
  final Function() onClick;
  final Function() onRename;
  final Function() onDelete;

  const ChatSidebarButton({
    super.key,
    required this.title,
    required this.onRename,
    required this.onDelete,
    required this.onClick,
  });

  @override
  _ChatSidebarButtonState createState() => _ChatSidebarButtonState();
}

class _ChatSidebarButtonState extends State<ChatSidebarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ListTile(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
        ),
        titleTextStyle: Theme.of(context).textTheme.bodySmall,
        visualDensity: const VisualDensity(vertical: -4),
        trailing: _isHovered
            ? PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    child: const Text('Rename'),
                    onTap: () {
                      widget.onRename();
                    },
                  ),
                  PopupMenuItem<String>(
                    child: const Text('Delete'),
                    onTap: () {
                      widget.onDelete();
                    },
                  ),
                ],
                icon: const Icon(Icons.more_vert_rounded),
                iconSize: 20,
                padding: EdgeInsets.zero,
                splashRadius: 10,
              )
            : null,
        onTap: () {
          widget.onClick();
        },
        onLongPress: kIsWeb
            ? null
            : () {
                HapticFeedback.mediumImpact();
                showOptionsMenu();
              },
      ),
    );
  }

  showOptionsMenu() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Rename'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onRename();
                  },
                ),
                ListTile(
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onDelete();
                  },
                ),
              ],
            ),
          );
        });
  }
}
