import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

class Model {
  late String id;
  late String group;
  late bool preview;

  Model(this.id, List<ModelGroup> groups) {
    group = "Other";
    for (ModelGroup mg in groups) {
      if (id.startsWith(mg.prefix)) {
        group = mg.name;
        break;
      }
    }
    preview = id.endsWith("preview");
  }
}

class ModelGroup {
  String name;
  String prefix;
  String description;

  ModelGroup({required this.name, required this.prefix, required this.description});
}

class ChatData extends ChangeNotifier {
  final List<ModelGroup> groups = [
    ModelGroup(
      name: "ChatGPT",
      prefix: "gpt",
      description: "Natural language processing"
    ),
    ModelGroup(
      name: "Dall·E",
      prefix: "dall-e",
      description: "Generate and edit images"
    ),
    ModelGroup(
      name: "TTS",
      prefix: "tts",
      description: "Convert text to spoken audio"
    ),
    ModelGroup(
      name: "Whisper",
      prefix: "whisper",
      description: "Convert audio to text"
    ),
    ModelGroup(
      name: "Embeddings",
      prefix: "text-embedding",
      description: "Convert text to a numerical form"
    ),
    ModelGroup(
      name: "Other",
      prefix: "",
      description: "Specialized models"
    ),
  ];

  List<OpenAIChatCompletionChoiceMessageModel> messages = [];
  String apiKey = "";
  String organization = "";
  List<Model> models = <Model>[];
  String model = "";
  String modelGroup = "";

  void setKey(String key, String org) {
    apiKey = key;
    OpenAI.apiKey = apiKey;
    organization = org;
    if (organization.isNotEmpty) {
      OpenAI.organization = organization;
    }
  }

  void resetKey() {
    apiKey = "";
    OpenAI.apiKey = "";
    organization = "";
    OpenAI.organization = "";
  }

  void addModels(List<String> ids) {
    for (String id in ids) {
      models.add(Model(id, groups));
    }
    notifyListeners();
  }

  void setModel(String model, String group) {
    this.model = model;
    this.modelGroup = group;
    notifyListeners();
  }

  bool keyIsSet() {
    return apiKey.isNotEmpty;
  }

  bool modelChosen() {
    return model.isNotEmpty;
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
