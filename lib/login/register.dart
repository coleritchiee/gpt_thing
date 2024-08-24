import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpt_thing/legal.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/auth.dart';
import 'login.dart';

class RegisterPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  RegisterPage({super.key});

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
                      "Register",
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
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 350),
                          child: TextField(
                            controller: passwordConfirmController,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              hintText: 'Confirm Password',
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
                    EmailSignupButton(
                      emailController: emailController,
                      passwordController: passwordController,
                      passwordConfirmController: passwordConfirmController,
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
                      redirect: "/",
                    ),
                    FutureBuilder<Object>(
                      future: SignInWithApple.isAvailable(),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return LoginButton(
                            text: "Sign in with Apple",
                            icon: FontAwesomeIcons.apple,
                            color: Colors.grey.shade800,
                            loginMethod: AuthService().signInWithApple,
                            redirect: "/",
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: GoogleFonts.notoSans().fontFamily,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                                text: "By registering, you agree to our "),
                            TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = openPrivacyPolicy),
                            const TextSpan(text: " and "),
                            TextSpan(
                                text: "Terms of Service",
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = openTOS),
                            const TextSpan(text: "."),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        InkWell(
                          child: const Text("Sign In",
                              style: TextStyle(color: Colors.blue)),
                          onTap: () {
                            context.go("/login");
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

class EmailSignupButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;

  const EmailSignupButton(
      {super.key,
      required this.emailController,
      required this.passwordController,
      required this.passwordConfirmController});

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
          if (passwordConfirmController.text != passwordController.text) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Passwords do not match"),
            ));
            return;
          } else if (emailController.text.isEmpty ||
              !emailController.text.contains('@')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid email address.'),
              ),
            );
          } else if (passwordController.text.length < 6) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password must be at least 6 characters long.'),
              ),
            );
          } else {
            try {
              await AuthService()
                  .emailSignup(emailController.text, passwordController.text);
              context.go('/');
            } on FirebaseAuthException catch (e) {
              print(
                  "Firebase Auth Exception: Code=${e.code}, Message=${e.message}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${e.message}'),
                ),
              );
            }
          }
        },
        label: Text(
          "Create Account",
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
