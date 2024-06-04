import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

enum ChatRole {
  user,
  assistant,
  system,
}

class ChatMessage {
  ChatRole role;
  String message;

  ChatMessage(this.role, this.message);
}

class ChatData extends ChangeNotifier {
  List<ChatMessage> messages = [
    ChatMessage(ChatRole.system, "Respond to any prompt in a single sentence."),
  ];
  String apiKey = "";
  String organization = "";

  void setKey(String key, String org) {
    apiKey = key;
    OpenAI.apiKey = apiKey;
    organization = org;
    if (organization.isNotEmpty) {
      OpenAI.organization = organization;
    }
  }

  bool keyIsSet() {
    return apiKey.isNotEmpty;
  }

  void addMessage(ChatRole role, String message) {
    messages.add(ChatMessage(role, message));
    notifyListeners();
  }

  static String roleToString(ChatRole role) {
    switch (role) {
      case ChatRole.user:
        return "User";
      case ChatRole.assistant:
        return "ChatGPT";
      case ChatRole.system:
        return "System";
      default:
        return "Unknown";
    }
  }

  @override
  String toString() { // really just to be used for debugging
    String retStr = "ChatData Contents:";
    for (int i = 0; i < messages.length; i++) {
      retStr += "\n ${messages[i].role}:\n  ${messages[i].message}";
    }
    return retStr;
  }
}