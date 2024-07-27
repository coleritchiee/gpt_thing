import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
            padding: const EdgeInsets.symmetric(vertical: 50),
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
                  Column(
                    children: [
                      SizedBox(
                        width: 350,
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            hintText: "Email Address",
                            hintStyle: TextStyle(
                                fontFamily: GoogleFonts.notoSans().fontFamily),
                          ),
                          style: TextStyle(
                              fontFamily: GoogleFonts.notoSans().fontFamily),
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
                                borderSide: BorderSide(color: Colors.white)),
                            hintText: 'Password',
                            hintStyle: TextStyle(
                                fontFamily: GoogleFonts.notoSans().fontFamily),
                          ),
                          obscureText: true,
                          style: TextStyle(
                              fontFamily: GoogleFonts.notoSans().fontFamily),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        child: TextField(
                          controller: passwordConfirmController,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(
                                fontFamily: GoogleFonts.notoSans().fontFamily),
                          ),
                          obscureText: true,
                          style: TextStyle(
                              fontFamily: GoogleFonts.notoSans().fontFamily),
                        ),
                      ),
                    ],
                  ),
                  EmailSignupButton(
                    text: 'Create Account',
                    icon: Icons.account_circle,
                    color: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    emailController: emailController,
                    passwordController: passwordController,
                    passwordConfirmController: passwordConfirmController,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: SizedBox(
                        width: 400,
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
                      )),
                  LoginButton(
                    text: "Sign in with Google",
                    icon: FontAwesomeIcons.google,
                    color: Colors.grey.shade800,
                    loginMethod: AuthService().googleLogin,
                    textColor: Colors.white,
                    iconColor: Colors.white,
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
                          loginMethod: AuthService().anonLogin,
                          textColor: Colors.white,
                          iconColor: Colors.white,
                          redirect: "/",
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      const SizedBox(width: 4),
                      InkWell(
                        child: const Text("Sign in",
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
    ));
  }
}

class EmailSignupButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Color textColor;
  final Color iconColor;
  final emailController;
  final passwordController;
  final passwordConfirmController;

  const EmailSignupButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.color,
      required this.textColor,
      required this.iconColor,
      this.emailController,
      this.passwordController,
      this.passwordConfirmController});

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
          if (passwordConfirmController.text != passwordController.text) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Passwords do not match"),
              backgroundColor: Colors.red,
            ));
            return;
          } else if (emailController.text.isEmpty ||
              !emailController.text.contains('@')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid email address.'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (passwordController.text.length < 6) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password must be at least 6 characters long.'),
                backgroundColor: Colors.red,
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
                  backgroundColor: Colors.red,
                ),
              );
            }
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
