import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/locale_provider.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

enum LanguageToggleVariant {
  /// Small "ने / EN" switch on the blue Home header.
  compact,

  /// "नेपाली / English" pill on a light background (Profile).
  full,
}

/// Nepali/English switch. Changes the whole app's language.
///
/// Language names are always shown in their own language (not translated),
/// so people can find theirs whatever language the app is in.
class LanguageToggle extends ConsumerWidget {
  final LanguageToggleVariant variant;

  const LanguageToggle({
    super.key,
    this.variant = LanguageToggleVariant.compact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;
    final notifier = ref.read(localeProvider.notifier);
    final colors = context.colors;
    final isCompact = variant == LanguageToggleVariant.compact;

    final style = isCompact
        ? _SegmentStyle(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            textStyle: TTextStyles.caption,
            selectedBackground: colors.onPrimary,
            selectedForeground: colors.primary,
            unselectedForeground: colors.onPrimary,
          )
        : _SegmentStyle(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            textStyle: TTextStyles.label,
            selectedBackground: colors.primary,
            selectedForeground: colors.onPrimary,
            unselectedForeground: colors.textSecondary,
          );

    return Container(
      padding: const EdgeInsets.all(TSizes.xs),
      decoration: BoxDecoration(
        color: isCompact ? colors.onPrimarySubtle : colors.surface,
        border: isCompact ? null : Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(TSizes.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: isCompact ? 'ने' : 'नेपाली',
            semanticsLabel: 'नेपाली',
            isSelected: current == 'ne',
            style: style,
            onTap: () => notifier.setLocale(const Locale('ne')),
          ),
          if (!isCompact) const SizedBox(width: 6),
          _Segment(
            label: isCompact ? 'EN' : 'English',
            semanticsLabel: 'English',
            isSelected: current == 'en',
            style: style,
            onTap: () => notifier.setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }
}

class _SegmentStyle {
  final EdgeInsets padding;
  final TextStyle textStyle;
  final Color selectedBackground;
  final Color selectedForeground;
  final Color unselectedForeground;

  const _SegmentStyle({
    required this.padding,
    required this.textStyle,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.unselectedForeground,
  });
}

class _Segment extends StatelessWidget {
  final String label;
  final String semanticsLabel;
  final bool isSelected;
  final _SegmentStyle style;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.semanticsLabel,
    required this.isSelected,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticsLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: style.padding,
          decoration: BoxDecoration(
            color: isSelected ? style.selectedBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(TSizes.pillRadius),
          ),
          child: Text(
            label,
            style: style.textStyle.copyWith(
              color: isSelected
                  ? style.selectedForeground
                  : style.unselectedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
