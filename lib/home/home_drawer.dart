import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_thing/home/about_dialog.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/chat_id_notifier.dart';
import 'package:gpt_thing/home/chat_info.dart';
import 'package:gpt_thing/home/chat_sidebar_button.dart';
import 'package:gpt_thing/home/settings_dialog.dart';
import 'package:gpt_thing/services/firestore.dart';
import '../services/models.dart' as u;

class HomeDrawer extends StatelessWidget {
  final ChatIdNotifier ids;
  final ChatData data;
  final u.User user;
  final Function() onNewChatClick;
  final Function(ChatInfo) onIdClick;
  final Function() onLogoutClick;
  final Function(int) onDelete;

  const HomeDrawer(
      {super.key,
      required this.ids,
      required this.data,
      required this.user,
      required this.onNewChatClick,
      required this.onIdClick,
      required this.onLogoutClick,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const LinearBorder(),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  const ListTile(
                    title: Text('ChatKeyPT'),
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
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListenableBuilder(
                  listenable: ids,
                  builder: (context, snapshot) {
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: ids.size(),
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return Material(
                          color: Colors.transparent,
                          child: ChatSidebarButton(
                            title: ids.get(index).title,
                            onRename: () {
                              _showRenameDialog(
                                  context, ids.get(index), index, ids);
                            },
                            onDelete: () {
                              onDelete(index);
                            },
                            onClick: () {
                              onIdClick(ids.get(index));
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  }),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
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
                                  titleTextStyle:
                                      Theme.of(context).textTheme.bodySmall,
                                  leading: const Icon(Icons.person_add_rounded),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  tileColor: Colors.green.shade600,
                                  onTap: () {
                                    context.go('/register');
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ListTile(
                                  title: const Text('Login'),
                                  titleTextStyle:
                                      Theme.of(context).textTheme.bodySmall,
                                  leading: const Icon(Icons.login_rounded),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  onTap: () {
                                    context.go('/login');
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ListTile(
                                  title: const Text('About'),
                                  titleTextStyle:
                                      Theme.of(context).textTheme.bodySmall,
                                  leading: const Icon(Icons.info_rounded),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showAbout(context);
                                  },
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ListTile(
                                  title: const Text('Logout'),
                                  titleTextStyle:
                                      Theme.of(context).textTheme.bodySmall,
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ListTile(
                                  title: const Text('Settings'),
                                  titleTextStyle:
                                      Theme.of(context).textTheme.bodySmall,
                                  leading: const Icon(Icons.settings),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showSettingsDialog(context);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ListTile(
                                  title: const Text('About'),
                                  titleTextStyle:
                                      Theme.of(context).textTheme.bodySmall,
                                  leading: const Icon(Icons.info_rounded),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showAbout(context);
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, ChatInfo chatInfo, int index,
      ChatIdNotifier chatIds) {
    TextEditingController renameController =
        TextEditingController(text: chatInfo.title);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        void rename() {
          chatIds.setTitleById(chatInfo.id, renameController.text);
          FirestoreService().updateInfo(chatIds.getById(chatInfo.id)!);
          Navigator.of(context).pop();
        }

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
                onFieldSubmitted: (val) => rename(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: rename,
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    TextEditingController nameController =
        TextEditingController(text: user.name);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SettingsDialog(
          data: data,
          nameController: nameController,
          user: user,
        );
      },
    );
  }
}

void _showAbout(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: "ChatKeyPT",
    applicationVersion: "1.0.0",
    applicationIcon: Image.asset(
      "assets/icon/icon.png",
      width: 50,
      height: 50,
    ),
    applicationLegalese: "\u{a9} 2024 Silver Pangolin",
    children: [
      const About(),
    ],
  );
}
