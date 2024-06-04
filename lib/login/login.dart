import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpt_thing/theme.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/auth.dart';

class LoginPage extends StatelessWidget {
  final emailController;
  final passwordController;
  const LoginPage({super.key, this.emailController, this.passwordController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Column(children: [
            const FlutterLogo(size: 50),
            const SizedBox(
              height: 50,
            ),
            Text(
              "Welcome Back",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: GoogleFonts.notoSans().fontFamily
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: 350,
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  enabledBorder:  OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)
                  ),
                  focusedBorder:  OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green)
                  ),
                  hintText: "Email Address",
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: 350,
              child: TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  enabledBorder:  OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  focusedBorder:  OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green)
                  ),
                  hintText: 'Password',
                ),
              ),
            ),
            const SizedBox(height: 25),
            LoginButton(text: 'Sign in', icon: Icons.account_circle, color: Colors.green, loginMethod: AuthService().anonLogin, textColor: Colors.white, iconColor: Colors.white),
            const SizedBox(height: 25),
            const Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
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
                        Text("   OR   ",
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
                  )
              ),
            const SizedBox(height: 25),
            LoginButton(text: "Sign in with Google", icon: FontAwesomeIcons.google, color: Colors.white, loginMethod: AuthService().googleLogin, textColor: Colors.black, iconColor: Colors.black),
            const SizedBox(height: 25),
            FutureBuilder<Object>(
              future: SignInWithApple.isAvailable(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return LoginButton(text: "Sign in with Apple", icon: FontAwesomeIcons.apple, color: Colors.white, loginMethod: AuthService().signInWithApple, textColor: Colors.black, iconColor: Colors.black);
                } else {
                  return Container();
                }
              },
            ),
          ]),
        ),
      )
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;
  final Color textColor;
  final Color iconColor;

  const LoginButton({super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.loginMethod,
    required this.textColor,
    required this.iconColor
  });

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
          elevation: 5
        ),
        onPressed: () => loginMethod(),
        label: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontFamily: GoogleFonts.notoSans().fontFamily
          ),
        ),
      ),
    );
  }
}