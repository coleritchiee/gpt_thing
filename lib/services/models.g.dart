// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      uid: json['uid'] as String,
      name: json['name'] as String,
      settings: UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
      apiKey: json['apiKey'] as String?,
      org: json['org'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'apiKey': instance.apiKey,
      'org': instance.org,
      'settings': instance.settings.toJson(),
    };
