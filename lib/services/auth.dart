import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gpt_thing/services/user_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'models.dart' as u;

class AuthService {
  final userStream = FirebaseAuth.instance.authStateChanges();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> anonLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      u.User newUser = await u.User.userFromFireBaseUser(userCredential.user!);
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set(newUser.toJson());
      UserProvider().signIn(newUser);
        } on FirebaseAuthException {
      //handle error
    }
  }

  Future<void> emailLogin(email, password) async{
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    u.User newUser = await u.User.userFromFireBaseUser(userCredential.user!);
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set(newUser.toJson());
    UserProvider().signIn(newUser);
  }

  Future<void> emailSignup(email, password) async{
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    u.User newUser = await u.User.userFromFireBaseUser(userCredential.user!);
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set(newUser.toJson());
    UserProvider().signIn(newUser);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    UserProvider().signOut();
  }

  Future<void> googleLogin() async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(authCredential);
      u.User newUser = await u.User.userFromFireBaseUser(userCredential.user!);
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set(newUser.toJson());
      UserProvider().signIn(newUser);
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    u.User newUser = await u.User.userFromFireBaseUser(userCredential.user!);
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set(newUser.toJson());
    UserProvider().signIn(newUser);
    return userCredential;
  }
}