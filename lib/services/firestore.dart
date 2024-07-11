import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/model_group.dart';
import 'package:gpt_thing/home/user_settings.dart';
import 'models.dart' as u;
import '../home/chat_info.dart';
import 'package:get_it/get_it.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<u.User?> getUserFromId(String uid) async{
    try {
      DocumentSnapshot userSnapshot = await _db.collection('users').doc(uid).get();
      return u.User.fromJson(userSnapshot.data() as Map<String, dynamic>);
    }
    catch(e){
      return u.User(uid: uid, name: "", settings: UserSettings.DEFAULT);
    }
  }

  Future<List<ChatInfo>> getChats(String uid) async {
    try {
      QuerySnapshot chatSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).collection('chatInfos').get();
      List<ChatInfo> chats = chatSnapshot.docs
          .map((doc) => ChatInfo.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return chats;
    } catch (e) {
      return [];
    }
  }

  Future<void> updateUser(u.User user) async {
    try{
      await _db.collection('users').doc(user.uid).set(user.toJson());
      GetIt.I<u.User>().overwrite(user);
    }
    catch(e){
      print(e.toString());
    }
  }

  Future<void> addChatInfoToUser(String userId, ChatInfo chatInfo) async {
    try {
      await _db.collection('users').doc(userId).collection('chatInfos').doc(chatInfo.id).set(chatInfo.toJson());
    } catch (e) {
      print('Error adding chat: $e');
      throw Exception('Failed to add chat: $e');
    }
  }

  ChatInfo updateInfo(ChatInfo info){
    CollectionReference chatInfos = _db.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).collection('chatInfos');
    info.date = DateTime.now();
    chatInfos.doc(info.id).set(info.toJson());
    return info;
  }

  ChatData updateChat(ChatData data, ChatInfo info){
    CollectionReference chats = _db.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).collection('chats');
    CollectionReference chatInfos = _db.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).collection('chatInfos');
    if (data.id == "") {
      var doc = chats.doc();
      data.setId(doc.id);
      doc.set(data.toJson());
      info.id = data.id;
      var infoDoc = chatInfos.doc(data.id);
      infoDoc.set(info.toJson());
    }
    else{
      chats.doc(data.id).set(data.toJson());
      addChatInfoToUser(FirebaseAuth.instance.currentUser!.uid, info);
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

  Future<ChatInfo?> fetchInfo(String chatId) async{
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return null;
    }
    try {
      DocumentSnapshot chatSnapshot = await _db.collection('users').doc(userId).collection('chatInfo').doc(chatId).get();
      if (chatSnapshot.exists) {
        return ChatInfo.fromJson(chatSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> removeIdFromUserAndDeleteChat(String userId, String chatId) async {
    DocumentReference userRef = _db.collection('users').doc(userId);
    DocumentReference chatRef = userRef.collection('chats').doc(chatId);
    DocumentReference chatInfoRef = _db.collection('users').doc(userId).collection('chatInfos').doc(chatId);
    try {
      DocumentSnapshot chat = await chatRef.get();
      var data = chat.data() as Map<String, dynamic>;
      if (ModelGroup.getByName(data["modelGroup"]) == ModelGroup.dalle) {
        deleteImageFromChat(chatId, userId);
      }
    }
    catch(e){}
    return _db.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw Exception("User not found");
      }
      transaction.delete(chatInfoRef);
      transaction.delete(chatRef);
    }).catchError((error) {
      throw Exception('Failed to remove chat ID and delete chat document: $error');
    });
  }

  Future<String> uploadImageToStorageFromLink(String b64, String chatId) async {
    try {
      Uint8List imageData = base64Decode(b64);
      final storageRef = FirebaseStorage.instance.ref();
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      var user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      final imageRef = storageRef.child('images/${user.uid}/$chatId/$fileName.png');
      final uploadTask = imageRef.putData(imageData);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error occurred while uploading image: $e');
      return '';
    }
  }

  Future<void> deleteImageFromChat(String chatId, String userId) async {
    final storageRef = FirebaseStorage.instance.ref();
    final chatImagesRef = storageRef.child('images/$userId/$chatId');

    try{
      final ListResult result = await chatImagesRef.listAll();
      List<Reference> allFiles = result.items;

      for (var fileRef in allFiles) {
        await fileRef.delete();
      }
    } catch (e) {
      print('Error occurred while deleting files: $e');
    }
  }
}