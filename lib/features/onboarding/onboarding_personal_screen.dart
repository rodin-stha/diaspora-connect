import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../personal_details/data/personal_details_provider.dart';
import '../personal_details/models/personal_details.dart';
import '../personal_details/widgets/personal_details_form.dart';
import 'widgets/onboarding_scaffold.dart';

/// 03 · Onboarding · Personal: step 1 of 3, right after the first sign-in.
class OnboardingPersonalScreen extends ConsumerWidget {
  const OnboardingPersonalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return OnboardingScaffold(
      step: 1,
      title: l10n.personalDetails,
      child: PersonalDetailsForm(
        initialValue: const PersonalDetails.empty(),
        submitLabel: l10n.continueAction,
        showHints: true,
        onSubmit: (details) {
          ref.read(personalDetailsProvider.notifier).save(details);
          context.push('/onboarding/legal');
        },
      ),
    );
  }
}
