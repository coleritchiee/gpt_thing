import 'package:dart_openai/dart_openai.dart';
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
                  alignment: msg.role == OpenAIChatMessageRole.user
                    ? Alignment.centerRight
                    : msg.role == OpenAIChatMessageRole.system
                      ? Alignment.center
                      : Alignment.centerLeft,
                  child: Text(
                    msg.role == OpenAIChatMessageRole.user
                    ? "You"
                    : msg.role == OpenAIChatMessageRole.system
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
                  alignment: msg.role == OpenAIChatMessageRole.user
                    ? Alignment.centerRight
                    : msg.role == OpenAIChatMessageRole.system
                      ? Alignment.center
                      : Alignment.centerLeft,
                  child: Column(
                    children: [
                      if ((msg.content)![0].text != null)
                        Text(
                          ((msg.content)![0].text)!,
                        ),
                      if ((msg.content)![0].imageUrl != null)
                        Image.network(
                          ((msg.content)![0].imageUrl)!,
                        )
                    ],
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
