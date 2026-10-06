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
import '../../widgets/link_button.dart';
import 'data/personal_details_provider.dart';
import 'models/personal_details.dart';
import 'widgets/personal_details_form.dart';

/// Profile → Personal details: edit and save.
class PersonalDetailsScreen extends ConsumerWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detailsAsync = ref.watch(personalDetailsProvider);

    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    Future<void> save(PersonalDetails updated) async {
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
                // The form reads initialValue only once, so it's built only
                // after the details have loaded.
                detailsAsync.when(
                  data: (details) => PersonalDetailsForm(
                    initialValue: details,
                    submitLabel: l10n.saveChanges,
                    onSubmit: save,
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: TSizes.xl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Column(
                    spacing: TSizes.sm,
                    children: [
                      Text(l10n.errorGeneric),
                      LinkButton(
                        label: l10n.retry,
                        // Drops the failed result, so build() fetches again.
                        onPressed: () =>
                            ref.invalidate(personalDetailsProvider),
                      ),
                    ],
                  ),
                  // Show the spinner on Retry instead of keeping the old
                  // error on screen until the new result arrives.
                  skipLoadingOnRefresh: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
