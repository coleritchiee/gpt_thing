import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gpt_thing/home/chat_id_notifier.dart';
import 'package:gpt_thing/home/chat_info.dart';
import 'package:gpt_thing/home/chat_sidebar_button.dart';
import 'package:gpt_thing/services/auth.dart';
import 'package:gpt_thing/services/firestore.dart';

class HomeDrawer extends StatelessWidget{
  ChatIdNotifier ids;
  final Function() onNewChatClick;
  final Function() onLogoutClick;
  final Function(ChatInfo) onIdClick;
  HomeDrawer({super.key, required this.ids, required this.onNewChatClick, required this.onIdClick, required this.onLogoutClick});

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
                      return ChatSidebarButton(
                          title: ids.get(index).title,
                          onRename: (){
                            _showRenameDialog(context, ids.get(index), index, ids);
                            },
                          onDelete: (){
                            FirestoreService().removeIdFromUserAndDeleteChat(FirebaseAuth.instance.currentUser!.uid, ids.get(index).id);
                            ids.removeInfo(ids.get(index));
                          },
                          onClick: () {
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
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  User? user = snapshot.data;
                  if (user == null) {
                    return Column(
                      children: [
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
                              Navigator.of(context).pushReplacementNamed('/register');
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
                              Navigator.of(context).pushReplacementNamed('/login');
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ListTile(
                        title: const Text('Logout'),
                        titleTextStyle: Theme.of(context).textTheme.bodySmall,
                        leading: const Icon(Icons.logout_rounded),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        onTap: () async {
                          onLogoutClick();
                        },
                      ),
                    );
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
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

  void _showRenameDialog(BuildContext context, ChatInfo chatInfo, int index, ChatIdNotifier chatIds) {
    TextEditingController renameController = TextEditingController(text: chatInfo.title);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 100,
          width: 350,
          child: AlertDialog(
            title: const Text("Rename Chat"),
            content: SizedBox(
              width: 300,
              child: TextFormField(
                autofocus: true,
                controller: renameController,
                decoration: const InputDecoration(
                  hintText: "Enter new name",
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Save"),
                onPressed: () {
                  chatIds.setTitleById(chatInfo.id, renameController.text);
                  FirestoreService().updateInfo(chatIds.getById(chatInfo.id)!);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}