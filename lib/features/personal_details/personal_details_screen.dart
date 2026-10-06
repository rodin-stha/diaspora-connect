import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/api/api_error_message.dart';
import '../../app/api/api_exception.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/sizes.dart';
import '../../widgets/app_background.dart';
import '../../widgets/back_title_bar.dart';
import 'data/personal_details_provider.dart';
import 'models/personal_details.dart';
import 'widgets/personal_details_form.dart';

/// Profile → Personal details: edit and save.
class PersonalDetailsScreen extends ConsumerWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final details = ref.watch(personalDetailsProvider);

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    Future<void> save(PersonalDetails updated) async {
      // The messenger belongs to the whole app, so the message stays
      // visible on Profile after this screen closes.
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref.read(personalDetailsProvider.notifier).save(updated);
        if (!context.mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(l10n.detailsSaved)));
        context.canPop() ? context.pop() : context.go('/profile');
      } on ApiException catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text(apiErrorMessage(l10n, e))),
        );
      }
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
                  title: l10n.personalDetails,
                  fallbackLocation: '/profile',
                ),
                PersonalDetailsForm(
                  initialValue: details,
                  submitLabel: l10n.saveChanges,
                  onSubmit: save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
