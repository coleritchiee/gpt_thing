import 'package:flutter/material.dart';

class ChatMessage {
  bool user;
  String message;

  ChatMessage(this.user, this.message);
}

class ChatData extends ChangeNotifier {
  List<ChatMessage> messages = [];
  String apiKey = "";
  String? organization;

  void setKey(String key, String? org) {
    apiKey = key;
    organization = org;
  }

  bool keyIsSet() {
    return apiKey.isNotEmpty;
  }

  void addMessage(bool user, String message) {
    messages.add(ChatMessage(user, message));
    notifyListeners();
  }

  @override
  String toString() { // really just to be used for debugging
    String retStr = "ChatData Contents:";
    for (int i = 0; i < messages.length; i++) {
      retStr += "\n ${messages[i].user ? "User" : "ChatGPT"}:\n  ${messages[i].message}";
    }
    return retStr;
  }
}