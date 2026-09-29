import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../legal_details/data/legal_details_provider.dart';
import '../legal_details/models/legal_details.dart';
import '../legal_details/widgets/legal_details_form.dart';
import 'widgets/onboarding_scaffold.dart';

/// 04 · Onboarding · Legal: step 2 of 3.
class OnboardingLegalScreen extends ConsumerWidget {
  const OnboardingLegalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return OnboardingScaffold(
      step: 2,
      title: l10n.legalDetailsTitle,
      child: LegalDetailsForm(
        initialValue: const LegalDetails.empty(),
        submitLabel: l10n.verifyAndContinue,
        useUploadTiles: true,
        requireConsent: true,
        // TODO: pick and upload the file once uploads exist.
        onUploadDocument: () => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.uploadComingSoon))),
        onSubmit: (details) {
          ref.read(legalDetailsProvider.notifier).save(details);
          context.push('/onboarding/work');
        },
      ),
    );
  }
}
