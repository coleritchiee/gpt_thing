import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/services/firestore.dart';

class KeySetDialog extends StatelessWidget {
  final ChatData data;

  const KeySetDialog(this.data, {super.key});

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
                setState(() {
                  isWaiting = true;
                });
                final validated = await data.setKey(keyController.text, orgController.text);
                if (validated) {
                  FirestoreService().updateUser(data.user);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    Navigator.pop(context, true);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      // TODO: change this to something else later
                      content: Text(
                          "Something went wrong. Check your API key and try again."),
                    ),
                  );
                  keyFocus.requestFocus();
                }
                setState(() {
                  isWaiting = false;
                });
                data.applyDefaultModel(context);
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
                    !data.user.settings.saveAPIKey
                        ? "This info will not be saved."
                        : "This info WILL be saved. This can be changed in settings.",
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                              autofocus: true,
                              focusNode: keyFocus,
                              controller: keyController,
                              decoration: const InputDecoration(
                                hintText: 'API Key',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                              onChanged: (text) {
                                setState(() {});
                              }, // make the button update
                              onSubmitted:
                                  keyController.text.isEmpty || isWaiting
                                      ? null
                                      : (text) {
                                          setInfo();
                                        }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: IconButton(
                            icon: const Icon(Icons.paste_rounded),
                            color: Colors.grey[600]!,
                            style: const ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () async {
                              final data =
                                  await Clipboard.getData(Clipboard.kTextPlain);
                              setState(() {
                                keyController.text = data!.text!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                              controller: orgController,
                              decoration: const InputDecoration(
                                hintText: 'Organization (Optional)',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                              onSubmitted:
                                  keyController.text.isEmpty || isWaiting
                                      ? null
                                      : (text) {
                                          setInfo();
                                        }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: IconButton(
                            icon: const Icon(Icons.paste_rounded),
                            color: Colors.grey[600]!,
                            style: const ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () async {
                              final data =
                                  await Clipboard.getData(Clipboard.kTextPlain);
                              setState(() {
                                orgController.text = data!.text!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                          ScaffoldMessenger.of(context).clearSnackBars();
                        },
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
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
                            style: const ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
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
