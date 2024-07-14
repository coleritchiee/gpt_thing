// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
      streamResponse: json['streamResponse'] as String,
      generateTitles: json['generateTitles'] as bool,
      defaultModel: json['defaultModel'] as String,
      defaultModelGroup: json['defaultModelGroup'] as String,
      showSystemPrompt: json['showSystemPrompt'] as bool,
      saveAPIKey: json['saveAPIKey'] as bool,
    );

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'streamResponse': instance.streamResponse,
      'generateTitles': instance.generateTitles,
      'defaultModel': instance.defaultModel,
      'defaultModelGroup': instance.defaultModelGroup,
      'showSystemPrompt': instance.showSystemPrompt,
      'saveAPIKey': instance.saveAPIKey,
    };
