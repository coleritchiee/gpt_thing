import 'package:dart_openai/dart_openai.dart';

class ChatMessageData {
  OpenAIChatCompletionChoiceMessageModel message;
  bool visible;
  DateTime timestamp;
  String? model;
  int? inputTokens;
  int? outputTokens;

  ChatMessageData({
    required this.message,
    required this.visible,
    required this.timestamp,
    this.model,
    this.inputTokens,
    this.outputTokens,
  });

  static List<OpenAIChatCompletionChoiceMessageModel> convertForAPI(
      List<ChatMessageData> data) {
    List<OpenAIChatCompletionChoiceMessageModel> apiList = [];
    for (final msg in data) {
      apiList.add(msg.message);
    }
    return apiList;
  }

  factory ChatMessageData.fromJson(Map<String, dynamic> json) {
    return ChatMessageData(
      message: OpenAIChatCompletionChoiceMessageModel.fromMap(
          json['message'] as Map<String, dynamic>),
      visible: json['visible'] as bool,
      timestamp: json['modelGroup'] as DateTime,
    )
      ..model = json['model'] as String
      ..inputTokens = json['inputTokens'] as int
      ..outputTokens = json['outputTokens'] as int;
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'visible': visible,
      'timestamp': timestamp,
      'model': model,
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
    };
  }
}
