import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/sizes.dart';
import '../../../utils/validators.dart';
import '../../../widgets/checkbox_row.dart';
import '../../../widgets/date_field.dart';
import '../../../widgets/document_row.dart';
import '../../../widgets/form_section_header.dart';
import '../../../widgets/image_source_sheet.dart';
import '../../../widgets/image_upload_tile.dart';
import '../../../widgets/labeled_field.dart';
import '../../../widgets/labeled_text_field.dart';
import '../../../widgets/loading_button.dart';
import '../models/legal_details.dart';

/// The legal details form, shared by Profile → Legal details ("Save changes")
/// and onboarding step 2 ("Verify and continue").
///
/// Holds its own editing state; [onSubmit] gets the result only when every
/// field is valid.
class LegalDetailsForm extends StatefulWidget {
  final LegalDetails initialValue;
  final String submitLabel;

  /// Saves the details. The button shows a spinner until it completes.
  final Future<void> Function(LegalDetails) onSubmit;

  /// Shows the passport and visa as two empty upload tiles instead of rows
  /// with Upload/Replace. Used in onboarding, where nothing is uploaded yet.
  final bool useUploadTiles;

  /// Adds a required "I consent to identity verification" checkbox above
  /// the button. Used in onboarding.
  final bool requireConsent;

  const LegalDetailsForm({
    super.key,
    required this.initialValue,
    required this.submitLabel,
    required this.onSubmit,
    this.useUploadTiles = false,
    this.requireConsent = false,
  });

  @override
  State<LegalDetailsForm> createState() => _LegalDetailsFormState();
}

