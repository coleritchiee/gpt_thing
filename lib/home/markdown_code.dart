import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/ir-black.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownCode extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element,
      TextStyle? preferredStyle, TextStyle? parentStyle) {
    var language = '';
    var code = element.textContent.trim();
    var mouseHover = false;
    var codeCopied = false;

    if (element.attributes['class'] != null) {
      language = (element.attributes['class'] as String).substring(9);
    }

    ScrollController scroller = ScrollController();
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (val) {
            setState(() {
              mouseHover = true;
            });
          },
          onExit: (val) {
            setState(() {
              mouseHover = false;
              codeCopied = false;
            });
          },
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: Scrollbar(
                  controller: scroller,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: scroller,
                    child: HighlightView(
                      code,
                      language: language,
                      theme: irBlackTheme,
                      padding: const EdgeInsets.all(8),
                      textStyle: GoogleFonts.robotoMono(),
                    ),
                  ),
                ),
              ),
              if (mouseHover && codeCopied)
                IconButton(
                  icon: const Icon(Icons.check_rounded),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                  },
                  color: Colors.grey,
                )
              else if (mouseHover)
                IconButton(
                  icon: const Icon(Icons.copy_rounded),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    setState(() {
                      codeCopied = true;
                    });
                  },
                  color: Colors.grey,
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    language,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }
}
