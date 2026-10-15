import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/load_error.dart';
import '../../platform_settings/data/platform_settings_provider.dart';
import '../../platform_settings/models/platform_settings.dart';

/// Shows a number from the platform settings (SOS, helpline) with a button
/// to call it.
///
/// A sheet instead of dialing straight away: one more tap guards against
/// calling an emergency number by accident.
void showCallSheet(
  BuildContext context, {
  required String title,
  required String? Function(PlatformSettings settings) numberOf,
}) => showModalBottomSheet<void>(
  context: context,
  backgroundColor: context.colors.surface,
  showDragHandle: true,
  builder: (_) => CallSheet(title: title, numberOf: numberOf),
);

class CallSheet extends ConsumerStatefulWidget {
  final String title;

  /// Picks this sheet's number out of the settings.
  final String? Function(PlatformSettings settings) numberOf;

  const CallSheet({super.key, required this.title, required this.numberOf});

  @override
  ConsumerState<CallSheet> createState() => _CallSheetState();
}

class _CallSheetState extends ConsumerState<CallSheet> {
  bool _callFailed = false;

  Future<void> _call(String number) async {
    // Keep digits and a leading "+": "+977 1-4200000" → "+97714200000".
    final dialable = number.replaceAll(RegExp(r'[^\d+]'), '');
    final started = await launchUrl(Uri(scheme: 'tel', path: dialable));
    // E.g. on a tablet or simulator, which can't make calls. Shown in the
    // sheet: a SnackBar would hide behind it.
    if (!started && mounted) setState(() => _callFailed = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final settingsAsync = ref.watch(platformSettingsProvider);

    final Widget content = switch (settingsAsync) {
      AsyncValue(:final value?) => switch (widget.numberOf(value)) {
        final number? => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: TSizes.lg,
          children: [
            // Selectable, so it can be copied if calling from here fails.
            SelectableText(
              number,
              textAlign: TextAlign.center,
              style: TTextStyles.headline.copyWith(color: colors.textPrimary),
            ),
            FilledButton.icon(
              onPressed: () => _call(number),
              icon: const Icon(Icons.call),
              label: Text(l10n.callAction),
            ),
            if (_callFailed)
              Text(
                l10n.errorStartCall,
                textAlign: TextAlign.center,
                style: TTextStyles.bodySmall.copyWith(
                  color: colors.onErrorContainer,
                ),
              ),
          ],
        ),
        null => Text(
          l10n.numberNotAvailable,
          textAlign: TextAlign.center,
          style: TTextStyles.body.copyWith(color: colors.textSecondary),
        ),
      },
      AsyncValue(hasError: true) => LoadError(
        message: l10n.errorLoadNumber,
        onRetry: () => ref.invalidate(platformSettingsProvider),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TSizes.pagePadding,
          0,
          TSizes.pagePadding,
          TSizes.pagePadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: TSizes.xl,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TTextStyles.titleMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
            content,
          ],
        ),
      ),
    );
  }
}
