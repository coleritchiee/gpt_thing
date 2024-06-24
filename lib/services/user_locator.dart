import 'package:get_it/get_it.dart';

import 'models.dart';

class UserLocator {
  static void setupLocator() {
    GetIt.I.registerSingleton<User>(User.NOT_SIGNED_IN);
  }
}