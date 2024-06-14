import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_id_notifier.dart';

class HomeDrawer extends StatelessWidget{
  ChatIdNotifier ids;
  final Function() onNewChatClick;
  final Function(String) onIdClick;
  HomeDrawer({super.key, required this.ids, required this.onNewChatClick,required this.onIdClick});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                title: const Text('New Chat'),
                titleTextStyle: Theme.of(context).textTheme.bodySmall,
                leading: const Icon(Icons.chat_rounded),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                onTap: () {
                  onNewChatClick();
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            Expanded(
              child: ListenableBuilder(
                listenable: ids,
                builder: (context, snapshot) {
                  return ListView.separated(
                    itemCount: ids.size(),
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(ids.get(index)),
                        onTap: () {
                          onIdClick(ids.get(index));
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }
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
    );
  }
}