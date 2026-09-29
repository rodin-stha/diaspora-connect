import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/sizes.dart';
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

    void save(PersonalDetails updated) {
      ref.read(personalDetailsProvider.notifier).save(updated);
      // The messenger belongs to the whole app, so the message stays
      // visible on Profile after this screen closes.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.detailsSaved)));
      context.canPop() ? context.pop() : context.go('/profile');
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
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
                // `initialValue` is only read once, when the form is created,
                // so later provider changes don't wipe what's being typed.
                initialValue: details,
                submitLabel: l10n.saveChanges,
                onSubmit: save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
