import 'package:firebase_auth/firebase_auth.dart' as f;
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  String uid;

  static Future<User> userFromFireBaseUser(f.User user) async{
    return User(uid: user.uid);
  }

  User({required this.uid});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}