// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageData _$ChatMessageDataFromJson(Map<String, dynamic> json) =>
    ChatMessageData(
      role: $enumDecode(_$OpenAIChatMessageRoleEnumMap, json['role']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      text: json['text'] as String?,
      imageUrl: json['imageUrl'] as String?,
      visible: json['visible'] as bool? ?? true,
      model: json['model'] as String?,
      inputTokens: (json['inputTokens'] as num?)?.toInt(),
      outputTokens: (json['outputTokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChatMessageDataToJson(ChatMessageData instance) =>
    <String, dynamic>{
      'role': _$OpenAIChatMessageRoleEnumMap[instance.role]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'visible': instance.visible,
      'model': instance.model,
      'inputTokens': instance.inputTokens,
      'outputTokens': instance.outputTokens,
    };

const _$OpenAIChatMessageRoleEnumMap = {
  OpenAIChatMessageRole.system: 'system',
  OpenAIChatMessageRole.user: 'user',
  OpenAIChatMessageRole.assistant: 'assistant',
  OpenAIChatMessageRole.function: 'function',
  OpenAIChatMessageRole.tool: 'tool',
};
