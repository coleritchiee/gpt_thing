import 'package:firebase_auth/firebase_auth.dart' as f;
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import '../home/user_settings.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true)
class User extends ChangeNotifier{

  static User NOT_SIGNED_IN = User(uid: "", name: "", streamResponse: false, generateTitles: false, showSystemPrompt: false);

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
    notifyListeners();
  }

  void overwrite(User user){
    this.name = user.name;
    this.uid = user.uid;
    this.showSystemPrompt = user.showSystemPrompt;
    this.generateTitles = user.generateTitles;
    this.streamResponse = user.streamResponse;
    notifyListeners();
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}