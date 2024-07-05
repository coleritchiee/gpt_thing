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
    bodySmall: TextStyle(fontSize: 14),
    bodyLarge: TextStyle(fontSize: 18),
    bodyMedium: TextStyle(fontSize: 16),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: Colors.grey,
    ),
  ),
  tooltipTheme: TooltipThemeData(
    textStyle: const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey[850],
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