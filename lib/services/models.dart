import 'package:firebase_auth/firebase_auth.dart' as f;
import 'package:json_annotation/json_annotation.dart';

import '../home/user_settings.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  String uid;
  String name;
  bool streamResponse;
  bool generateTitles;
  bool showSystemPrompt;

  User({
    required this.uid,
    required this.name,
    required this.streamResponse,
    required this.generateTitles,
    required this.showSystemPrompt,
  });

  UserSettings getSettings(){
    return UserSettings(streamResponse: streamResponse, generateTitles: generateTitles, showSystemPrompt: showSystemPrompt);
  }

  void updateSettings(UserSettings settings){
    this.streamResponse = settings.streamResponse;
    this.generateTitles = settings.generateTitles;
    this.showSystemPrompt = settings.showSystemPrompt;
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}