import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_thing/firebase_init.dart';
import 'package:gpt_thing/delete_account/delete_account.dart';
import 'package:gpt_thing/home/home.dart';
import 'package:gpt_thing/legal.dart';
import 'package:gpt_thing/login/login.dart';
import 'package:gpt_thing/login/register.dart';
import 'package:gpt_thing/services/user_locator.dart';
import 'package:gpt_thing/support/support.dart';
import 'package:gpt_thing/theme.dart';
import 'package:gpt_thing/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  UserLocator.setupLocator();
  runApp(
    App(),
  );
}

class App extends StatelessWidget {
  App({super.key});

  final Future<FirebaseApp> _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final String version = "v1.0.0";

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: GoRouter(
        onException: (context, state, router) {
          router.go('/');
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => FirebaseInit(
                init: _initialization,
                version: version,
                child: const HomePage()),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => FirebaseInit(
                init: _initialization, version: version, child: LoginPage()),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => FirebaseInit(
                init: _initialization, version: version, child: RegisterPage()),
          ),
          GoRoute(
            path: '/login-delete-account',
            builder: (context, state) => FirebaseInit(
              init: _initialization,
              version: version,
              child: LoginPage(redirect: "/delete-account"),
            ),
          ),
          GoRoute(
            path: '/delete-account',
            builder: (context, state) => FirebaseInit(
                init: _initialization,
                version: version,
                child: const DeleteAccountPage()),
          ),
          GoRoute(
            path: '/support',
            builder: (context, state) => FirebaseInit(
                init: _initialization,
                version: version,
                child: const SupportPage()),
          ),
          GoRoute(
            path: '/privacy',
            builder: (context, state) {
              openPrivacyPolicy(newWindow: false);
              return FirebaseInit(
                  init: _initialization,
                  version: version,
                  child: const HomePage());
            },
          ),
          GoRoute(
            path: '/tos',
            builder: (context, state) {
              openTOS(newWindow: false);
              return FirebaseInit(
                  init: _initialization,
                  version: version,
                  child: const HomePage());
            },
          ),
        ],
      ),
      theme: appTheme,
    );
  }
}
