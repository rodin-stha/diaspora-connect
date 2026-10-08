import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/sizes.dart';
import '../../../widgets/async_select_field.dart';
import '../../../widgets/image_source_sheet.dart';
import '../../../widgets/image_upload_tile.dart';
import '../../../widgets/document_row.dart';
import '../../../widgets/form_section_header.dart';
import '../../../widgets/labeled_text_field.dart';
import '../../../widgets/loading_button.dart';
import '../../../widgets/select_field.dart';
import '../data/work_details_provider.dart';
import '../models/employment_type.dart';
import '../models/work_details.dart';

/// The work details form, shared by Profile → Work details & permit
/// ("Save changes") and onboarding step 3 ("Save profile").
///
/// The caregiving section (live-in/out, host) shows only for types that
/// allow living in ([EmploymentType.allowsLiveIn]).
class WorkDetailsForm extends ConsumerStatefulWidget {
  final WorkDetails initialValue;
  final String submitLabel;

  /// Saves the details. The button shows a spinner until it completes.
  final Future<void> Function(WorkDetails) onSubmit;

  /// Shows the work permit as an empty upload tile instead of a row with
  /// Upload/Replace. Used in onboarding, where nothing is uploaded yet.
  final bool useUploadTiles;

  const WorkDetailsForm({
    super.key,
    required this.initialValue,
    required this.submitLabel,
    required this.onSubmit,
    this.useUploadTiles = false,
  });

  @override
  ConsumerState<WorkDetailsForm> createState() => _WorkDetailsFormState();
}

class _WorkDetailsFormState extends ConsumerState<WorkDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  late int? _employmentTypeId = _initial.employmentTypeId;
  late CareArrangement? _careArrangement = _initial.careArrangement;
  late final _hostFamily = TextEditingController(text: _initial.hostFamily);

  /// The permit photo picked on this device; null until the user picks one.
  late String? _permitFile = _initial.workPermitFile;

  /// Show errors as the user types, but only after the first Save attempt.
  bool _submitted = false;

  /// True while [WorkDetailsForm.onSubmit] runs: shows the spinner and
  /// blocks a second tap from saving twice.
  bool _saving = false;

  WorkDetails get _initial => widget.initialValue;

  @override
  void dispose() {
    _hostFamily.dispose();
    super.dispose();
  }

  /// Whether the chosen type allows living in. False until the types have
  /// loaded: the type can't be looked up before then.
  ///
  /// `read`, not `watch`: it's also called from [_submit], outside build.
  /// build() already watches the types (for the dropdown), so the form
  /// still rebuilds when they arrive.
  bool get _allowsLiveIn {
    final types = ref.read(employmentTypesProvider).value ?? const [];
    return types
            .where((type) => type.id == _employmentTypeId)
            .firstOrNull
            ?.allowsLiveIn ??
        false;
  }

  Future<void> _pickPermit() async {
    final image = await pickImage(context);
    if (image == null) return;
    setState(() => _permitFile = image.path);
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final allowsLiveIn = _allowsLiveIn;
    setState(() => _saving = true);
    try {
      await widget.onSubmit(
        WorkDetails(
          employmentTypeId: _employmentTypeId,
          workPermitLetter: _initial.workPermitLetter,
          workPermitFile: _permitFile,
          // Don't keep live-in answers after switching to a type without
          // them.
          careArrangement: allowsLiveIn ? _careArrangement : null,
          hostFamily: allowsLiveIn ? _hostFamily.text.trim() : '',
        ),
      );
    } finally {
      // Runs on success and failure. After a successful save the screen may
      // already have navigated away, hence the mounted check.
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasPermit = _permitFile != null || _initial.workPermitLetter != null;

    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: TSizes.formGap,
        children: [
          AsyncSelectField<EmploymentType>(
            label: l10n.businessTypeLabel,
            options: ref.watch(employmentTypesProvider),
            selectedId: _employmentTypeId,
            idOf: (type) => type.id,
            nameOf: (type) => type.name,
            requiredMessage: l10n.errorBusinessType,
            loadErrorMessage: l10n.errorLoadEmploymentTypes,
            onRetry: () => ref.invalidate(employmentTypesProvider),
            onChanged: (type) => setState(() => _employmentTypeId = type?.id),
          ),

          FormSectionHeader(title: l10n.workPermitSection, showDivider: false),
          if (widget.useUploadTiles)
            ImageUploadTile(
              label: l10n.uploadWorkPermit,
              imagePath: _permitFile,
              onTap: _pickPermit,
            )
          else
            DocumentRow(
              name: l10n.documentWorkPermitLetter,
              actionLabel: hasPermit ? l10n.replaceAction : l10n.uploadAction,
              onAction: _pickPermit,
            ),

          if (_allowsLiveIn) ...[
            FormSectionHeader(
              title: l10n.otherDetailsSection,
              showDivider: false,
            ),
            SelectField<CareArrangement>(
              label: l10n.careArrangementLabel,
              isRequired: true,
              value: _careArrangement,
              options: CareArrangement.values,
              optionLabel: (arrangement) => switch (arrangement) {
                CareArrangement.liveIn => l10n.liveIn,
                CareArrangement.liveOut => l10n.liveOut,
              },
              hintText: l10n.selectHint,
              validator: (value) =>
                  value == null ? l10n.errorCareArrangement : null,
              onChanged: (value) => setState(() => _careArrangement = value),
            ),
            LabeledTextField(
              label: l10n.hostFamilyLabel,
              controller: _hostFamily,
              hintText: l10n.hostFamilyHint,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
            ),
          ],

          LoadingButton(
            label: widget.submitLabel,
            isLoading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
