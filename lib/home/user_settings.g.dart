// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
      streamResponse: json['streamResponse'] as bool,
      generateTitles: json['generateTitles'] as bool,
      showSystemPrompt: json['showSystemPrompt'] as bool,
    );

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'streamResponse': instance.streamResponse,
      'generateTitles': instance.generateTitles,
      'showSystemPrompt': instance.showSystemPrompt,
    };
