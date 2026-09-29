import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/sizes.dart';
import '../../../widgets/dashed_tile.dart';
import '../../../widgets/document_row.dart';
import '../../../widgets/form_section_header.dart';
import '../../../widgets/labeled_text_field.dart';
import '../../../widgets/select_field.dart';
import '../models/work_details.dart';

/// The work details form, shared by Profile → Work details & permit
/// ("Save changes") and onboarding step 3 ("Save profile").
///
/// The section under "Type of business" depends on the chosen type. Only
/// caregiving's is designed so far; other types show none yet.
class WorkDetailsForm extends StatefulWidget {
  final WorkDetails initialValue;
  final String submitLabel;
  final ValueChanged<WorkDetails> onSubmit;

  /// Called when the user taps Upload/Replace on the work permit.
  final VoidCallback? onUploadWorkPermit;

  /// Shows the work permit as an empty upload tile instead of a row with
  /// Upload/Replace. Used in onboarding, where nothing is uploaded yet.
  final bool useUploadTiles;

  const WorkDetailsForm({
    super.key,
    required this.initialValue,
    required this.submitLabel,
    required this.onSubmit,
    this.onUploadWorkPermit,
    this.useUploadTiles = false,
  });

  @override
  State<WorkDetailsForm> createState() => _WorkDetailsFormState();
}

class _WorkDetailsFormState extends State<WorkDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  late BusinessType? _businessType = _initial.businessType;
  late CareArrangement? _careArrangement = _initial.careArrangement;
  late final _hostFamily = TextEditingController(text: _initial.hostFamily);

  /// Show errors as the user types, but only after the first Save attempt.
  bool _submitted = false;

  WorkDetails get _initial => widget.initialValue;

  @override
  void dispose() {
    _hostFamily.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final isCaregiving = _businessType == BusinessType.caregiving;
    widget.onSubmit(
      WorkDetails(
        businessType: _businessType,
        workPermitLetter: _initial.workPermitLetter,
        // Don't keep caregiving answers after switching to another type.
        careArrangement: isCaregiving ? _careArrangement : null,
        hostFamily: isCaregiving ? _hostFamily.text.trim() : '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final permit = _initial.workPermitLetter;

    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: TSizes.formGap,
        children: [
          SelectField<BusinessType>(
            label: l10n.businessTypeLabel,
            isRequired: true,
            value: _businessType,
            options: BusinessType.values,
            optionLabel: (type) => _businessTypeLabel(l10n, type),
            hintText: l10n.selectHint,
            validator: (value) => value == null ? l10n.errorBusinessType : null,
            onChanged: (value) => setState(() => _businessType = value),
          ),

          FormSectionHeader(title: l10n.workPermitSection, showDivider: false),
          if (widget.useUploadTiles)
            DashedTile.large(
              label: l10n.uploadWorkPermit,
              iconAsset: 'assets/icons/plus_bold.svg',
              onTap: widget.onUploadWorkPermit,
            )
          else
            DocumentRow(
              name: l10n.documentWorkPermitLetter,
              actionLabel: permit == null
                  ? l10n.uploadAction
                  : l10n.replaceAction,
              onAction: widget.onUploadWorkPermit,
            ),

          // Details for the chosen business type. Each type gets its own
          // section here once it's designed.
          if (_businessType == BusinessType.caregiving) ...[
            FormSectionHeader(
              title: l10n.caregivingDetailsSection,
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

          FilledButton(onPressed: _submit, child: Text(widget.submitLabel)),
        ],
      ),
    );
  }

  static String _businessTypeLabel(AppLocalizations l10n, BusinessType type) =>
      switch (type) {
        BusinessType.caregiving => l10n.businessCaregiving,
        BusinessType.agriculture => l10n.businessAgriculture,
        BusinessType.entrepreneur => l10n.businessEntrepreneur,
        BusinessType.employee => l10n.businessEmployee,
      };
}
