import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/auth.dart';

class LoginPage extends StatelessWidget {
  final String redirect;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  LoginPage({super.key, this.redirect = "/"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(children: [
                  SvgPicture.asset(
                    'assets/icon/icon.svg',
                    height: 75,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: GoogleFonts.notoSans().fontFamily),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 350,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green)),
                        hintText: "Email Address",
                        hintStyle: TextStyle(
                            color: Colors.green,
                            fontFamily: GoogleFonts.notoSans().fontFamily),
                      ),
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: GoogleFonts.notoSans().fontFamily),
                      cursorColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 350,
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green)),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                            color: Colors.green,
                            fontFamily: GoogleFonts.notoSans().fontFamily),
                      ),
                      obscureText: true,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: GoogleFonts.notoSans().fontFamily),
                      cursorColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 25),
                  EmailLoginButton(
                    text: 'Sign in',
                    icon: Icons.account_circle,
                    color: Colors.green,
                    textColor: Colors.white,
                    iconColor: Colors.white,
                    emailController: emailController,
                    passwordController: passwordController,
                    redirect: redirect,
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: SizedBox(
                        width: 400,
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "   OR   ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 25),
                  LoginButton(
                    text: "Sign in with Google",
                    icon: FontAwesomeIcons.google,
                    color: Colors.white,
                    loginMethod: AuthService().googleLogin,
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    redirect: redirect,
                  ),
                  const SizedBox(height: 25),
                  FutureBuilder<Object>(
                    future: SignInWithApple.isAvailable(),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return LoginButton(
                          text: "Sign in with Apple",
                          icon: FontAwesomeIcons.apple,
                          color: Colors.white,
                          loginMethod: AuthService().anonLogin,
                          textColor: Colors.black,
                          iconColor: Colors.black,
                          redirect: redirect,
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Not Registered?",
                          style: TextStyle(color: Colors.black)),
                      const SizedBox(width: 4),
                      InkWell(
                        child: Text("Register Now",
                            style: TextStyle(color: Colors.blue)),
                        onTap: () {
                          context.go("/register");
                        },
                      ),
                    ],
                  )
                ]),
              ),
            ),
          ),
        ));
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;
  final Color textColor;
  final Color iconColor;
  final String redirect;

  const LoginButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.color,
      required this.loginMethod,
      required this.textColor,
      required this.iconColor,
      required this.redirect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(24),
            backgroundColor: color,
            elevation: 5),
        onPressed: () async {
          try {
            await loginMethod();
            context.go(redirect);
          } on FirebaseAuthException catch (e) {
            print("Login failed: ${e.code}");
            print(e.stackTrace);
            return;
          }
        },
        label: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontFamily: GoogleFonts.notoSans().fontFamily),
        ),
      ),
    );
  }
}

class EmailLoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Color textColor;
  final Color iconColor;
  final emailController;
  final passwordController;
  final String redirect;

  const EmailLoginButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.color,
      required this.textColor,
      required this.iconColor,
      this.emailController,
      this.passwordController,
      required this.redirect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(24),
            backgroundColor: color,
            elevation: 5),
        onPressed: () async {
          try {
            await AuthService()
                .emailLogin(emailController.text, passwordController.text);
            context.go(redirect);
          } on FirebaseAuthException catch (e) {
            print(
                "Firebase Auth Exception: Code=${e.code}, Message=${e.message}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${e.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        label: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontFamily: GoogleFonts.notoSans().fontFamily),
        ),
      ),
    );
  }
}
