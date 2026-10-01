import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/sizes.dart';
import '../../widgets/app_background.dart';
import '../../widgets/back_title_bar.dart';
import 'data/work_details_provider.dart';
import 'models/work_details.dart';
import 'widgets/work_details_form.dart';

/// Profile → Work details & permit: edit and save.
class WorkDetailsScreen extends ConsumerWidget {
  const WorkDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final details = ref.watch(workDetailsProvider);

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    void showMessage(String message) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    void save(WorkDetails updated) {
      ref.read(workDetailsProvider.notifier).save(updated);
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
                  title: l10n.workDetails,
                  fallbackLocation: '/profile',
                ),
                WorkDetailsForm(
                  initialValue: details,
                  submitLabel: l10n.saveChanges,
                  onSubmit: save,
                  // TODO: pick and upload the file once uploads exist.
                  onUploadWorkPermit: () => showMessage(l10n.uploadComingSoon),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
