import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';

class ModelDialog extends StatelessWidget {
  final ChatData data;

  const ModelDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String filter = "";
    String newModel = data.model;
    String newGroup = data.modelGroup;
    bool showPreviews = false;
    bool groupSelected = false;

    void setModel() {
      data.setModel(newModel, newGroup);
      Navigator.of(context).pop();
    }
    
    return Dialog(
      insetPadding: const EdgeInsets.all(24.0),
      clipBehavior: Clip.antiAlias, // fixes rounded corner issue with ListTile
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            if (!groupSelected) { // group selection
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Choose a Model",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        newModel.isEmpty ? "None Selected" : "Selected: $newModel",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(
                        height: 1,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: data.groups.map((group) {
                          return Material( // avoiding color overflow
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  filter = group.name;
                                  groupSelected = true;
                                });
                              },
                              title: Text(group.name),
                              subtitle: Text(group.description),
                              subtitleTextStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              tileColor:
                                  filter == group.name ? Colors.grey[850] : null,
                            ),
                          );
                        }).toList(),
                      )
                    ],
                ),
              );
            } else { // model selection
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filter,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        newModel.isEmpty ? "None Selected" : "Selected: $newModel",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(
                        height: 1,
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 300,
                        ),
                        child: ListView(
                          children: data.models.where((i) {
                            return (i.group == filter) &&
                                (showPreviews || !i.preview);
                          }).map((model) {
                            return Material( // need this so color doesn't overflow
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    if (newModel == model.id) {
                                      setModel(); // detecting "double tap"
                                    }
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
                                    ? Colors.grey[850]
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Column(
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  child: const Text("Back"),
                                  onPressed: () {
                                    setState(() {
                                      groupSelected = false;
                                    });
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text(
                                      "Preview Models",
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
                                  onPressed: newModel.isEmpty
                                      ? null
                                      : () {
                                          setModel();
                                        },
                                  child: const Text("Confirm"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                ),
              );
            }
          }
        )
      ),
    );
  }
}
