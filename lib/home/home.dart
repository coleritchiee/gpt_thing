import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gpt_thing/home/api_manager.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/chat_id_notifier.dart';
import 'package:gpt_thing/home/home_drawer.dart';
import 'package:gpt_thing/home/key_set_dialog.dart';
import 'package:gpt_thing/services/firestore.dart';
import 'chat_window.dart';
import 'message_box.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    APIManager api = APIManager();
    ChatData data = ChatData();
    KeySetDialog keyDialog = KeySetDialog(data: data);

    return FutureBuilder<List<String>>(
      future: FirestoreService().getChats(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        ChatIdNotifier chatIds = ChatIdNotifier(snapshot.data!);
        return Scaffold(
          appBar: AppBar(
            title: const Text('GPT Thing'),
            forceMaterialTransparency: true,
          ),
          drawer: HomeDrawer(
            ids: chatIds,
            onNewChatClick: (){
              data.overwrite(ChatData());
            },
            onIdClick: (id) async {
              ChatData? newData = await FirestoreService().fetchChat(id);
              if(newData !=null){
                data.overwrite(newData);
              }
            },
          ),
          body: Center(
            child: Padding (
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
                        MessageBox(data: data, keyDialog: keyDialog, api: api, chatIds: chatIds),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
