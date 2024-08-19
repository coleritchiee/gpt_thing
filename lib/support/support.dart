import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    var textHover = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatKeyPT"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Questions? Suggestions? Any problems?',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Reach out to us by email at:',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                Tooltip(
                  message: "Copy email",
                  child: StatefulBuilder(builder: (context, setState) {
                    return MouseRegion(
                      onEnter: (event) {
                        setState(() {
                          textHover = true;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          textHover = false;
                        });
                      },
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(const ClipboardData(
                              text: "silverpangolin.contact@gmail.com"));
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Email copied to clipboard"),
                          ));
                        },
                        child: Text("silverpangolin.contact@gmail.com",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration:
                                  textHover ? TextDecoration.underline : null,
                              decorationColor:
                                  Theme.of(context).colorScheme.primary,
                            )),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      context.go("/");
                    },
                    child: const Text('Go Back'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
