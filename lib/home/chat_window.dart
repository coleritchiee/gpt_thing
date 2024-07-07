import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/chat_message.dart';
import 'package:gpt_thing/home/model_group.dart';

class ChatWindow extends StatefulWidget {
  final ChatData data;
  final ScrollController scroller;

  const ChatWindow({super.key, required this.data, required this.scroller});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final FocusNode nothing = FocusNode();

  void unfocus() {
    FocusScope.of(context).requestFocus(nothing);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> messages = widget.data.messages.map((msg) {
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
      if (widget.data.modelGroup == ModelGroup.dalle) {
        messages.add(
          ChatMessage(
            role: OpenAIChatMessageRole.assistant,
            modelGroup: widget.data.modelGroup,
            imageUrl: "Generating...",
          ),
        );
      } else {
        messages.add(
          ChatMessage(
            role: OpenAIChatMessageRole.assistant,
            modelGroup: widget.data.modelGroup,
            text: widget.data.streamText,
          ),
        );
      }
    }

    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notif) {
          if (notif is ScrollStartNotification && !kIsWeb) {
            unfocus();
          }
          return true;
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          controller: widget.scroller,
          reverse: true,
          child: Column(
            children: messages,
          )
        ),
      ),
    );
  }
}
