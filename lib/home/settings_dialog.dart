import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gpt_thing/home/user_settings.dart';
import '../services/models.dart' as u;

class SettingsDialog extends StatelessWidget {
  const SettingsDialog(
      {super.key, required this.nameController, required this.user});

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
                        "Shows words as they are generated, instead of waiting for the full message",
                        user.settings.streamResponse, (value) {
                      setState(() => user.updateSettings(
                          user.settings.copyWith(streamResponse: value)));
                    }, values: streamValues),
                    _settingsTile(
                        "Generate Titles",
                        "Automatically generate titles for chats, using tokens",
                        user.settings.generateTitles, (value) {
                      setState(() => user.updateSettings(
                          user.settings.copyWith(generateTitles: value)));
                    }),
                    _settingsTile(
                        "Show System Prompt",
                        "Enables an input field for system prompts in chats",
                        user.settings.showSystemPrompt, (value) {
                      setState(() => user.updateSettings(
                          user.settings.copyWith(showSystemPrompt: value)));
                    }),
                    _settingsTile(
                      "Clear Cache",
                      "In case anything isn't working right",
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
    {List<dynamic>? values, Icon? buttonIcon}) {
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
    subtitle: Text(description),
    trailing: trailingWidget,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
