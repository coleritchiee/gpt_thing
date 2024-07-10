import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:gpt_thing/route.dart';
import 'package:gpt_thing/services/user_locator.dart';
import 'package:gpt_thing/theme.dart';
import 'package:gpt_thing/firebase_options.dart';
import 'package:gpt_thing/home/home.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  UserLocator.setupLocator();
  runApp(
  const App(),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("${snapshot.error}", textDirection: TextDirection.rtl);
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
                  routes: appRoutes,
                  theme: appTheme,
                  home: const HomePage(),
            );
          }
          return const Text('loading', textDirection: TextDirection.rtl);
        },
    );
  }
}