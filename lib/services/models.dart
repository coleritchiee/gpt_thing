import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart' as f;
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/services/firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  String uid;
  List<ChatData> chats;

  static Future<User> userFromFireBaseUser(f.User user) async{
    return User(uid: user.uid, chats: await FirestoreService().getChats(user.uid));
  }

  User({required this.uid, required this.chats});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}