import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';

class ModelDialog extends StatelessWidget {
  final ChatData data;

  const ModelDialog({super.key, required this.data});
  
  @override
  Widget build(BuildContext context) {
    String filter = data.groups.first.name;
    String newModel = data.model;
    String newGroup = data.modelGroup;
    bool showPreviews = false;

    void setModel() {
      data.setModel(newModel, newGroup);
      Navigator.of(context).pop();
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints (
          maxWidth: 600,
          maxHeight: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
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
                              return Expanded(
                                child: ListTile(
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
                                  tileColor: filter == group.name
                                    ? Theme.of(context).colorScheme.inversePrimary
                                    : null,
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
                                  setState(() {
                                    newModel = model.id;
                                    newGroup = model.group;
                                  });
                                },
                                title: Center(child: Text(model.id)),
                                titleTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                dense: true,
                                visualDensity: const VisualDensity(vertical: -4),
                                tileColor: newModel == model.id
                                  ? Theme.of(context).colorScheme.inversePrimary
                                  : null,
                              );
                            }).toList(),
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
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
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
                      TextButton(
                        onPressed: newModel.isEmpty ? null : () {
                          setModel();
                        },
                        child: const Text("Confirm"),
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
