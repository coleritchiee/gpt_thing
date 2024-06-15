import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gpt_thing/home/api_manager.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/chat_id_notifier.dart';
import 'package:gpt_thing/home/home_drawer.dart';
import 'package:gpt_thing/home/key_set_dialog.dart';
import 'package:gpt_thing/services/firestore.dart';
import 'chat_info.dart';
import 'chat_window.dart';
import 'message_box.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    APIManager api = APIManager();
    ChatData data = ChatData();
    KeySetDialog keyDialog = KeySetDialog(data: data);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('GPT Thing')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('GPT Thing'),
              forceMaterialTransparency: true,
            ),
            drawer: HomeDrawer(
              ids: ChatIdNotifier([]),
              onNewChatClick: () {
                data.overwrite(ChatData());
              },
              onIdClick: (info) async {
                ChatData? newData = await FirestoreService().fetchChat(
                    info.id);
                if (newData != null) {
                  data.overwrite(newData);
                }
              },
            ),
            body: Center(
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
                          ChatWindow(data: data),
                          Container(
                            margin: const EdgeInsets.all(16.0),
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(25.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10.0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Please sign in to access your chats.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.0),
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
          );
        }
        else {
          return FutureBuilder<List<ChatInfo>>(
              future: FirestoreService().getChats(
                  FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('GPT Thing')),
                    body: const Center(child: CircularProgressIndicator()),
                  );
                }
                else {
                  ChatIdNotifier chatIds = ChatIdNotifier(snapshot.data!);
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('GPT Thing'),
                      forceMaterialTransparency: true,
                    ),
                    drawer: HomeDrawer(
                      ids: chatIds,
                      onNewChatClick: () {
                        data.overwrite(ChatData());
                      },
                      onIdClick: (info) async {
                        ChatData? newData = await FirestoreService().fetchChat(
                            info.id);
                        if (newData != null) {
                          data.overwrite(newData);
                        }
                      },
                    ),
                    body: Center(
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
                                  ChatWindow(data: data),
                                  MessageBox(data: data,
                                      keyDialog: keyDialog,
                                      api: api,
                                      chatIds: chatIds),
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
          );
        }
      }
    );
  }
}
