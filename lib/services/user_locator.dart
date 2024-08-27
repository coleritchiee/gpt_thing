import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:gpt_thing/services/firestore.dart';

import 'models.dart' as u;

class UserLocator {
  static void setupLocator() {
    GetIt.I.registerSingleton<u.User>(u.User.NOT_SIGNED_IN);
  }

  static Future<void> setUserIfSignedIn() async{
    if(FirebaseAuth.instance.currentUser != null){
      u.User? newUser = await FirestoreService().getUserFromId(FirebaseAuth.instance.currentUser!.uid);
      FirestoreService().updateUser(newUser!);
    }
  }
}