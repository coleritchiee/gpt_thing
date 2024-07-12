import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/key_set_dialog.dart';
import 'package:gpt_thing/home/user_settings.dart';
import '../services/models.dart' as u;

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({
    super.key,
    required this.data,
    required this.keyDialog,
    required this.nameController,
    required this.user,
  });

  final ChatData data;
  final KeySetDialog keyDialog;
  final TextEditingController nameController;
  final u.User user;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Settings",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Change Name",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(
                        "Stream Response",
                        "Show the response as its generated, instead of waiting until it's finished",
                        user.settings.streamResponse, (value) {
                      setState(() => user.updateSettings(
                          user.settings.copyWith(streamResponse: value)));
                    }, values: streamValues),
                    _settingsTile(
                        "Generate Titles",
                        "Automatically generate titles for chats",
                        note: "Uses tokens on ChatGPT 3.5 Turbo",
                        noteColor: Colors.amber,
                        user.settings.generateTitles, (value) {
                      setState(() => user.updateSettings(
                          user.settings.copyWith(generateTitles: value)));
                    }),
                    _settingsTile(
                        "Show System Prompt",
                        "Enable an input field for a system prompt in chats",
                        user.settings.showSystemPrompt, (value) {
                      setState(() => user.updateSettings(
                          user.settings.copyWith(showSystemPrompt: value)));
                    }),
                    _settingsTile(
                        "Save API Key",
                        "Save your API key in the database, so it's ready when you log in",
                        note:
                            "This is sensitive info, only do this if you understand the risks involved",
                        noteColor: Colors.red.shade400,
                        user.settings.saveAPIToken, (value) {
                      setState(() => user.updateSettings(
                          user.settings.copyWith(saveAPIToken: value)));
                    }),
                    _settingsTile(
                      "Set API Key",
                      "It may or may not be necessary to use this app",
                      note: data.keyIsSet() ? "Key is set!" : "Currently not set",
                      null,
                      (value) async {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return keyDialog;
                            });
                        setState(() {});
                      },
                      buttonIcon: const Icon(Icons.key_rounded),
                    ),
                    _settingsTile(
                      "Clear Cache",
                      "This will not delete any of your chats or images",
                      null,
                      (value) async {
                        await DefaultCacheManager().emptyCache();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Cache cleared'),
                            duration: Duration(seconds: 2),
                          ));
                        }
                      },
                      buttonIcon: const Icon(Icons.delete_rounded),
                    ),
                    const SizedBox(height: 10),
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
                          onPressed: () {
                            user.overwrite(u.User(
                              uid: user.uid,
                              name: nameController.text,
                              settings: user.settings,
                            ));
                            Navigator.of(context).pop();
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

Widget _settingsTile(String title, String description, dynamic currentValue,
    Function(dynamic) onChanged,
    {List<dynamic>? values, Icon? buttonIcon, String? note, Color? noteColor}) {
  Widget trailingWidget = const SizedBox.shrink();

  if (currentValue is bool) {
    trailingWidget = Switch(
      value: currentValue,
      onChanged: onChanged,
    );
  } else if (currentValue is String) {
    trailingWidget = DropdownButton(
      value: currentValue,
      items: values!.map((value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  } else {
    trailingWidget = IconButton(
      icon: buttonIcon ?? const Icon(Icons.error_outline_rounded),
      onPressed: () {
        onChanged(null);
      },
    );
  }

  return ListTile(
    title: Text(title),
    subtitle: RichText(
      text: TextSpan(children: [
        TextSpan(
            text: description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            )),
        if (note != null)
          TextSpan(
              text: "\n$note",
              style: TextStyle(
                color: noteColor ?? Colors.grey.shade600,
                fontSize: 14,
                height: 1.5, // for line spacing
              )),
      ]),
    ),
    trailing: trailingWidget,
  );
}