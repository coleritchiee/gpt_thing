import 'package:flutter/cupertino.dart';
import 'package:gpt_thing/home/user_settings.dart';
import 'package:gpt_thing/services/models.dart';

class UserNotifier extends ChangeNotifier{
  static User NOT_SIGNED_IN = User(uid: "", name: "", streamResponse: false, generateTitles: false, showSystemPrompt: false);

  User _user;

  UserNotifier(this._user);

  User getUser(){
    return _user;
  }

  UserSettings getUserSettings(){
    return _user.getSettings();
  }

  void updateUserSetting(UserSettings settings){
    _user.updateSettings(settings);
    notifyListeners();
  }

  void updateUser(User user){
    _user = user;
    notifyListeners();
  }
}