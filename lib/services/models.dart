import 'package:dart_openai/dart_openai.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  final String uid;
  final List<ChatData> chats;

  User({required this.uid, required this.chats});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

