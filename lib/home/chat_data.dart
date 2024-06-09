import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

class Model {
  late String id;
  late String group;
  late bool preview;

  Model(this.id, Map groups) {
    group = "Other";
    for (String key in groups.keys) {
      if (id.startsWith(groups[key])) {
        group = key;
        break;
      }
    }
    preview = id.endsWith("preview");
  }
}

class ChatData extends ChangeNotifier {
  final Map groups = {
    "ChatGPT" : "gpt",
    "Dall·E" : "dall-e",
    "Other" : "",
  };

  List<OpenAIChatCompletionChoiceMessageModel> messages = [];
  String apiKey = "";
  String organization = "";
  List<Model> models = <Model>[];
  String model = "";

  void setKey(String key, String org) {
    apiKey = key;
    OpenAI.apiKey = apiKey;
    organization = org;
    if (organization.isNotEmpty) {
      OpenAI.organization = organization;
    }
  }

  void addModels(List<String> ids) {
    for (String id in ids) {
      models.add(Model(id, groups));
    }
    notifyListeners();
  }

  void setModel(String model) {
    this.model = model;
    notifyListeners();
  }

  bool keyIsSet() {
    return apiKey.isNotEmpty;
  }

  void addMessage(OpenAIChatMessageRole role, String message) {
    messages.add(OpenAIChatCompletionChoiceMessageModel(
      role: role,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
      ],
    ));
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
  String toString() {
    // really just to be used for debugging
    // TODO: remove this eventually
    String retStr = "ChatData Contents:";
    for (int i = 0; i < messages.length; i++) {
      retStr += "\n ${messages[i].role}:\n  ${(messages[i].content)![0].text}";
    }
    return retStr;
  }
}
