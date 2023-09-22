import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_scheme.dart';

class CustomTheme {
  ThemeData buildLightTheme() {
    var baseTheme = ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
        brightness: Brightness.light);

    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
    );
  }

  ThemeData buildDarkTheme() {
    var baseTheme = ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple.shade800,
        brightness: Brightness.dark);

    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).copyWith(
        headlineSmall: TextStyle(color: Colors.white54),
        bodySmall: TextStyle(color: Colors.white54)
      ),
    );
  }
}
