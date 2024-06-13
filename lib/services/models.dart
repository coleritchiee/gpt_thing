import 'package:firebase_auth/firebase_auth.dart' as f;
import 'package:gpt_thing/services/firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  String uid;
  List<String> chatIds;

  static Future<User> userFromFireBaseUser(f.User user) async{
    return User(uid: user.uid, chatIds: await FirestoreService().getChats(user.uid));
  }

  User({required this.uid, required this.chatIds});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}