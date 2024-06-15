import 'package:json_annotation/json_annotation.dart';

part 'chat_info.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatInfo {
  String id;
  String title;
  DateTime date;

  ChatInfo({required this.id, required this.title, required this.date});

  void setTitle(String title){
    this.title = title;
  }

  factory ChatInfo.fromJson(Map<String, dynamic> json) => _$ChatInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatInfoToJson(this);
}