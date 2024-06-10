import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';

class ModelDialog extends StatelessWidget {
  final ChatData data;

  const ModelDialog({super.key, required this.data});
  
  @override
  Widget build(BuildContext context) {
    String filter = data.groups.first.name;
    bool showPreviews = false;

    return Dialog(
      insetPadding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints (
          maxWidth: 600,
          maxHeight: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder( // so the right column can update from the left
            builder: (context, setState) {
              return Column(
                children: [
                  const Text("Choose a Model"),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: data.groups.map((group) {
                              return Column(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        filter = group.name;
                                      });
                                    },
                                    child: Text(group.name),
                                  ),
                                  Text(
                                    group.description,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        Expanded(
                          flex: 3,
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("Show Preview Models"),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          onChanged: (value) {
                            setState(() {
                              showPreviews = (value)!;
                            });
                          },
                          value: showPreviews,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}
