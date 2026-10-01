import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/back_title_bar.dart';
import '../../widgets/dashed_tile.dart';
import '../../widgets/form_section_header.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/select_field.dart';
import '../activity/data/activity_provider.dart';
import '../activity/models/activity.dart';
import '../issues/data/issues_provider.dart';
import '../issues/models/issue.dart';
import '../work_details/data/work_details_provider.dart';

/// Home → Report an issue. Submitting adds the issue to Issues and Activity,
/// then opens its Track issue page.
class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();

  IssueCategory? _category;

  // Pre-filled with the employer from Work details; the user can change it.
  late final _concerned = TextEditingController(
    text: ref.read(workDetailsProvider).hostFamily,
  );
  final _subject = TextEditingController();
  final _description = TextEditingController();

  /// Show errors as the user types, but only after the first Submit attempt.
  bool _submitted = false;

  @override
  void dispose() {
    _concerned.dispose();
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  void _submit() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final issue = ref
        .read(issuesProvider.notifier)
        .report(
          category: _category!,
          subject: _subject.text.trim(),
          description: _description.text.trim(),
          concerned: _concerned.text.trim(),
        );
    ref
        .read(activityProvider.notifier)
        .record(
          IssueSubmitted(reference: issue.reference, issueTitle: issue.title),
        );

    _showMessage(AppLocalizations.of(context).issueSubmitted);
    // Replace this form with the new issue's page, so Back goes to where
    // the user started (e.g. Home), not to a filled-in form.
    context.pushReplacement('/issues/${issue.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    // Empty until loaded (or if loading failed); the dropdown just has no
    // options then.
    final categories = ref.watch(issueCategoriesProvider).value ?? const [];
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);
    // TODO: attach evidence once camera, location and recording are set up.
    void evidenceComingSoon() => _showMessage(l10n.evidenceComingSoon);

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
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: TSizes.lg,
              children: [
                BackTitleBar(
                  title: l10n.reportIssueTitle,
                  fallbackLocation: '/home',
                ),
                SelectField<IssueCategory>(
                  label: l10n.categoryLabel,
                  isRequired: true,
                  value: _category,
                  options: categories,
                  optionLabel: (category) => category.name,
                  hintText: l10n.selectHint,
                  validator: (value) =>
                      value == null ? l10n.errorCategory : null,
                  onChanged: (value) => setState(() => _category = value),
                ),
                LabeledTextField(
                  label: l10n.concernedLabel,
                  controller: _concerned,
                  hintText: l10n.concernedHint,
                  textCapitalization: TextCapitalization.words,
                ),
                LabeledTextField(
                  label: l10n.subjectLabel,
                  isRequired: true,
                  controller: _subject,
                  hintText: l10n.subjectHint,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.errorSubject
                      : null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                LabeledTextField(
                  label: l10n.descriptionLabel,
                  controller: _description,
                  hintText: l10n.descriptionHint,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 6,
                ),

                FormSectionHeader(
                  title: l10n.evidenceSection,
                  showDivider: false,
                ),
                Row(
                  spacing: TSizes.sm,
                  children: [
                    for (final (label, icon) in [
                      (l10n.evidencePhoto, 'assets/icons/camera.svg'),
                      (l10n.evidenceLocation, 'assets/icons/map_pin.svg'),
                      (l10n.evidenceVoice, 'assets/icons/mic.svg'),
                    ])
                      Expanded(
                        child: DashedTile(
                          label: label,
                          iconAsset: icon,
                          onTap: evidenceComingSoon,
                        ),
                      ),
                  ],
                ),
                Text(
                  l10n.voiceNoteHint,
                  style: TTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),

                FilledButton(onPressed: _submit, child: Text(l10n.submitIssue)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
