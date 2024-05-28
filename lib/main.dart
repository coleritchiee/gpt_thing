import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gpt_thing/route.dart';
import 'package:gpt_thing/theme.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'home/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

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
        return Text('loading', textDirection: TextDirection.rtl);
      },
    );
  }
}