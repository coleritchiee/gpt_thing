import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../home/chat_info.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      info.date = DateTime.now();
      info.title = data.id;
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

  Future<String> uploadImageToStorageFromLink(String b64) async {
    try {
      print("here");
      Uint8List imageData = base64Decode(b64);
      print("here2");
      final storageRef = FirebaseStorage.instance.ref();
      print("here3");
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      print("here4");
      var user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      final imageRef = storageRef.child('images/${user.uid}/$fileName.png');
      print("here5");

      final uploadTask = imageRef.putData(imageData);
      print("here6");
      final snapshot = await uploadTask.whenComplete(() => {});
      print("here7");
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("here8");

      return downloadUrl;
    } catch (e) {
      print('Error occurred while uploading image: $e');
      return '';
    }
  }
}