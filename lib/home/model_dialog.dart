import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_data.dart';

class ModelDialog extends StatelessWidget {
  final ChatData data;

  const ModelDialog({super.key, required this.data});
  
  @override
  Widget build(BuildContext context) {
    String filter = data.groups.keys.first;

    return Dialog(
      insetPadding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints (
          maxWidth: 600,
          maxHeight: 500,
        ),
        child: StatefulBuilder( // so the right column can update from the left
          builder: (context, setState) {
            return Row(
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
                            print(data.groups[key]);
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
                    children: data.models.where((i) => i.group == filter).map((model) {
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
            );
          }
        ),
      ),
    );
  }
}
