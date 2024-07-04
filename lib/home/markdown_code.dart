import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atelier-cave-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownCode extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element, TextStyle? preferredStyle, TextStyle? parentStyle) {
    var language = '';

    if (element.attributes['class'] != null) {
      language = (element.attributes['class'] as String).substring(9);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: HighlightView(
        element.textContent.trim(),
        language: language,
        theme: atelierCaveDarkTheme,
        padding: const EdgeInsets.all(4),
      ),
    );
  }
}
