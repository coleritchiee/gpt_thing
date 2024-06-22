// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_WEB_KEY']!,
    appId: '1:202585147455:web:90d85427998c730715508a',
    messagingSenderId: '202585147455',
    projectId: 'gptthing-a25d7',
    authDomain: 'gptthing-a25d7.firebaseapp.com',
    storageBucket: 'gptthing-a25d7.appspot.com',
    measurementId: 'G-FXH7H5ZG85',
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_ANDROID_KEY']!,
    appId: '1:202585147455:android:daf36b76f293f01315508a',
    messagingSenderId: '202585147455',
    projectId: 'gptthing-a25d7',
    storageBucket: 'gptthing-a25d7.appspot.com',
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_IOS_KEY']!,
    appId: '1:202585147455:ios:fe93b93a0b9caca115508a',
    messagingSenderId: '202585147455',
    projectId: 'gptthing-a25d7',
    storageBucket: 'gptthing-a25d7.appspot.com',
    iosBundleId: 'net.iicosahedra.gptThing',
  );

}