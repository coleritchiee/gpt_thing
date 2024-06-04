import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';

class ChatWindow extends StatefulWidget {
  final ChatData data;

  const ChatWindow({super.key, required this.data});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class ChatMessage {
  late bool user;
  late String message;

  ChatMessage(bool u, String m) {
    user = u;
    message = m;
  }
}

class _ChatWindowState extends State<ChatWindow> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        reverse: true,
        children: widget.data.messages.reversed.map((msg) {
          return Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
            ),
            child: Column(
              children: [
                Align(
                  alignment: msg.role == ChatRole.user
                    ? Alignment.centerRight
                    : msg.role == ChatRole.system
                      ? Alignment.center
                      : Alignment.centerLeft,
                  child: Text(
                    msg.role == ChatRole.user
                    ? "You"
                    : msg.role == ChatRole.system
                      ? "System"
                      : "ChatGPT",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Align(
                  alignment: msg.role == ChatRole.user
                    ? Alignment.centerRight
                    : msg.role == ChatRole.system
                      ? Alignment.center
                      : Alignment.centerLeft,
                  child: Text(
                    msg.message,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
