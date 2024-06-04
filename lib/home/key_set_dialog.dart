import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';

class KeySetDialog extends StatelessWidget{
  final ChatData data;

  const KeySetDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final keyController = TextEditingController();
    final orgController = TextEditingController();

    return Dialog(
      child: Column(
        children: [
          const Text("Enter API key"),
          TextField(
            controller: keyController,
            decoration: const InputDecoration(
              hintText: 'API Key',
            ),
          ),
          TextField(
            controller: orgController,
            decoration: const InputDecoration(
              hintText: 'Organization (Optional)',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  data.setKey(
                    keyController.text,
                    orgController.text,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Set'),
              ),
            ]
          )
        ]
      ),
    );
  }
}