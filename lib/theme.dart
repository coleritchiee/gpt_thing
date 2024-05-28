import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


var appTheme = ThemeData(
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
    color: Colors.grey
    ),
  ),
);
