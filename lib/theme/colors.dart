import 'package:flutter/material.dart';

/// The app's color tokens, attached to [ThemeData] as a theme extension.
///
/// Names describe *purpose* (surface, textSecondary), never the literal color
/// (white, grey). That way a dark theme only needs a second [AppColors]
/// instance, and no widget has to change.
///
/// Read them in widgets with `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // Brand
  final Color primary; // blue: header, links
  final Color onPrimary; // text/icons on primary
  final Color onPrimarySubtle; // translucent fills on primary (language toggle)
  final Color accent; // crimson: main action, selected tab
  final Color onAccent; // text/icons on accent

  // Surfaces
  final Color background; // page background
  final Color surface; // cards, bottom nav
  final Color border;

  // Content
  final Color textPrimary;
  final Color textSecondary;
  final Color iconInactive;

  // Status
  final Color warningContainer;
  final Color onWarningContainer;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color infoContainer;
  final Color onInfoContainer;
  final Color successContainer;
  final Color onSuccessContainer;

  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.onPrimarySubtle,
    required this.accent,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.iconInactive,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.successContainer,
    required this.onSuccessContainer,
  });

  /// Values from the Figma design.
  static const light = AppColors(
    primary: Color(0xFF003893),
    onPrimary: Color(0xFFFFFFFF),
    onPrimarySubtle: Color(0x24FFFFFF), // 14% white
    accent: Color(0xFFC8102E),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFFFAFAF9),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFDFDBD0),
    textPrimary: Color(0xFF1C1B1A),
    textSecondary: Color(0xFF6B675F),
    iconInactive: Color(0xFF8A8676),
    warningContainer: Color(0xFFFDF0D5),
    onWarningContainer: Color(0xFF8A5A00),
    errorContainer: Color(0xFFFCE4E4),
    onErrorContainer: Color(0xFFB3261E),
    infoContainer: Color(0xFFE5E2F5),
    onInfoContainer: Color(0xFF4436B0),
    successContainer: Color(0xFFDEF2E4),
    onSuccessContainer: Color(0xFF1F7A4D),
  );

  // To add dark mode: define `static const dark = AppColors(...)` with the
  // designer's dark values, then see TAppTheme.dark.

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? onPrimarySubtle,
    Color? accent,
    Color? onAccent,
    Color? background,
    Color? surface,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? iconInactive,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? successContainer,
    Color? onSuccessContainer,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      onPrimarySubtle: onPrimarySubtle ?? this.onPrimarySubtle,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      iconInactive: iconInactive ?? this.iconInactive,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    );
  }

  /// Used by Flutter to animate smoothly when switching themes.
  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onPrimarySubtle: Color.lerp(onPrimarySubtle, other.onPrimarySubtle, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      iconInactive: Color.lerp(iconInactive, other.iconInactive, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(
        onErrorContainer,
        other.onErrorContainer,
        t,
      )!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
    );
  }
}

extension AppColorsContext on BuildContext {
  /// The current theme's colors, e.g. `context.colors.surface`.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
