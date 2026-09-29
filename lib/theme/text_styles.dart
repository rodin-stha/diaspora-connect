import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography from the Figma design (Manrope, plus Newsreader for the logo).
///
/// Styles hold size/weight/line-height only, never color: color depends on
/// the theme, so apply it at the call site with `context.colors`.
class TTextStyles {
  TTextStyles._();

  /// Manrope has no Devanagari glyphs, so Nepali text falls back to
  /// Noto Sans Devanagari.
  static final List<String> devanagariFallback = [
    GoogleFonts.notoSansDevanagari().fontFamily!,
  ];

  static TextStyle _manrope({
    required double fontSize,
    FontWeight? fontWeight,
    double? height,
  }) => GoogleFonts.manrope(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
  ).copyWith(fontFamilyFallback: devanagariFallback);

  static TextStyle get logo => GoogleFonts.newsreader(
    fontSize: 15,
    height: 1.2,
  ).copyWith(fontFamilyFallback: devanagariFallback);

  static TextStyle get headline => _manrope(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static TextStyle get titleLarge =>
      _manrope(fontSize: 20, fontWeight: FontWeight.w700, height: 1.25);

  static TextStyle get titleMedium => _manrope(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static TextStyle get titleSmall => _manrope(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  /// Body/Regular
  static TextStyle get body => _manrope(
    fontSize: 14,
    height: 1.4,
  );

  /// Body/Small
  static TextStyle get bodySmall => _manrope(
    fontSize: 12,
    height: 1.4,
  );

  /// Body/Label
  static TextStyle get label => _manrope(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static TextStyle get chipLabel =>
      _manrope(fontSize: 13, fontWeight: FontWeight.w700, height: 1.3);

  static TextStyle get caption => _manrope(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static TextStyle get navLabel =>
      _manrope(fontSize: 11, fontWeight: FontWeight.w600);
}
