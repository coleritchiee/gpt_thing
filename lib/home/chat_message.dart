import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gpt_thing/home/chat_image.dart';
import 'package:gpt_thing/home/compact_icon_button.dart';
import 'package:gpt_thing/home/markdown_code.dart';
import 'package:gpt_thing/home/model_group.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({
    super.key,
    required this.role,
    required this.modelGroup,
    this.model,
    this.timestamp,
    this.text = "",
    this.imageUrl = "",
    this.streaming = false,
  });

  final OpenAIChatMessageRole role;
  final ModelGroup modelGroup;
  final String? model;
  final DateTime? timestamp;
  final String text;
  final String imageUrl;
  final bool streaming;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  late bool markdown;

  @override
  void initState() {
    markdown = true;
    super.initState();
  }

  bool isToday() {
    final stamp = widget.timestamp!;
    final now = DateTime.now();
    return stamp.year == now.year &&
        stamp.month == now.month &&
        stamp.day == now.day;
  }

  String stampFormat() {
    return isToday()
        ? DateFormat.jm().format(widget.timestamp!)
        : DateFormat.yMd().format(widget.timestamp!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: widget.role == OpenAIChatMessageRole.user
              ? Alignment.centerRight
              : widget.role == OpenAIChatMessageRole.system
                  ? Alignment.center
                  : Alignment.centerLeft,
          child: Text(
            widget.role == OpenAIChatMessageRole.user
                ? "You"
                : widget.role == OpenAIChatMessageRole.system
                    ? "System"
                    : widget.modelGroup == ModelGroup.other
                        ? "Assistant"
                        : widget.modelGroup.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: widget.role == OpenAIChatMessageRole.user
              ? Alignment.centerRight
              : widget.role == OpenAIChatMessageRole.system
                  ? Alignment.center
                  : Alignment.centerLeft,
          child: Column(
            children: [
              if (widget.text.isNotEmpty)
                SelectionArea(
                    // use SelectionArea to avoid multiple highlights
                    child: widget.role == OpenAIChatMessageRole.assistant
                        ? markdown
                            ? MarkdownBody(
                                data: widget.text,
                                styleSheet: gptStyle,
                                onTapLink: (text, href, title) async {
                                  if (href != null) {
                                    if (!await openLink(href) &&
                                        context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          "Invalid link: $href",
                                        ),
                                      ));
                                    }
                                  }
                                },
                                imageBuilder: (uri, title, alt) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: ChatImage(
                                                  imageUrl: uri.toString(),
                                                  altText: alt)),
                                        ]),
                                  );
                                },
                                checkboxBuilder: (isChecked) {
                                  return Icon(
                                      isChecked
                                          ? Icons.check_box_rounded
                                          : Icons
                                              .check_box_outline_blank_rounded,
                                      applyTextScaling: true,
                                      size: 16);
                                },
                                builders: {
                                    'code': MarkdownCode(),
                                  })
                            : Text(
                                widget.text,
                              )
                        : FractionallySizedBox(
                            widthFactor: 0.9,
                            child: Align(
                              alignment: widget.role ==
                                      OpenAIChatMessageRole.user
                                  ? Alignment.centerRight
                                  : widget.role == OpenAIChatMessageRole.system
                                      ? Alignment.center
                                      : Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.grey[850],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  child: Text(
                                    widget.text,
                                  ),
                                ),
                              ),
                            ),
                          )),
              if (widget.imageUrl.isNotEmpty)
                ChatImage(imageUrl: widget.imageUrl),
              if (widget.text.isEmpty && widget.imageUrl.isEmpty)
                const Text(
                  "Thinking...",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                )
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (widget.role == OpenAIChatMessageRole.assistant &&
            !widget.streaming &&
            widget.imageUrl != "Generating...")
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (widget.text.isNotEmpty)
                    CompactIconButton(
                      icon: const Icon(Icons.copy_rounded),
                      tooltip: "Copy message",
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: widget.text));
                        return true;
                      },
                    ),
                  if (widget.text.isNotEmpty)
                    if (markdown)
                      CompactIconButton(
                          icon: const Icon(Icons.code_off_rounded),
                          tooltip: "View without formatting",
                          showConfirm: false,
                          onPressed: () async {
                            setState(() {
                              markdown = false;
                            });
                            return true;
                          })
                    else
                      CompactIconButton(
                          icon: const Icon(Icons.code_rounded),
                          tooltip: "View with Markdown",
                          showConfirm: false,
                          onPressed: () async {
                            setState(() {
                              markdown = true;
                            });
                            return true;
                          }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      "${widget.model!} • ${stampFormat()}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (widget.role == OpenAIChatMessageRole.user)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                stampFormat(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          )
      ],
    );
  }
}

Future<bool> openLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null) {
    try {
      return await launchUrl(uri);
    } catch (e) {
      return false;
    }
  }
  return false;
}

final gptStyle = MarkdownStyleSheet(
  // a: null,
  // blockSpacing: null,
  blockquote: null,
  // blockquoteAlign: null,
  blockquoteDecoration: BoxDecoration(
      border: Border(
          left: BorderSide(
    color: Colors.grey.shade800,
    width: 5,
  ))),
  blockquotePadding: const EdgeInsets.only(
    left: 16,
    top: 4,
    bottom: 4,
  ),
  // checkbox: null,
  // code: GoogleFonts.robotoMono(
  //   backgroundColor: Colors.grey.shade900,
  // ),
  // codeblockAlign: null,
  // codeblockDecoration: BoxDecoration(
  //   color: Colors.grey.shade900,
  //   borderRadius: BorderRadius.circular(8),
  //   border: Border.all(color: Colors.grey.shade800),
  // ),
  // codeblockPadding: null,
  // del: null,
  // em: null,
  // h1: null,
  // h1Align: null,
  // h1Padding: null,
  // h2: null,
  // h2Align: null,
  // h2Padding: null,
  // h3: null,
  // h3Align: null,
  // h3Padding: null,
  // h4: null,
  // h4Align: null,
  // h4Padding: null,
  // h5: null,
  // h5Align: null,
  // h5Padding: null,
  // h6: null,
  // h6Align: null,
  // h6Padding: null,
  horizontalRuleDecoration: BoxDecoration(
    border: Border.all(
      color: Colors.grey.shade800,
      width: 1,
    ),
  ),
  // img: null,
  // listBullet: null,
  // listBulletPadding: null,
  // listIndent: null,
  // orderedListAlign: null,
  // p: null,
  // pPadding: null,
  // strong: null,
  // superscriptFontFeatureTag: null,
  // tableBody: null,
  // tableBorder: null,
  // tableCellsDecoration: null,
  // tableCellsPadding: null,
  // tableColumnWidth: null,
  // tableHead: null,
  // tableHeadAlign: null,
  // tablePadding: null,
  // tableVerticalAlignment: null,
  // textAlign: null,
  // textScaler: null,
  // unorderedListAlign: null,
);
