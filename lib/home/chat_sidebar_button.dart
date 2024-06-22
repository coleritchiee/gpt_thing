import 'package:flutter/material.dart';

class ChatSidebarButton extends StatefulWidget {
  final String title;
  final Function() onClick;
  final Function() onRename;
  final Function() onDelete;

  const ChatSidebarButton({
    Key? key,
    required this.title,
    required this.onRename,
    required this.onDelete,
    required this.onClick,
  }) : super(key: key);

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
                icon: const Icon(Icons.more_vert),
              )
            : null,
        onTap: () {
          widget.onClick();
        },
      ),
    );
  }
}
