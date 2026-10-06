import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/api/api_error_message.dart';
import '../../app/api/api_exception.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/attachment_row.dart';
import '../../widgets/async_select_field.dart';
import '../../widgets/back_title_bar.dart';
import '../../widgets/dashed_tile.dart';
import '../../widgets/form_section_header.dart';
import '../../widgets/image_source_sheet.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/removable_thumbnail.dart';
import '../../widgets/voice_note_player.dart';
import '../../widgets/voice_recorder_sheet.dart';
import '../activity/data/activity_provider.dart';
import '../issues/data/issues_provider.dart';
import '../issues/models/issue.dart';
import '../issues/models/new_issue.dart';
import '../work_details/data/work_details_provider.dart';
import 'models/evidence.dart';

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

  /// True while the issue is being sent: shows the spinner and blocks a
  /// second tap from reporting it twice.
  bool _sending = false;

  // Evidence (all optional).
  String? _photo;
  PinnedLocation? _location;
  VoiceNote? _voiceNote;

  @override
  void dispose() {
    _concerned.dispose();
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  /// Picks the photo; a new one replaces the previous (the API takes one).
  Future<void> _pickPhoto() async {
    final image = await pickImage(context);
    if (image == null) return;
    setState(() => _photo = image.path);
  }

  /// Opens the map, starting at the current pin if there is one. The
  /// picker pops with the chosen spot, or null if the user went back.
  Future<void> _pinLocation() async {
    final picked = await context.push<PinnedLocation>(
      '/report-issue/location',
      extra: _location,
    );
    if (picked != null) setState(() => _location = picked);
  }

  /// Records a new voice note; it replaces the previous one.
  Future<void> _recordVoice() async {
    final recording = await recordVoiceNote(context);
    if (recording == null) return;
    setState(
      () => _voiceNote = VoiceNote(
        path: recording.path,
        duration: recording.duration,
      ),
    );
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(issuesProvider.notifier)
          .submit(
            NewIssue(
              categoryId: _category!.id,
              subject: _subject.text.trim(),
              description: _description.text.trim(),
              employer: _concerned.text.trim(),
              photoPath: _photo,
              recordingPath: _voiceNote?.path,
              latitude: _location?.latitude,
              longitude: _location?.longitude,
            ),
          );
    } on ApiException catch (e) {
      if (mounted) _showMessage(apiErrorMessage(l10n, e));
      return;
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    if (!mounted) return;

    // The server logs the new issue; fetch the feed again to show it.
    ref.invalidate(activityProvider);

    _showMessage(l10n.issueSubmitted);
    // Close this form and show the Issues tab, where the list has been
    // fetched again and includes the new issue.
    context.go('/issues');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);
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
                  AsyncSelectField<IssueCategory>(
                    label: l10n.categoryLabel,
                    options: ref.watch(issueCategoriesProvider),
                    selectedId: _category?.id,
                    idOf: (category) => category.id,
                    nameOf: (category) => category.name,
                    requiredMessage: l10n.errorCategory,
                    loadErrorMessage: l10n.errorLoadCategories,
                    onRetry: () => ref.invalidate(issueCategoriesProvider),
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
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
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
                      for (final (label, icon, onTap) in [
                        (
                          l10n.evidencePhoto,
                          'assets/icons/camera.svg',
                          _pickPhoto,
                        ),
                        (
                          l10n.evidenceLocation,
                          'assets/icons/map_pin.svg',
                          _pinLocation,
                        ),
                        (
                          l10n.evidenceVoice,
                          'assets/icons/mic.svg',
                          _recordVoice,
                        ),
                      ])
                        Expanded(
                          child: DashedTile(
                            label: label,
                            iconAsset: icon,
                            onTap: onTap,
                          ),
                        ),
                    ],
                  ),
                  if (_photo case final photo?)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: RemovableThumbnail(
                        imagePath: photo,
                        onRemove: () => setState(() => _photo = null),
                      ),
                    ),
                  if (_location case final location?)
                    AttachmentRow(
                      leading: SvgPicture.asset(
                        'assets/icons/map_pin.svg',
                        width: TSizes.iconMd,
                        height: TSizes.iconMd,
                        colorFilter: ColorFilter.mode(
                          colors.accent,
                          BlendMode.srcIn,
                        ),
                      ),
                      title: l10n.locationPinned,
                      subtitle: location.display,
                      onTap: _pinLocation,
                      onRemove: () => setState(() => _location = null),
                    ),
                  if (_voiceNote case final voiceNote?)
                    VoiceNotePlayer(
                      // A new recording gets a fresh player.
                      key: ValueKey(voiceNote.path),
                      title: l10n.voiceNote,
                      path: voiceNote.path,
                      duration: voiceNote.duration,
                      onRemove: () => setState(() => _voiceNote = null),
                    ),
                  Text(
                    l10n.voiceNoteHint,
                    style: TTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),

                  LoadingButton(
                    label: l10n.submitIssue,
                    isLoading: _sending,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
