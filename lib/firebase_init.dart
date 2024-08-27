import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gpt_thing/services/firestore.dart';
import 'package:gpt_thing/theme.dart';

class FirebaseInit extends StatelessWidget {
  final Future<FirebaseApp> init;
  final String version;
  final Widget child;

  const FirebaseInit(
      {super.key,
      required this.init,
      required this.version,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("${snapshot.error}", textDirection: TextDirection.rtl);
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder(
            future: FirestoreService().fetchCurrentVersion(),
            builder: (context, versionSnapshot) {
              if (versionSnapshot.connectionState == ConnectionState.waiting) {
                return MaterialApp(
                  theme: appTheme,
                    home: const Scaffold(
                        body: Center(child: CircularProgressIndicator())));
              } else if (versionSnapshot.hasError) {
                return MaterialApp(
                    home: Scaffold(
                        body: Center(
                            child: Text(
                                "Error fetching version info: ${versionSnapshot.error}"))));
              }

              if (versionSnapshot.data != version) {
                return MaterialApp(
                  theme: appTheme,
                  home: Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Update Available",
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Text(
                              "Your app version is $version, but the latest version is ${versionSnapshot.data}. Please update the app."),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return child;
            },
          );
        }
        return const Text('', textDirection: TextDirection.rtl);
      },
    );
  }
}
