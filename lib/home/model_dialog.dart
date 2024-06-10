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
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: StatefulBuilder( // so the right column can update from the left
            builder: (context, setState) {
              return Column(
                children: [
                  const Text(
                    "Choose a Model",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: data.groups.map((group) {
                              return ListTile(
                                onTap: () {
                                  setState(() {
                                    filter = group.name;
                                  });
                                },
                                title: Text(group.name),
                                subtitle: Text(group.description),
                                subtitleTextStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: data.models.where((i) {
                              return (i.group == filter) && (showPreviews || !i.preview);
                            }
                            ).map((model) {
                              return ListTile(
                                onTap: () {
                                  data.setModel(model.id);
                                  Navigator.of(context).pop();
                                },
                                title: Center(child: Text(model.id)),
                                titleTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                dense: true,
                                visualDensity: VisualDensity(vertical: -4),
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
                      const Text(
                        "Show Preview Models",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Checkbox(
                        onChanged: (value) {
                          setState(() {
                            showPreviews = (value)!;
                          });
                        },
                        value: showPreviews,
                        side: BorderSide(
                          color: (Colors.grey[500])!,
                        ),
                        activeColor: Colors.grey[500],
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