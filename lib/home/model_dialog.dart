import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/model_group.dart';

class ModelDialog extends StatelessWidget {
  final ChatData data;

  const ModelDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    ModelGroup? filter;
    String newModel = data.model;
    ModelGroup newGroup = data.modelGroup;
    bool hasPreviews = false;
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
          maxHeight: 700,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            if (!groupSelected) { // group selection
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Choose a Model",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(
                        height: 1,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: data.groups.where((group) => group.isSupported()).map((group) {
                          return Material( // avoiding color overflow
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  filter = group;
                                  groupSelected = true;
                                });
                              },
                              title: Center(child: Text(group.name)),
                              subtitle: Center(child: Text(group.description)),
                              subtitleTextStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
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
                        filter!.name,
                        style: const TextStyle(
                          fontSize: 18,
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
                          padding: EdgeInsets.zero,
                          children: data.models.where((model) {
                            if (model.group == filter && model.preview) {
                              hasPreviews = true;
                            }
                            return (model.group == filter) &&
                                (showPreviews || !model.preview);
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
                                      filter = null;
                                      hasPreviews = false;
                                      groupSelected = false;
                                    });
                                  },
                                ),
                                if (hasPreviews)
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
                                  onPressed: newModel.isNotEmpty && newGroup == filter
                                      ? () {
                                          setModel();
                                        }
                                      : null,
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
