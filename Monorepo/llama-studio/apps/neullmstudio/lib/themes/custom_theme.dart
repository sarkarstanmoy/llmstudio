import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_scheme.dart';

class CustomTheme {
  ThemeData buildLightTheme() {
    var baseTheme = ThemeData(useMaterial3: true, colorScheme: lightColorScheme);

    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
    );
  }

  ThemeData buildDarkTheme() {
    var baseTheme = ThemeData(useMaterial3: true,colorScheme: darkColorScheme);

    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
    );
  }
}