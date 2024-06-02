import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatWindow extends StatefulWidget {
  const ChatWindow({super.key});

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
  List<ChatMessage> messages = [
    ChatMessage(true, "Hi"),
    ChatMessage(false, "Hello! What can I help you with today?"),
    ChatMessage(true, "May I have something to eat?"),
    ChatMessage(false, "No."),
    ChatMessage(true, "May I have something to eat?"),
    ChatMessage(false, "No."),
    ChatMessage(true, "May I have something to eat?"),
    ChatMessage(false, "No."),
    ChatMessage(true, "May I have something to eat?"),
    ChatMessage(false, "Try asking again."),
    ChatMessage(true, "MAY I HAVE SOMETHING TO EAT?"),
    ChatMessage(false, "No~"),
  ];

  void sendMsg(ChatMessage msg) {
    setState(() {
      messages.add(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        reverse: true,
        children: messages.reversed.map((msg) {
          return Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
            ),
            child: Column(
              children: [
                Align(
                  alignment: msg.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    msg.user ? "You" : "ChatGPT",
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
                  alignment: msg.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: MarkdownBody(
                    data: msg.message,
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
