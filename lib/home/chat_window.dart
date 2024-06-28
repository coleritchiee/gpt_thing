import 'dart:async';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/chat_message.dart';

class ChatWindow extends StatefulWidget {
  final ChatData data;
  final ScrollController scroller;

  const ChatWindow({super.key, required this.data, required this.scroller});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  bool blink = true;
  late Timer blinkTimer;

  @override
  void initState() {
    super.initState();
    blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        blink = !blink;
      });
    });
  }

  @override
  void dispose() {
    blinkTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> messages = widget.data.messages.reversed.map((msg) {
      return ChatMessage(
        role: msg.role,
        modelGroup: widget.data.modelGroup,
        text: msg.content!.first.text != null ? msg.content!.first.text! : "",
        imageUrl: msg.content!.first.imageUrl != null
            ? msg.content!.first.imageUrl!
            : "",
      );
    }).toList();

    if (widget.data.isThinking()) {
      messages.insert(
        0,
        ChatMessage(
          role: OpenAIChatMessageRole.assistant,
          modelGroup: widget.data.modelGroup,
          text: widget.data.streamText,
        ),
      );
    }

    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        controller: widget.scroller,
        reverse: true,
        children: messages,
      ),
    );
  }
}
