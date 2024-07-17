import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/key_set_dialog.dart';
import 'package:gpt_thing/home/model_dialog.dart';
import 'package:gpt_thing/home/settings_tile.dart';
import 'package:gpt_thing/home/user_settings.dart';
import 'package:gpt_thing/services/firestore.dart';
import '../services/models.dart' as u;

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({
    super.key,
    required this.data,
    required this.nameController,
    required this.user,
  });

  final ChatData data;
  final TextEditingController nameController;
  final u.User user;

  @override
  Widget build(BuildContext context) {
    u.User prev =
        u.User(uid: user.uid, name: user.name, settings: user.settings);

    Future<bool> openKeySetDialog() async {
      bool? keySet =
          await showDialog(context: context, builder: KeySetDialog(data).build);
      return keySet == true;
    }

    Future<bool> setDefaultModel() async {
      if (!data.keyIsSet()) {
        if (!await openKeySetDialog()) return false;
      }
      Model? newModel;
      if (context.mounted) {
        newModel = await showDialog(
            context: context, builder: ModelDialog(data).build);
        if (newModel != null) {
          user.settings.defaultModel = newModel.id;
        }
      }
      return newModel != null;
    }

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
                    SettingsTile(
                        "Stream Response",
                        "Show chat responses as they are generated",
                        user.settings.streamResponse, (value) {
                      setState(() => user.updateSettings(
                          user.settings.copyWith(streamResponse: value)));
                    },
                        defaultValue: UserSettings.DEFAULT.streamResponse,
                        values: streamValues),
                    SettingsTile(
                        "Generate Titles",
                        "Automatically generate titles for new chats",
                        note: "Uses tokens on ChatGPT 3.5 Turbo",
                        noteColor: Colors.amber,
                        user.settings.generateTitles, (value) {
                      setState(() => user.updateSettings(
                          user.settings.copyWith(generateTitles: value)));
                    }, defaultValue: UserSettings.DEFAULT.generateTitles),
                    SettingsTile(
                      "Default Model",
                      "Automatically set the model in new chats",
                      note: user.settings.defaultModel.isEmpty
                          ? "None selected"
                          : "Selected: ${user.settings.defaultModel}",
                      user.settings.defaultModel,
                      (value) async {
                        if (value is String && value.isEmpty) {
                          // reset the setting
                          setState(() => user.updateSettings(
                              user.settings.copyWith(defaultModel: "")));
                          return;
                        }
                        if (await setDefaultModel()) {
                          data.applyDefaultModel();
                          setState(() {});
                        }
                      },
                      defaultValue: UserSettings.DEFAULT.defaultModel,
                      buttonText: "Select",
                    ),
                    SettingsTile(
                        "Show System Prompt",
                        "Enable an input field for a system prompt in chats",
                        user.settings.showSystemPrompt, (value) {
                      setState(() => user.updateSettings(
                          user.settings.copyWith(showSystemPrompt: value)));
                    }, defaultValue: UserSettings.DEFAULT.showSystemPrompt),
                    SettingsTile(
                        "Save API Key",
                        "Save your API key in the database, so it's ready when you log in",
                        note:
                            "This is sensitive info, only do this if you understand the risks involved",
                        noteColor: Colors.red.shade400,
                        user.settings.saveAPIKey, (value) async {
                      if (value) {
                        if (!data.keyIsSet()) {
                          await showDialog(
                              context: context,
                              builder: KeySetDialog(data).build);
                        }
                        if (data.keyIsSet()) {
                          user.updateSettings(
                              user.settings.copyWith(saveAPIKey: value));
                          user.setKey(data.apiKey, data.organization);
                        }
                      } else {
                        user.updateSettings(
                            user.settings.copyWith(saveAPIKey: value));
                      }
                      setState(() {});
                    }, defaultValue: UserSettings.DEFAULT.saveAPIKey),
                    SettingsTile(
                      "Set API Key",
                      "It may or may not be necessary to use this app",
                      note:
                          data.keyIsSet() ? "Key is set!" : "Currently not set",
                      null,
                      (value) async {
                        await showDialog(
                            context: context,
                            builder: KeySetDialog(data).build);
                        setState(() {});
                      },
                      buttonIcon: const Icon(Icons.key_rounded),
                    ),
                    SettingsTile(
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
                            user.overwrite(prev);
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
                                apiKey: user.apiKey,
                                org: user.org));
                            FirestoreService().updateUser(user);
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
