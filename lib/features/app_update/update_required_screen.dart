import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/loading_button.dart';
import 'data/update_required_provider.dart';

/// The app's ID in the App Store (App Store Connect → App Information →
/// Apple ID). Until it's set, the button opens the App Store's front page.
// TODO: set once the app exists in App Store Connect, before raising
// min_version.ios.
const _appStoreId = '';

/// Shown instead of the whole app when this version is too old (see
/// [updateRequiredProvider]). There's no way past it but updating.
class UpdateRequiredScreen extends ConsumerWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final packageName = ref.watch(appInfoProvider).value?.packageName;

    // Dark status bar icons: the background here is light.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.pagePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: TSizes.spaceBtwItems,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: TSizes.logoSize,
                    semanticLabel: l10n.appName,
                  ),
                  Text(
                    l10n.updateRequiredTitle,
                    textAlign: TextAlign.center,
                    style: TTextStyles.pageHeading.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.updateRequiredMessage,
                    textAlign: TextAlign.center,
                    style: TTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: TSizes.sm),
                  SizedBox(
                    width: double.infinity,
                    child: LoadingButton(
                      label: l10n.updateNow,
                      onPressed: packageName == null
                          ? null
                          : () => launchUrl(
                              _storeUri(packageName),
                              // The Play Store / App Store app, not a browser.
                              mode: LaunchMode.externalApplication,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Uri _storeUri(String packageName) => switch (defaultTargetPlatform) {
  TargetPlatform.iOS =>
    _appStoreId.isEmpty
        ? Uri.parse('https://apps.apple.com')
        : Uri.parse('https://apps.apple.com/app/id$_appStoreId'),
  _ => Uri.parse(
    'https://play.google.com/store/apps/details?id=$packageName',
  ),
};
