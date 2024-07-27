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
        body: SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  children: [
                    SvgPicture.asset(
                      'assets/icon/icon.svg',
                      height: 75,
                    ),
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.notoSans().fontFamily),
                    ),
                    Wrap(
                      direction: Axis.vertical,
                      spacing: 10,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 350),
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              hintText: "Email Address",
                              hintStyle: TextStyle(
                                  fontFamily:
                                      GoogleFonts.notoSans().fontFamily),
                            ),
                            style: TextStyle(
                                fontFamily: GoogleFonts.notoSans().fontFamily),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 350),
                          child: TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                  fontFamily:
                                      GoogleFonts.notoSans().fontFamily),
                            ),
                            obscureText: true,
                            style: TextStyle(
                                fontFamily: GoogleFonts.notoSans().fontFamily),
                          ),
                        ),
                      ],
                    ),
                    EmailLoginButton(
                      emailController: emailController,
                      passwordController: passwordController,
                      redirect: redirect,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey.shade100,
                            ),
                          ),
                          const Text(
                            "   OR   ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey.shade100,
                            ),
                          ),
                        ],
                      ),
                    ),
                    LoginButton(
                      text: "Sign in with Google",
                      icon: FontAwesomeIcons.google,
                      color: Colors.grey.shade800,
                      loginMethod: AuthService().googleLogin,
                      redirect: redirect,
                    ),
                    FutureBuilder<Object>(
                      future: SignInWithApple.isAvailable(),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return LoginButton(
                            text: "Sign in with Apple",
                            icon: FontAwesomeIcons.apple,
                            color: Colors.grey.shade800,
                            loginMethod: AuthService().anonLogin,
                            redirect: redirect,
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Not registered?"),
                        const SizedBox(width: 4),
                        InkWell(
                          child: const Text("Register Now",
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
      ),
    ));
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;
  final String redirect;

  const LoginButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.color,
      required this.loginMethod,
      required this.redirect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          color: Colors.white,
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
              color: Colors.white,
              fontFamily: GoogleFonts.notoSans().fontFamily),
        ),
      ),
    );
  }
}

class EmailLoginButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String redirect;

  const EmailLoginButton(
      {super.key,
      required this.emailController,
      required this.passwordController,
      required this.redirect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: ElevatedButton.icon(
        icon: const Icon(
          Icons.account_circle_rounded,
          color: Colors.black,
          size: 20,
        ),
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(24),
            backgroundColor: Colors.white,
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
              ),
            );
          }
        },
        label: Text(
          "Sign In",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: GoogleFonts.notoSans().fontFamily),
        ),
      ),
    );
  }
}
