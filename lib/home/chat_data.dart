import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class ChatData extends ChangeNotifier {
  // included fields
  List<OpenAIChatCompletionChoiceMessageModel> messages = [];
  String id = "";
  String model = "";
  String modelGroup = "";

  // excluded fields
  @JsonKey(includeFromJson: false, includeToJson: false)
  String apiKey = "";
  @JsonKey(includeFromJson: false, includeToJson: false)
  String organization = "";
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Model> models = <Model>[];
  @JsonKey(includeFromJson: false, includeToJson: false)
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
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool _thinking = false;

  ChatData();

  void overwrite(ChatData data){
    id = data.id;
    messages = data.messages;
    model = data.model;
    modelGroup = data.modelGroup;
    _thinking = false;
    notifyListeners();
  }

  void setId(String id){
    this.id = id;
    notifyListeners();
  }

  void setKey(String key, String org) {
    apiKey = key;
    OpenAI.apiKey = apiKey;
    organization = org;
    if (organization.isNotEmpty) {
      OpenAI.organization = organization;
    }
    notifyListeners();
  }

  void resetKey() {
    apiKey = "";
    OpenAI.apiKey = "";
    organization = "";
    OpenAI.organization = "";
    notifyListeners();
  }

  void addModels(List<String> ids) {
    models.clear();
    for (String id in ids) {
      models.add(Model(id, groups));
    }
    notifyListeners();
  }

  void setModel(String model, String group) {
    this.model = model;
    modelGroup = group;
    notifyListeners();
  }

  bool keyIsSet() {
    return apiKey.isNotEmpty;
  }

  bool modelChosen() {
    return model.isNotEmpty;
  }

  void setThinking(bool t) {
    _thinking = t;
    notifyListeners();
  }

  bool isThinking() {
    return _thinking;
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

  void addImage(OpenAIChatMessageRole role, String url) {
    messages.add(OpenAIChatCompletionChoiceMessageModel(
      role: role,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(url),
      ],
    ));
    notifyListeners();
  }

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData()
      ..id = json['id'] as String
      ..model = json['model'] as String
      ..modelGroup = json['modelGroup'] as String
      ..messages = (json['messages'] as List)
          .map((e) => OpenAIChatCompletionChoiceMessageModel.fromMap(e as Map<String, dynamic>))
          .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'modelGroup': modelGroup,
      'messages': messages.map((message) => message.toMap()).toList(),
    };
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
