import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import '../home/user_settings.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true)
class User extends ChangeNotifier{

  static User NOT_SIGNED_IN = User(uid: "", name: "", settings: UserSettings.DEFAULT);

  String uid;
  String name;
  String? apiKey;
  String? org;
  UserSettings settings;

  User({
    required this.uid,
    required this.name,
    required this.settings,
    this.apiKey,
    this.org
  });

  void updateSettings(UserSettings settings){
    this.settings = settings;
    notifyListeners();
  }

  void overwrite(User user){
    this.name = user.name;
    this.uid = user.uid;
    this.settings = user.settings;
    this.apiKey = user.apiKey;
    this.org = user.org;
    notifyListeners();
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}