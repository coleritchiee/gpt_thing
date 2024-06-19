import 'package:flutter/material.dart';
import 'package:gpt_thing/home/api_manager.dart';
import 'package:gpt_thing/home/chat_data.dart';

class KeySetDialog extends StatelessWidget {
  final ChatData data;
  final APIManager api;

  const KeySetDialog({super.key, required this.data, required this.api});

  @override
  Widget build(BuildContext context) {
    final keyController = TextEditingController();
    final keyFocus = FocusNode();
    final orgController = TextEditingController();

    bool isWaiting = false;

    keyController.text = data.apiKey;
    orgController.text = data.organization;

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
              // i know its ugly but i need this function here to be able to call setState
              void setInfo() async {
                data.setKey(keyController.text, orgController.text);
                setState(() {
                  isWaiting = true;
                });
                try {
                  data.addModels(await api.getModels());
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        // TODO: change this to something else later
                        content: Text(
                            "Something went wrong. Check your API key and try again."),
                      ),
                    );
                  }
                  data.resetKey();
                  setState(() {
                    isWaiting = false;
                  });
                  keyFocus.requestFocus();
                  return;
                }
                setState(() {
                  isWaiting = false;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  Navigator.pop(context);
                }
              }

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
                      autofocus: true,
                      focusNode: keyFocus,
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
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                      onChanged: (text) {
                        setState(() {});
                      }, // make the button update
                      onSubmitted: keyController.text.isEmpty || isWaiting
                          ? null
                          : (text) {
                              setInfo();
                            }),
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
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                      onSubmitted: keyController.text.isEmpty || isWaiting
                          ? null
                          : (text) {
                              setInfo();
                            }),
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
                      Row(
                        children: [
                          if (isWaiting)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            ),
                          TextButton(
                            onPressed: keyController.text.isEmpty || isWaiting
                                ? null
                                : setInfo,
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
