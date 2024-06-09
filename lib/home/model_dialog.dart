import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';

class ModelDialog extends StatelessWidget {
  final ChatData data;

  const ModelDialog({super.key, required this.data});
  
  @override
  Widget build(BuildContext context) {
    String filter = data.groups.keys.first;
    bool showPreviews = false;

    return Dialog(
      insetPadding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints (
          maxWidth: 600,
          maxHeight: 500,
        ),
        child: StatefulBuilder( // so the right column can update from the left
          builder: (context, setState) {
            return Column(
              children: [
                SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      const Text("Show Preview Models"),
                      Checkbox(
                        onChanged: (value) {
                          setState(() {
                            showPreviews = (value)!;
                          });
                        },
                        value: showPreviews,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 200,
                        ),
                        child: ListView(
                          children: data.groups.keys.map((key) {
                            return TextButton(
                              onPressed: () {
                                setState(() {
                                  filter = key;
                                });
                              },
                              child: Text(key),
                            );
                          }).toList(),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 300,
                        ),
                        child: ListView(
                          children: data.models.where((i) {
                            return (i.group == filter) && (showPreviews || !i.preview);
                          }
                          ).map((model) {
                            return TextButton(
                              onPressed: () {
                                data.setModel(model.id);
                                Navigator.of(context).pop();
                              },
                              child: Text(model.id),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
