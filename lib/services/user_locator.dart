import 'package:get_it/get_it.dart';
import 'package:gpt_thing/services/user_notifier.dart';

class UserLocator {
  static void setupLocator() {
    GetIt.I.registerSingleton<UserNotifier>(UserNotifier(UserNotifier.NOT_SIGNED_IN));
  }
}