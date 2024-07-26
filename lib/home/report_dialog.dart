import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({
    super.key,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  late String message;
  
  @override
  void initState() {
    message = "";
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Report Conversation"),
      content: SizedBox(
        width: 400,
        child: TextField(
          maxLines: null,
          onChanged: (value) {
            setState(() {
              message = value;
            });
          },
          decoration: const InputDecoration(
            hintText: "What went wrong?",
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, "");
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: message.isEmpty ? null : () {
            Navigator.pop(context, message);
          },
          child: const Text("Send"),
        ),
      ],
    );
  }
}
