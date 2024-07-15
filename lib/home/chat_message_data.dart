import 'package:dart_openai/dart_openai.dart';

class ChatMessageData {
  OpenAIChatMessageRole role;
  DateTime timestamp;
  String? text;
  String? imageUrl;
  bool visible;
  String? model;
  int? inputTokens;
  int? outputTokens;

  ChatMessageData({
    required this.role,
    required this.timestamp,
    this.text,
    this.imageUrl,
    this.visible = true,
    this.model,
    this.inputTokens,
    this.outputTokens,
  });

  static List<OpenAIChatCompletionChoiceMessageModel> convertForAPI(
      List<ChatMessageData> data) {
    List<OpenAIChatCompletionChoiceMessageModel> apiList = [];
    for (final msg in data) {
      List<OpenAIChatCompletionChoiceMessageContentItemModel> content = [];
      if (msg.text != null) {
        content.add(
          OpenAIChatCompletionChoiceMessageContentItemModel.text(msg.text!)
        );
      }
      if (msg.imageUrl != null) {
        content.add(
          OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(msg.imageUrl!)
        );
      }
      if (content.isNotEmpty) {
        apiList.add(
          OpenAIChatCompletionChoiceMessageModel(
            role: msg.role,
            content: content,
          ),
        );
      }
    }
    return apiList;
  }

  factory ChatMessageData.fromJson(Map<String, dynamic> json) {
    return ChatMessageData(
      role: OpenAIChatMessageRole.values
          .firstWhere((role) => role.name == json['role']),
      timestamp: json['timestamp'] as DateTime,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String,
      visible: json['visible'] as bool,
      model: json['model'] as String,
      inputTokens: json['inputTokens'] as int,
      outputTokens: json['outputTokens'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'timestamp': timestamp,
      'text': text,
      'imageUrl': imageUrl,
      'visible': visible,
      'model': model,
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
    };
  }
}
