import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gpt_thing/home/chat_data.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<String>> getChats(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>? ?? {};
        List<dynamic> chatIdsDynamic = userData['chatIds'] as List<dynamic>? ?? [];
        return List<String>.from(chatIdsDynamic.map((item) => item.toString()));
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> addChatIdToUser(String userId, String chatId) async {
    DocumentReference userDocRef = _db.collection('users').doc(userId);

    return _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDocRef);
      if (!snapshot.exists) {
        throw Exception("User not found");
      }
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>? ?? {};
      List<String> chatIds = List<String>.from(userData['chatIds'] as List<dynamic>? ?? []);
      if (!chatIds.contains(chatId)) {
        chatIds.add(chatId);
        transaction.update(userDocRef, {'chatIds': chatIds});
      }
    }).catchError((error) {
      throw Exception('Failed to add chat ID: $error');
    });
  }

  ChatData updateChat(ChatData data){
    CollectionReference chats = _db.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).collection('chats');
    if (data.id == "") {
      var doc = chats.doc();
      data.setId(doc.id);
      doc.set(data.toJson());
      addChatIdToUser(FirebaseAuth.instance.currentUser!.uid, data.id);
    }
    else{
      chats.doc(data.id).set(data.toJson());
    }
    return data;
  }

  Future<ChatData?> fetchChat(String chatId) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return null;
    }
    try {
      DocumentSnapshot chatSnapshot = await _db.collection('users').doc(userId).collection('chats').doc(chatId).get();
      if (chatSnapshot.exists) {
        return ChatData.fromJson(chatSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}