class _LegalDetailsFormState extends State<LegalDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  late final _passportNumber = TextEditingController(
    text: _initial.passportNumber,
  );
  late final _nationalId = TextEditingController(text: _initial.nationalId);
  late final _citizenshipNumber = TextEditingController(
    text: _initial.citizenshipCertificateNumber,
  );
  late DateTime? _passportExpiry = _initial.passportExpiry;

  // Photos picked on this device; null until the user picks one.
  late String? _photoPageFile = _initial.passportPhotoPageFile;
  late String? _visaPageFile = _initial.israelVisaPageFile;

  /// Show errors as the user types, but only after the first Save attempt.
  bool _submitted = false;

  /// True while [LegalDetailsForm.onSubmit] runs: shows the spinner and
  /// blocks a second tap from saving twice.
  bool _saving = false;

  LegalDetails get _initial => widget.initialValue;

  @override
  void dispose() {
    _passportNumber.dispose();
    _nationalId.dispose();
    _citizenshipNumber.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await widget.onSubmit(
        LegalDetails(
          passportNumber: _passportNumber.text
              .replaceAll(' ', '')
              .toUpperCase(),
          passportExpiry: _passportExpiry,
          nationalId: _nationalId.text.trim(),
          citizenshipCertificateNumber: _citizenshipNumber.text.trim(),
          passportPhotoPage: _initial.passportPhotoPage,
          israelVisaPage: _initial.israelVisaPage,
          passportPhotoPageFile: _photoPageFile,
          israelVisaPageFile: _visaPageFile,
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
    final now = DateTime.now();

    FormFieldValidator<String> required(String message) =>
        (value) => (value == null || value.trim().isEmpty) ? message : null;

    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: TSizes.formGap,
        children: [
          LabeledTextField(
            label: l10n.passportNumberLabel,
            isRequired: true,
            controller: _passportNumber,
            hintText: l10n.passportNumberHint,
            validator: (value) =>
                required(l10n.errorPassportNumber)(value) ??
                (TValidators.isPassportNumber(value!)
                    ? null
                    : l10n.errorPassportNumberFormat),
            textCapitalization: TextCapitalization.characters,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Expanded(
                child: DateField(
                  label: l10n.passportExpiryLabel,
                  isRequired: true,
                  value: _passportExpiry,
                  hintText: l10n.dateHint,
                  // Allow already-expired passports: that's real information
                  // a case worker may need to act on.
                  firstDate: DateTime(now.year - 10),
                  lastDate: DateTime(now.year + 15),
                  initialPickerDate: DateTime(now.year + 5),
                  validator: (value) =>
                      value == null ? l10n.errorPassportExpiry : null,
                  onChanged: (date) => setState(() => _passportExpiry = date),
                ),
              ),
              Expanded(
                child: LabeledTextField(
                  label: l10n.nationalIdLabel,
                  controller: _nationalId,
                  hintText: l10n.nationalIdHint,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          LabeledTextField(
            label: l10n.citizenshipNumberLabel,
            isRequired: true,
            controller: _citizenshipNumber,
            hintText: l10n.citizenshipNumberHint,
            validator: required(l10n.errorCitizenshipNumber),
            textInputAction: TextInputAction.done,
          ),

          FormSectionHeader(title: l10n.uploadedDocumentsSection),
          if (widget.useUploadTiles)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Expanded(child: _photoPageField(l10n)),
                Expanded(child: _visaPageField(l10n)),
              ],
            )
          else ...[
            _photoPageField(l10n),
            _visaPageField(l10n),
          ],
          if (widget.requireConsent)
            // A FormField so the box is checked by the same validate() call
            // as the text fields, and shows its error the same way.
            FormField<bool>(
              initialValue: false,
              validator: (value) =>
                  value == true ? null : l10n.errorIdentityConsent,
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxRow(
                    label: l10n.identityConsent,
                    value: field.value ?? false,
                    hasError: field.hasError,
                    onChanged: field.didChange,
                  ),
                  if (field.hasError) FieldErrorText(field.errorText!),
                ],
              ),
            ),

          LoadingButton(
            label: widget.submitLabel,
            isLoading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _photoPageField(AppLocalizations l10n) => _documentField(
    tileLabel: l10n.uploadPhotoPage,
    rowLabel: l10n.documentPassportPhotoPage,
    uploaded: _initial.passportPhotoPage,
    picked: _photoPageFile,
    requiredMessage: l10n.errorPhotoPage,
    onPicked: (path) => _photoPageFile = path,
  );

  Widget _visaPageField(AppLocalizations l10n) => _documentField(
    tileLabel: l10n.documentIsraelVisaPage,
    rowLabel: l10n.documentIsraelVisaPage,
    uploaded: _initial.israelVisaPage,
    picked: _visaPageFile,
    requiredMessage: l10n.errorVisaPage,
    onPicked: (path) => _visaPageFile = path,
  );

  /// A required document photo: an upload tile in onboarding, a row with
  /// Upload/Replace in Profile. Valid once a file is uploaded or picked.
  ///
  /// A FormField (like the consent checkbox) so the same validate() call
  /// checks it and shows its error the same way.
  Widget _documentField({
    required String tileLabel,
    required String rowLabel,
    required String? uploaded,
    required String? picked,
    required String requiredMessage,
    required ValueChanged<String> onPicked,
  }) {
    final l10n = AppLocalizations.of(context);
    final current = picked ?? uploaded;

    return FormField<String>(
      initialValue: current,
      validator: (value) =>
          (value == null || value.isEmpty) ? requiredMessage : null,
      builder: (field) {
        Future<void> pick() async {
          final image = await pickImage(context);
          if (image == null) return;
          setState(() => onPicked(image.path));
          field.didChange(image.path);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.useUploadTiles)
              ImageUploadTile(
                label: tileLabel,
                imagePath: picked,
                hasError: field.hasError,
                onTap: pick,
              )
            else
              DocumentRow(
                name: rowLabel,
                actionLabel: current == null
                    ? l10n.uploadAction
                    : l10n.replaceAction,
                onAction: pick,
              ),
            if (field.hasError) FieldErrorText(field.errorText!),
          ],
        );
      },
    );
  }
}
