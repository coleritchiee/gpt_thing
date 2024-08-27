import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMsg;

  const ErrorDialog({super.key, required this.errorMsg});

  @override
  Widget build(BuildContext context) {
    bool apiError = errorMsg != "unexpected";

    return AlertDialog(
      insetPadding: const EdgeInsets.all(24.0),
      title: Text(apiError ? "OpenAI Error" : "Unexpected Error"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SelectableText(apiError
            ? errorMsg
            : "Something went wrong, try again later. If the issue persists, let us know what happened at silverpangolin.contact@gmail.com."),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
