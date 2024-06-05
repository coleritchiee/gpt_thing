import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


var appTheme = ThemeData(
  pageTransitionsTheme: PageTransitionsTheme(
    builders:{
      TargetPlatform.android: NoTransitionsBuilder(),
      TargetPlatform.iOS: NoTransitionsBuilder(),
      TargetPlatform.windows: NoTransitionsBuilder(),
      TargetPlatform.macOS: NoTransitionsBuilder(),
      TargetPlatform.linux: NoTransitionsBuilder(),
      TargetPlatform.fuchsia: NoTransitionsBuilder()
    }
  ),
  fontFamily: GoogleFonts.notoSans().fontFamily,
  brightness: Brightness.dark,
  textTheme: const TextTheme(
    bodySmall: TextStyle(fontSize: 16),
    bodyLarge: TextStyle(fontSize: 18),
    bodyMedium: TextStyle(fontSize: 16),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
    color: Colors.grey
    ),
  ),
);

class NoTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {

    return child;
  }
}