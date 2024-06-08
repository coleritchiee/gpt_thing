import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';

class ModelDialog extends StatelessWidget {
  final ChatData data;

  ModelDialog({super.key, required this.data});

  final Map slugs = {
    "ChatGPT" : "gpt",
    "Dall·E" : "dall-e",
    "Other" : "",
  };
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints (
          maxWidth: 600,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              child: Column(
                children: slugs.keys.map((key) {
                  return TextButton(
                    onPressed: () {
                      print(slugs[key]);
                    },
                    child: Text(key),
                  );
                }).toList(),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: data.models.map((model) {
                  return TextButton(
                    onPressed: () {
                      data.setModel(model);
                    },
                    child: Text(model),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
