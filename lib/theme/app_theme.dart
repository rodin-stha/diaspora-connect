import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'text_styles.dart';

class TAppTheme {
  TAppTheme._();

  static final ThemeData light = _build(AppColors.light, Brightness.light);

  // To add dark mode:
  //   static final ThemeData dark = _build(AppColors.dark, Brightness.dark);
  // then in main.dart set `darkTheme: TAppTheme.dark` and
  // `themeMode: ThemeMode.system`.

  static ThemeData _build(AppColors colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.accent,
        onSecondary: colors.onAccent,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        outline: colors.border,
      ),
      fontFamily: GoogleFonts.manrope().fontFamily,
      fontFamilyFallback: TTextStyles.devanagariFallback,
      extensions: [colors],
    );
  }
}
