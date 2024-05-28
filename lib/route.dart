import 'package:gpt_thing/settings/settings.dart';

import 'home/home.dart';
import 'login/login.dart';

var appRoutes = {
  '': (context) => const HomePage(),
  '/login': (context) => const LoginPage(),
  '/settings': (context) => const SettingsPage(),
};