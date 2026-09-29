import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/segmented_progress_bar.dart';

/// The page around each onboarding step: progress bar, "STEP 1 OF 3",
/// the step's title, then [child] (the step's form), all scrolling.
class OnboardingScaffold extends StatelessWidget {
  static const totalSteps = 3;

  /// 1-based: 1 = personal, 2 = legal, 3 = work.
  final int step;
  final String title;
  final Widget child;

  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

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
            spacing: TSizes.lg,
            children: [
              SegmentedProgressBar(completed: step, total: totalSteps),
              Text(
                l10n.onboardingStep(step, totalSteps).toUpperCase(),
                style: TTextStyles.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                title,
                style: TTextStyles.titleLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
