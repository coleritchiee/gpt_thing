import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/chat_message.dart';
import 'package:gpt_thing/home/model_group.dart';
import 'package:gpt_thing/home/report_dialog.dart';
import 'package:gpt_thing/services/firestore.dart';
// import 'package:intl/intl.dart';

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
    // have to define it here or it throws a fit over types when adding the token display
    final List<Widget> messages = [];

    messages.addAll(widget.data.messages.map((msg) {
      return ChatMessage(
          role: msg.role,
          model: msg.model,
          timestamp: msg.timestamp,
          modelGroup: widget.data.modelGroup,
          text: msg.text != null ? msg.text! : "",
          imageUrl: msg.imageUrl != null ? msg.imageUrl! : "",
          onReport: () async {
            final String? message = await showDialog(
                context: context, builder: (context) => const ReportDialog());
            if (message == null || message.isEmpty) {
              return false;
            }
            final result = await FirestoreService().addChatReport(widget.data);
            if (result) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Report sent",
                    ),
                  ),
                );
              }
              return true;
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Error occurred while sending report",
                    ),
                  ),
                );
              }
              return false;
            }
          });
    }).toList());

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
            streaming: true,
          ),
        );
      }
    }

    // if (widget.data.hasTokenUsage()) {
    //   final formatter = NumberFormat.compact();
    //   formatter.maximumFractionDigits = 1;
    //   // final input = formatter.format(widget.data.inputTokens);
    //   // final output = formatter.format(widget.data.outputTokens);
    //   final input = 1;
    //   final output = 1;

    //   messages.add(
    //     Padding(
    //       padding: const EdgeInsets.only(bottom: 4),
    //       child: Text(
    //         "Token Usage: $input input, $output output",
    //         style: const TextStyle(
    //           color: Colors.grey,
    //           fontSize: 12,
    //           fontStyle: FontStyle.italic,
    //         ),
    //         textAlign: TextAlign.center,
    //       ),
    //     ),
    //   );
    // }

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
            )),
      ),
    );
  }
}
