import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'sizes.dart';
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
      // Every TextField/TextFormField/Dropdown gets this look by default,
      // like a global CSS rule for inputs.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        hintStyle: TTextStyles.body.copyWith(color: colors.textSecondary),
        errorStyle: TTextStyles.bodySmall.copyWith(
          color: colors.onErrorContainer,
        ),
        errorMaxLines: 2,
        border: _inputBorder(colors.border),
        enabledBorder: _inputBorder(colors.border),
        focusedBorder: _inputBorder(colors.primary, width: 1.5),
        errorBorder: _inputBorder(colors.onErrorContainer),
        focusedErrorBorder: _inputBorder(colors.onErrorContainer, width: 1.5),
      ),
      // Main call-to-action button ("Save changes", "Continue").
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.buttonRadius),
          ),
          textStyle: TTextStyles.button,
        ),
      ),
      fontFamily: GoogleFonts.manrope().fontFamily,
      fontFamilyFallback: TTextStyles.devanagariFallback,
      extensions: [colors],
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: BorderSide(color: color, width: width),
      );
}
