import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/sizes.dart';
import '../../widgets/app_background.dart';
import '../../widgets/back_title_bar.dart';
import 'data/legal_details_provider.dart';
import 'models/legal_details.dart';
import 'widgets/legal_details_form.dart';

/// Profile → Legal details: edit and save.
class LegalDetailsScreen extends ConsumerWidget {
  const LegalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final details = ref.watch(legalDetailsProvider);

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    void showMessage(String message) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    void save(LegalDetails updated) {
      ref.read(legalDetailsProvider.notifier).save(updated);
      showMessage(l10n.detailsSaved);
      context.canPop() ? context.pop() : context.go('/profile');
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              TSizes.pagePadding,
              topPadding,
              TSizes.pagePadding,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: TSizes.formGap,
              children: [
                BackTitleBar(
                  title: l10n.legalDetailsTitle,
                  fallbackLocation: '/profile',
                ),
                LegalDetailsForm(
                  initialValue: details,
                  submitLabel: l10n.saveChanges,
                  onSubmit: save,
                  // TODO: pick a photo/file and upload it once the backend
                  // and file permissions are set up.
                  onUploadDocument: () => showMessage(l10n.uploadComingSoon),
                  // Same as Saved documents' button: adds to that list.
                  onUploadNewDocument: () => showMessage(l10n.uploadComingSoon),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
