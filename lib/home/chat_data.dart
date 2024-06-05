import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

class ChatMessage {
  OpenAIChatMessageRole role;
  String message;

  ChatMessage(this.role, this.message);
}

class ChatData extends ChangeNotifier {
  List<ChatMessage> messages = [];
  String apiKey = "";
  String organization = "";
  List<String> models = <String>[];
  String model = "";

  void setKey(String key, String org) {
    apiKey = key;
    OpenAI.apiKey = apiKey;
    organization = org;
    if (organization.isNotEmpty) {
      OpenAI.organization = organization;
    }
  }

  void addModels(List<String> models) {
    this.models = models;
    notifyListeners();
  }

  void setModel(String model) {
    this.model = model;
  }

  bool keyIsSet() {
    return apiKey.isNotEmpty;
  }

  void addMessage(OpenAIChatMessageRole role, String message) {
    messages.add(ChatMessage(role, message));
    notifyListeners();
  }

  static String roleToString(OpenAIChatMessageRole role) {
    switch (role) {
      case OpenAIChatMessageRole.user:
        return "User";
      case OpenAIChatMessageRole.assistant:
        return "ChatGPT";
      case OpenAIChatMessageRole.system:
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