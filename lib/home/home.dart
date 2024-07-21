import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/chat_id_notifier.dart';
import 'package:gpt_thing/home/home_drawer.dart';
import 'package:gpt_thing/services/auth.dart';
import 'package:gpt_thing/services/firestore.dart';
import '../services/user_locator.dart';
import 'chat_info.dart';
import '../services/models.dart' as u;
import 'chat_window.dart';
import 'message_box.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ChatData data = ChatData();
    ScrollController scroller = ScrollController();
    u.User user = GetIt.I<u.User>();

    bool linkHover = false;

    void applyUserSettings() async {
      if (user.settings.saveAPIKey) {
        final validated = await data.setKey(user.apiKey!, user.org!, fromUser: true);
        if (validated) {
          data.applyDefaultModel(context);
        } else {
          user.updateSettings(user.settings.copyWith(saveAPIKey: false));
          FirestoreService().updateUser(user);
          if (context.mounted && ModalRoute.of(context)!.isCurrent) {
            showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("API Key Error"),
                content: const Text(
                    "Your saved API key failed to validate. Check your key, and set it again in settings."),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
                insetPadding: const EdgeInsets.all(24),
              );
            });
          }
        }
      }
    }

    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text('ChatKeyPT')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('ChatKeyPT'),
                forceMaterialTransparency: true,
              ),
              drawer: HomeDrawer(
                data: data,
                ids: ChatIdNotifier([]),
                user: user,
                onNewChatClick: () {},
                onIdClick: (info) {},
                onDelete: (index) {},
                onLogoutClick: () {},
              ),
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 768,
                      ),
                      child: ListenableBuilder(
                        listenable: data,
                        builder: (context, child) {
                          return Column(
                            children: [
                              ChatWindow(data: data, scroller: scroller),
                              Container(
                                margin: const EdgeInsets.all(16.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(25.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10.0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Text(
                                            "Please ",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          StatefulBuilder(
                                              builder: (context, setState) {
                                            return MouseRegion(
                                              onEnter: (event) {
                                                setState(() {
                                                  linkHover = true;
                                                });
                                              },
                                              onExit: (event) {
                                                setState(() {
                                                  linkHover = false;
                                                });
                                              },
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pushReplacementNamed(
                                                          '/login');
                                                },
                                                child: Text(
                                                  'sign in',
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 16.0,
                                                    decoration: linkHover
                                                        ? TextDecoration
                                                            .underline
                                                        : null,
                                                    decorationColor:
                                                        Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                          const Text(
                                            " to access chats.",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10.0),
                                  ],
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return FutureBuilder(
                future: UserLocator.setUserIfSignedIn(),
                builder: (context, snapshot) {
                  return FutureBuilder<List<ChatInfo>>(
                      future: FirestoreService()
                          .getChats(FirebaseAuth.instance.currentUser!.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Scaffold(
                            appBar: AppBar(title: const Text('ChatKeyPT')),
                            body: const Center(
                                child: CircularProgressIndicator()),
                          );
                        } else {
                          // USER IS FOUND, CONFIGURE SETTINGS HERE
                          ChatIdNotifier chatIds =
                              ChatIdNotifier(snapshot.data!);
                          return ListenableBuilder(
                              listenable: user,
                              builder: (context, snapshot) {
                                applyUserSettings();
                                return Scaffold(
                                    appBar: AppBar(
                                      title: const Text("ChatKeyPT"),
                                      forceMaterialTransparency: true,
                                    ),
                                    drawer: HomeDrawer(
                                      data: data,
                                      ids: chatIds,
                                      user: user,
                                      onNewChatClick: () {
                                        data.overwrite(ChatData());
                                        data.applyDefaultModel(context);
                                      },
                                      onIdClick: (info) async {
                                        ChatData? newData =
                                            await FirestoreService()
                                                .fetchChat(info.id);
                                        if (newData != null) {
                                          data.overwrite(newData);
                                          scroller.jumpTo(0);
                                        }
                                      },
                                      onDelete: (index) {
                                        FirestoreService()
                                            .removeIdFromUserAndDeleteChat(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                chatIds.get(index).id);
                                        chatIds.removeInfo(chatIds.get(index));
                                        data.overwrite(ChatData());
                                      },
                                      onLogoutClick: () {
                                        AuthService().signOut();
                                        user.overwrite(u.User.NOT_SIGNED_IN);
                                        data.overwrite(ChatData());
                                      },
                                    ),
                                    body: SafeArea(
                                      child: Center(
                                          child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxWidth: 768,
                                                  ),
                                                  child: ListenableBuilder(
                                                      listenable: data,
                                                      builder:
                                                          (context, child) {
                                                        return Column(
                                                          children: [
                                                            ChatWindow(
                                                                data: data,
                                                                scroller:
                                                                    scroller),
                                                            MessageBox(
                                                              data: data,
                                                              chatIds: chatIds,
                                                              chatScroller:
                                                                  scroller,
                                                            ),
                                                          ],
                                                        );
                                                      })))),
                                    ));
                              });
                        }
                      });
                });
          }
        });
  }
}
