import 'package:gpt_thing/login/register.dart';
import 'package:gpt_thing/settings/settings.dart';

import 'home/home.dart';
import 'login/login.dart';

var appRoutes = {
  '': (context) => const HomePage(),
  '/login': (context) => LoginPage(),
  '/register': (context) => RegisterPage(),
  '/settings': (context) => const SettingsPage(),
};