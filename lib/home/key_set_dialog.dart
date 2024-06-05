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
      insetPadding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Enter API Key",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "This is sensitive info, we know. Don't worry—we don't save any of it.",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: keyController,
                    decoration: InputDecoration(
                      hintText: 'API Key',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      )
                    ),
                    onChanged: (text) {setState(() {});}, // make the button update
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: orgController,
                    decoration: InputDecoration(
                      hintText: 'Organization (Optional)',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      )
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        onPressed: keyController.text.isEmpty ? null : () {
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}