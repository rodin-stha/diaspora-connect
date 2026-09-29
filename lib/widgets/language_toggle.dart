import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/locale_provider.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// The ने / EN switch shown in the home header. Changes the whole app's language.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;
    final notifier = ref.read(localeProvider.notifier);
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.onPrimarySubtle,
        borderRadius: BorderRadius.circular(TSizes.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'ने',
            semanticsLabel: 'नेपाली',
            isSelected: current == 'ne',
            onTap: () => notifier.setLocale(const Locale('ne')),
          ),
          _Segment(
            label: 'EN',
            semanticsLabel: 'English',
            isSelected: current == 'en',
            onTap: () => notifier.setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final String semanticsLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.semanticsLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? colors.onPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(TSizes.pillRadius),
          ),
          child: Text(
            label,
            style: TTextStyles.caption.copyWith(
              color: isSelected ? colors.primary : colors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
