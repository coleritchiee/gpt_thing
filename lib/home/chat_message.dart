import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpt_thing/home/compact_icon_button.dart';
import 'package:gpt_thing/home/markdown_code.dart';
import 'package:gpt_thing/home/model_group.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class ChatMessage extends StatefulWidget {
  const ChatMessage({
    super.key,
    required this.role,
    required this.modelGroup,
    this.text = "",
    this.imageUrl = "",
  });

  final OpenAIChatMessageRole role;
  final ModelGroup modelGroup;
  final String text;
  final String imageUrl;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  late bool markdown;

  @override
  void initState() {
    super.initState();
    markdown = true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
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
                      child: widget.role == OpenAIChatMessageRole.assistant
                          ? markdown
                              ? MarkdownBody(
                                  data: widget.text,
                                  styleSheet: gptStyle,
                                  builders: {
                                      'code': MarkdownCode(),
                                    })
                              : Text(
                                  widget.text,
                                  textAlign: TextAlign.left,
                                )
                          : Text(
                              widget.text,
                              textAlign: widget.role == OpenAIChatMessageRole.user
                                  ? TextAlign.right
                                  : TextAlign.center,
                            )), // use SelectionArea to avoid multiple highlights
                if (widget.imageUrl.isNotEmpty)
                  FractionallySizedBox(
                    widthFactor: 0.7,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.grey[900]!),
                          child: CachedNetworkImage(
                            imageUrl: widget.imageUrl,
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
                              child:
                                  Icon(Icons.error, color: Colors.red[200]!),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
          if (widget.role == OpenAIChatMessageRole.assistant)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (widget.text.isNotEmpty)
                      CompactIconButton(
                        icon: const Icon(Icons.copy_rounded),
                        tooltip: "Copy message",
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.text));
                        },
                      ),
                    if (widget.text.isNotEmpty)
                      if (markdown)
                        CompactIconButton(
                            icon: const Icon(Icons.code_off_rounded),
                            tooltip: "View without formatting",
                            showConfirm: false,
                            onPressed: () {
                              setState(() {
                                markdown = false;
                              });
                            })
                      else
                        CompactIconButton(
                            icon: const Icon(Icons.code_rounded),
                            tooltip: "View with Markdown",
                            showConfirm: false,
                            onPressed: () {
                              setState(() {
                                markdown = true;
                              });
                            }),
                    if (widget.imageUrl.isNotEmpty)
                      CompactIconButton(
                        icon: const Icon(Icons.file_download_rounded),
                        tooltip: "Save image",
                        onPressed: () {
                          saveImage(widget.imageUrl);
                        },
                      ),
                    if (widget.imageUrl.isNotEmpty && !kIsWeb)
                      CompactIconButton(
                        icon: Platform.isAndroid
                            ? const Icon(Icons.share_rounded)
                            : const Icon(Icons.ios_share_rounded),
                        onPressed: () {
                          shareImage(widget.imageUrl);
                        },
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void saveImage(String url) async {
  if (kIsWeb) {
    html.AnchorElement anchor = html.AnchorElement(href: url);
    anchor.download = url;
    anchor.click();
    anchor.remove();
  } else {
    final imagePath = '${Directory.systemTemp.path}/image.png';
    await Dio().download(url, imagePath);
    await Gal.putImage(imagePath);
  }
}

void shareImage(String url) async {
  if (!kIsWeb) {
    final imagePath = '${Directory.systemTemp.path}/image.png';
    await Dio().download(url, imagePath);
    Share.shareXFiles([XFile(imagePath)]);
  }
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
  code: GoogleFonts.robotoMono(
    backgroundColor: Colors.grey.shade900,
  ),
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
  // horizontalRuleDecoration: null,
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
