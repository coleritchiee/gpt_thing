import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMsg;

  const ErrorDialog({super.key, required this.errorMsg});

  @override
  Widget build(BuildContext context) {
    bool apiError = errorMsg != "unexpected";

    return AlertDialog(
      title: Text(apiError ? "OpenAI Error" : "Unexpected Error"),
      content: Text(apiError ? errorMsg : "Something went wrong, try again later. If the issue persists, let us know what happened at silverpangolin.contact@gmail.com."),
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