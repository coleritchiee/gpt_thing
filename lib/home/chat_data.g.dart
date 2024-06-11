// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatData _$ChatDataFromJson(Map<String, dynamic> json) => ChatData()
  ..apiKey = json['apiKey'] as String
  ..organization = json['organization'] as String;

Map<String, dynamic> _$ChatDataToJson(ChatData instance) => <String, dynamic>{
      'apiKey': instance.apiKey,
      'organization': instance.organization,
    };
