// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      uid: json['uid'] as String,
      name: json['name'] as String,
      streamResponse: json['streamResponse'] as bool,
      generateTitles: json['generateTitles'] as bool,
      showSystemPrompt: json['showSystemPrompt'] as bool,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'streamResponse': instance.streamResponse,
      'generateTitles': instance.generateTitles,
      'showSystemPrompt': instance.showSystemPrompt,
    };
