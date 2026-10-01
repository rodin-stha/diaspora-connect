import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/language_toggle.dart';
import '../../widgets/list_section.dart';
import '../../widgets/menu_row.dart';
import '../auth/data/auth_provider.dart';
import 'data/user_provider.dart';
import 'widgets/profile_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final user = ref.watch(currentUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // White status bar icons on the blue header
      value: SystemUiOverlayStyle.light,
      child: AppBackground(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(user: user),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TSizes.pagePadding,
                    TSizes.groupGap,
                    TSizes.pagePadding,
                    TSizes.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.appLanguage,
                              style: TTextStyles.label.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          const LanguageToggle(
                            variant: LanguageToggleVariant.full,
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.groupGap),
                      ListSection(
                        title: l10n.profileSectionProfile,
                        children: [
                          MenuRow(
                            title: l10n.personalDetails,
                            onTap: () =>
                                context.push('/profile/personal-details'),
                          ),
                          MenuRow(
                            title: l10n.legalDetails,
                            onTap: () => context.push('/profile/legal-details'),
                          ),
                          MenuRow(
                            title: l10n.workDetails,
                            onTap: () => context.push('/profile/work-details'),
                          ),
                          MenuRow(
                            title: l10n.savedDocuments,
                            onTap: () =>
                                context.push('/profile/saved-documents'),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.groupGap),
                      ListSection(
                        title: l10n.profileSectionPreferences,
                        children: [
                          MenuRow(
                            title: l10n.notificationSettings,
                            onTap: () =>
                                context.push('/profile/notification-settings'),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),
                      // Outlined, not filled: logging out is never the main
                      // thing to do here, so it shouldn't be the loudest.
                      OutlinedButton(
                        onPressed: () => _confirmLogOut(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.accent,
                          side: BorderSide(color: colors.accent),
                        ),
                        child: Text(l10n.logOut),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Asks first, so an accidental tap doesn't sign the user out. After
  /// signing out, the router's redirect shows the login screen.
  Future<void> _confirmLogOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logOutConfirmTitle),
        content: Text(l10n.logOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            // Red, like the Log out button: it's the destructive choice.
            style: TextButton.styleFrom(
              foregroundColor: context.colors.accent,
            ),
            child: Text(l10n.logOut),
          ),
        ],
      ),
    );
    if (confirmed == true) await ref.read(authProvider.notifier).signOut();
  }
}
