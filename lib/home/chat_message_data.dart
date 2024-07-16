import 'package:dart_openai/dart_openai.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_message_data.g.dart';

@JsonSerializable(explicitToJson: true)
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
            OpenAIChatCompletionChoiceMessageContentItemModel.text(msg.text!));
      }
      if (msg.imageUrl != null) {
        content.add(OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
            msg.imageUrl!));
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

  factory ChatMessageData.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDataFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageDataToJson(this);
}
