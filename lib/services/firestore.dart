import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/services/user_provider.dart';

import 'models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ChatData>> getChats(String uid) async {
    try {
      var collection = _db.collection('chats');
      var snapshots = await collection.where('userId', isEqualTo: uid).get();
      var chats = snapshots.docs.map((doc) => ChatData.fromJson(doc.data())).toList();
      return chats;
    } catch (e) {
      throw Exception('Failed to fetch chats: $e');
    }
  }

  ChatData updateChat(ChatData data){
    CollectionReference chats = _db.collection('users').doc(UserProvider().currentUser?.uid).collection('chats');
    if (data.id == "") {
      var doc = chats.doc();
      data.setId(doc.id);
      doc.set(data.toJson());
    }
    else{
      chats.doc(data.id).set(data.toJson());
    }

    return data;
  }
}