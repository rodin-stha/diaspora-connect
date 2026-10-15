import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../widgets/action_tile.dart';
import '../../platform_settings/data/platform_settings_provider.dart';
import 'call_sheet.dart';

/// The 2×2 grid of shortcuts on Home: Report an issue, Notice, SOS,
/// Helpline.
class HomeActions extends ConsumerWidget {
  const HomeActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    // Fetch the SOS and helpline numbers now, so they're ready by the time
    // someone taps. In an emergency, no spinner.
    ref.watch(platformSettingsProvider);

    // TODO: Notice has no screen yet.
    void comingSoon() => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: TSizes.md,
      children: [
        _TileRow(
          children: [
            ActionTile(
              label: l10n.reportIssueTitle,
              iconAsset: 'assets/icons/report_circle.svg',
              color: colors.primary,
              onColor: colors.onPrimary,
              onTap: () => context.push('/report-issue'),
            ),
            ActionTile(
              label: l10n.notice,
              iconAsset: 'assets/icons/alarm.svg',
              color: colors.accent,
              onColor: colors.onAccent,
              onTap: comingSoon,
            ),
          ],
        ),
        _TileRow(
          children: [
            ActionTile(
              label: l10n.sos,
              color: colors.accent,
              onColor: colors.onAccent,
              onTap: () => showCallSheet(
                context,
                title: l10n.sosSheetTitle,
                numberOf: (settings) => settings.sosNumber,
              ),
            ),
            ActionTile(
              label: l10n.helpline,
              iconAsset: 'assets/icons/phone.svg',
              color: colors.primary,
              onColor: colors.onPrimary,
              onTap: () => showCallSheet(
                context,
                title: l10n.helpline,
                numberOf: (settings) => settings.helplineNumber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Two equal-width tiles side by side, kept the same height if one's label
/// wraps.
class _TileRow extends StatelessWidget {
  final List<Widget> children;

  const _TileRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: TSizes.md,
        children: [for (final child in children) Expanded(child: child)],
      ),
    );
  }
}
