import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_data.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatData extends ChangeNotifier {
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<OpenAIChatCompletionChoiceMessageModel> messages = [];
  String id = "";
  @JsonKey(includeFromJson: false, includeToJson: false)
  String apiKey = "";
  @JsonKey(includeFromJson: false, includeToJson: false)
  String organization = "";

  ChatData();

  void overwrite(ChatData data){
    this.id = data.id;
    this.messages = data.messages;
    notifyListeners();
  }

  void setId(String id){
    this.id = id;
  }

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

  void addMessage(OpenAIChatMessageRole role, String message) {
    messages.add(OpenAIChatCompletionChoiceMessageModel(
      role: role,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
      ],
    ));
    notifyListeners();
  }

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData()
      ..id = json['id'] as String
      ..messages = (json['messages'] as List)
          .map((e) => OpenAIChatCompletionChoiceMessageModel.fromMap(e as Map<String, dynamic>))
          .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
