import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:gpt_thing/home/model_group.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    super.key,
    required this.role,
    required this.modelGroup,
    this.text = "",
    this.imageUrl = "",
    this.blink = false,
  });

  final OpenAIChatMessageRole role;
  final ModelGroup modelGroup;
  final String text;
  final String imageUrl;
  final bool blink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Align(
            alignment: role == OpenAIChatMessageRole.user
                ? Alignment.centerRight
                : role == OpenAIChatMessageRole.system
                    ? Alignment.center
                    : Alignment.centerLeft,
            child: Text(
              role == OpenAIChatMessageRole.user
                  ? "You"
                  : role == OpenAIChatMessageRole.system
                      ? "System"
                      : modelGroup == ModelGroup.other
                          ? "Assistant"
                          : modelGroup.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: role == OpenAIChatMessageRole.user
                ? Alignment.centerRight
                : role == OpenAIChatMessageRole.system
                    ? Alignment.center
                    : Alignment.centerLeft,
            child: Column(
              children: [
                if (text.isNotEmpty)
                  SelectionArea(
                      child: Text(
                    text,
                    textAlign: role == OpenAIChatMessageRole.user
                        ? TextAlign.right
                        : role == OpenAIChatMessageRole.system
                            ? TextAlign.center
                            : TextAlign.left,
                  )), // use SelectionArea to avoid multiple highlights
                if (imageUrl.isNotEmpty)
                  FractionallySizedBox(
                    widthFactor: 0.7,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.grey[900]!),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            placeholder: (context, url) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_rounded,
                                    color: Colors.grey[700]),
                                const Text(
                                  "Loading image...",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(Icons.error, color: Colors.red[200]!),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (text.isEmpty && imageUrl.isEmpty)
                  const Text(
                    "Thinking...",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
