import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_thing/legal.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    var hover1 = false;
    var hover2 = false;
    var hover3 = false;
    var hover4 = false;

    return Column(
      children: [
        const SizedBox(height: 16),
        StatefulBuilder(builder: (context, setState) {
          return MouseRegion(
            onEnter: (event) {
              setState(() {
                hover1 = true;
              });
            },
            onExit: (event) {
              setState(() {
                hover1 = false;
              });
            },
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                openLink("https://github.com/coleritchiee/gpt_thing");
              },
              child: Text("GitHub",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: hover1 ? TextDecoration.underline : null,
                    decorationColor: Theme.of(context).colorScheme.primary,
                  )),
            ),
          );
        }),
        if (!kIsWeb) const SizedBox(height: 8),
        if (!kIsWeb)
          StatefulBuilder(builder: (context, setState) {
            return MouseRegion(
              onEnter: (event) {
                setState(() {
                  hover2 = true;
                });
              },
              onExit: (event) {
                setState(() {
                  hover2 = false;
                });
              },
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  openLink("https://www.chatkeypt.com/");
                },
                child: Text("Website",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: hover2 ? TextDecoration.underline : null,
                      decorationColor: Theme.of(context).colorScheme.primary,
                    )),
              ),
            );
          }),
        const SizedBox(height: 8),
        StatefulBuilder(builder: (context, setState) {
          return MouseRegion(
            onEnter: (event) {
              setState(() {
                hover3 = true;
              });
            },
            onExit: (event) {
              setState(() {
                hover3 = false;
              });
            },
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                openPrivacyPolicy();
              },
              child: Text("Privacy Policy",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: hover3 ? TextDecoration.underline : null,
                    decorationColor: Theme.of(context).colorScheme.primary,
                  )),
            ),
          );
        }),
        const SizedBox(height: 8),
        StatefulBuilder(builder: (context, setState) {
          return MouseRegion(
            onEnter: (event) {
              setState(() {
                hover4 = true;
              });
            },
            onExit: (event) {
              setState(() {
                hover4 = false;
              });
            },
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                openTOS();
              },
              child: Text("Terms of Service",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: hover4 ? TextDecoration.underline : null,
                    decorationColor: Theme.of(context).colorScheme.primary,
                  )),
            ),
          );
        }),
        const SizedBox(height: 8),
        StatefulBuilder(builder: (context, setState) {
          return MouseRegion(
            onEnter: (event) {
              setState(() {
                hover4 = true;
              });
            },
            onExit: (event) {
              setState(() {
                hover4 = false;
              });
            },
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                context.go("/support");
              },
              child: Text("Support",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: hover4 ? TextDecoration.underline : null,
                    decorationColor: Theme.of(context).colorScheme.primary,
                  )),
            ),
          );
        }),
        const SizedBox(height: 8),
        StatefulBuilder(builder: (context, setState) {
          return MouseRegion(
            onEnter: (event) {
              setState(() {
                hover4 = true;
              });
            },
            onExit: (event) {
              setState(() {
                hover4 = false;
              });
            },
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                context.go("/delete-account");
              },
              child: Text("Delete My Account",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: hover4 ? TextDecoration.underline : null,
                    decorationColor: Theme.of(context).colorScheme.primary,
                  )),
            ),
          );
        }),
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
