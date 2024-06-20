import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';

class ChatWindow extends StatefulWidget {
  final ChatData data;
  final ScrollController scroller;

  const ChatWindow({super.key, required this.data, required this.scroller});

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
    final messages = widget.data.messages.reversed.map((msg) {
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
                        : widget.data.modelGroup == "Other"
                            ? "Assistant"
                            : widget.data.modelGroup,
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
                    CachedNetworkImage(
                      imageUrl: msg.content![0].imageUrl!,
                      placeholder: (context, url) => const Text(
                        "Loading...",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();

    if (widget.data.isThinking()) {
      messages.insert(
        0,
        Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.data.modelGroup == "Other"
                      ? "Assistant"
                      : widget.data.modelGroup,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Thinking...",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.data.streamText.isNotEmpty) {
      messages.insert(
        0,
        Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.data.modelGroup == "Other"
                      ? "Assistant"
                      : widget.data.modelGroup,
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
                alignment: Alignment.centerLeft,
                child: Text(widget.data.streamText),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: widget.scroller,
        reverse: true,
        children: messages,
      ),
    );
  }
}
