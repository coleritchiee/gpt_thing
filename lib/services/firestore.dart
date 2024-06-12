import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gpt_thing/home/chat_data.dart';

import 'models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ChatData>> getChats(User user) async {
    try {
      var collection = _db.collection('chats');
      var snapshots = await collection.where('userId', isEqualTo: user.uid).get();
      var chats = snapshots.docs.map((doc) => ChatData.fromJson(doc.data())).toList();
      return chats;
    } catch (e) {
      throw Exception('Failed to fetch chats: $e');
    }
  }
}