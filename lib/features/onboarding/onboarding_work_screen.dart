import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/api/api_error_message.dart';
import '../../app/api/api_exception.dart';
import '../../l10n/app_localizations.dart';
import '../auth/data/auth_provider.dart';
import '../work_details/data/work_details_provider.dart';
import '../work_details/models/work_details.dart';
import '../work_details/widgets/work_details_form.dart';
import 'widgets/onboarding_scaffold.dart';

/// 05 · Onboarding · Work: step 3 of 3.
///
/// Saving finishes onboarding. There's no navigation here: the router's
/// redirect sees [AuthState.isOnboarded] change and moves the user to Home.
class OnboardingWorkScreen extends ConsumerWidget {
  const OnboardingWorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return OnboardingScaffold(
      step: 3,
      title: l10n.onboardingWorkTitle,
      child: WorkDetailsForm(
        initialValue: const WorkDetails(),
        submitLabel: l10n.saveProfile,
        useUploadTiles: true,
        onSubmit: (details) async {
          try {
            await ref.read(workDetailsProvider.notifier).save(details);
            // Only once the server has the details: finishing onboarding
            // leaves this screen, and with it the chance to retry.
            await ref.read(authProvider.notifier).completeOnboarding();
          } on ApiException catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(apiErrorMessage(l10n, e))),
            );
          }
        },
      ),
    );
  }
}
