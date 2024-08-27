import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpt_thing/home/compact_icon_button.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownCode extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element,
      TextStyle? preferredStyle, TextStyle? parentStyle) {
    var language = "";
    var code = element.textContent.trim();

    var wrapCode = false;

    if (element.attributes['class'] != null) {
      language = (element.attributes['class'] as String).substring(9);
    }

    if (language == "" && !code.contains('\n')) {
      return RichText(
        // must be RichText otherwise SelectionArea throws a fit
        text: TextSpan(
          text: code,
          style: GoogleFonts.robotoMono(
            color: Colors.grey[350],
            fontSize: 14,
            backgroundColor: Colors.black,
          ),
        ),
        textScaler: MediaQuery.textScalerOf(
            context), // to scale with mobile accessibility
      );
    } else {
      ScrollController scroller = ScrollController();
      if (language.isEmpty) {
        language = "code";
      }

      return StatefulBuilder(builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
              clipBehavior: Clip.antiAlias,
              child: wrapCode
                  ? HighlightView(
                      code,
                      language: language,
                      theme: irBlackModifiedTheme,
                      padding: const EdgeInsets.all(8),
                      textStyle: GoogleFonts.robotoMono(
                        fontSize: MediaQuery.of(context)
                            .textScaler
                            .scale(14), // to scale with mobile accessibility
                      ),
                    )
                  : kIsWeb
                      ? Scrollbar(
                          controller: scroller,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: scroller,
                            child: HighlightView(
                              code,
                              language: language,
                              theme: irBlackModifiedTheme,
                              padding: const EdgeInsets.all(8),
                              textStyle: GoogleFonts.robotoMono(
                                fontSize: MediaQuery.of(context).textScaler.scale(
                                    14), // to scale with mobile accessibility
                              ),
                            ),
                          ),
                        )
                      : Scrollbar(
                          controller: scroller,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: scroller,
                            child: IgnorePointer(
                              child: HighlightView(
                                code,
                                language: language,
                                theme: irBlackModifiedTheme,
                                padding: const EdgeInsets.all(8),
                                textStyle: GoogleFonts.robotoMono(
                                  fontSize: MediaQuery.of(context).textScaler.scale(
                                      14), // to scale with mobile accessibility
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (language.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
                      child: Text(
                        language,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  CompactIconButton(
                    icon: const Icon(Icons.copy_rounded),
                    tooltip: "Copy code",
                    color: Colors.grey,
                    iconSize: 20,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: code));
                      return true;
                    },
                  ),
                  CompactIconButton(
                    icon: const Icon(Icons.wrap_text_rounded),
                    tooltip: "Wrap code",
                    color: Colors.grey,
                    iconSize: 20,
                    showConfirm: false,
                    onPressed: () async {
                      setState(() {
                        wrapCode = !wrapCode;
                      });
                      return true;
                    },
                  ),
                ]),
          ],
        );
      });
    }
  }
}

// source before modfication: https://github.com/git-touch/highlight.dart/blob/master/flutter_highlight/lib/themes/ir-black.dart
final irBlackModifiedTheme = {
  'root': TextStyle(
      backgroundColor: const Color(0xff000000),
      color: Colors.grey[350]), // I only changed the base text color
  'comment': const TextStyle(color: Color(0xff7c7c7c)),
  'quote': const TextStyle(color: Color(0xff7c7c7c)),
  'meta': const TextStyle(color: Color(0xff7c7c7c)),
  'keyword': const TextStyle(color: Color(0xff96cbfe)),
  'selector-tag': const TextStyle(color: Color(0xff96cbfe)),
  'tag': const TextStyle(color: Color(0xff96cbfe)),
  'name': const TextStyle(color: Color(0xff96cbfe)),
  'attribute': const TextStyle(color: Color(0xffffffb6)),
  'selector-id': const TextStyle(color: Color(0xffffffb6)),
  'string': const TextStyle(color: Color(0xffa8ff60)),
  'selector-attr': const TextStyle(color: Color(0xffa8ff60)),
  'selector-pseudo': const TextStyle(color: Color(0xffa8ff60)),
  'addition': const TextStyle(color: Color(0xffa8ff60)),
  'subst': const TextStyle(color: Color(0xffdaefa3)),
  'regexp': const TextStyle(color: Color(0xffe9c062)),
  'link': const TextStyle(color: Color(0xffe9c062)),
  'title': const TextStyle(color: Color(0xffffffb6)),
  'section': const TextStyle(color: Color(0xffffffb6)),
  'type': const TextStyle(color: Color(0xffffffb6)),
  'doctag': const TextStyle(color: Color(0xffffffb6)),
  'symbol': const TextStyle(color: Color(0xffc6c5fe)),
  'bullet': const TextStyle(color: Color(0xffc6c5fe)),
  'variable': const TextStyle(color: Color(0xffc6c5fe)),
  'template-variable': const TextStyle(color: Color(0xffc6c5fe)),
  'literal': const TextStyle(color: Color(0xffc6c5fe)),
  'number': const TextStyle(color: Color(0xffff73fd)),
  'deletion': const TextStyle(color: Color(0xffff73fd)),
  'emphasis': const TextStyle(fontStyle: FontStyle.italic),
  'strong': const TextStyle(fontWeight: FontWeight.bold),
};
