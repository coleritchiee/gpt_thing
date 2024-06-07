import 'package:flutter/material.dart';
import 'package:gpt_thing/home/api_manager.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/key_set_dialog.dart';
import 'chat_window.dart';
import 'message_box.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    APIManager api = APIManager();
    ChatData data = ChatData();
    KeySetDialog keyDialog = KeySetDialog(data: data, api: api);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPT Thing'),
        forceMaterialTransparency: true,
      ),
      drawer: Drawer(
        shape: const LinearBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const ListTile(
                title: Text('GPT Thing'),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text('ChatGPT'),
                  titleTextStyle: Theme.of(context).textTheme.bodySmall,
                  leading: const Icon(Icons.chat_rounded),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text('DALL·E'),
                  titleTextStyle: Theme.of(context).textTheme.bodySmall,
                  leading: const Icon(Icons.design_services_rounded),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const Spacer(), // so the rest of the column shows up at the bottom
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text('Enter API Key'),
                  titleTextStyle: Theme.of(context).textTheme.bodySmall,
                  leading: const Icon(Icons.key_rounded),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  tileColor: Colors.blue[800],
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text('Sign Up'),
                  titleTextStyle: Theme.of(context).textTheme.bodySmall,
                  leading: const Icon(Icons.person_add_rounded),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  tileColor: Colors.green[600],
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text('Login'),
                  titleTextStyle: Theme.of(context).textTheme.bodySmall,
                  leading: const Icon(Icons.login_rounded),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text('About'),
                  titleTextStyle: Theme.of(context).textTheme.bodySmall,
                  leading: const Icon(Icons.info_rounded),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding (
          padding: const EdgeInsets.all(4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 768,
            ),
            child: ListenableBuilder(
              listenable: data,
              builder: (context, child) {
                return Column(
                  children: [
                    DropdownMenu<String>(
                      dropdownMenuEntries: data.models.map(
                        (model) {
                          return DropdownMenuEntry(
                            label: model,
                            value: model,
                          );
                        },
                      ).toList(),
                      onSelected: (value) {
                        data.model = (value)!;
                      },
                    ),
                    ChatWindow(data: data),
                    MessageBox(data: data, keyDialog: keyDialog, api: api),
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
