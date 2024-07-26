import 'package:go_router/go_router.dart';
import 'package:gpt_thing/login/register.dart';

import 'home/home.dart';
import 'login/login.dart';

var appRoutes = [
  GoRoute(
    path: '/',
    builder: (context, state) => const HomePage(),
  ),
  GoRoute(
    path: '/login',
    builder: (context, state) => LoginPage(),
  ),
  GoRoute(
    path: '/register',
    builder: (context, state) => RegisterPage(),
  ),
];