import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/sizes.dart';
import '../../../utils/validators.dart';
import '../../../widgets/checkbox_row.dart';
import '../../../widgets/dashed_button.dart';
import '../../../widgets/dashed_tile.dart';
import '../../../widgets/date_field.dart';
import '../../../widgets/document_row.dart';
import '../../../widgets/form_section_header.dart';
import '../../../widgets/labeled_field.dart';
import '../../../widgets/labeled_text_field.dart';
import '../models/legal_details.dart';

/// The legal details form, shared by Profile → Legal details ("Save changes")
/// and onboarding step 2 ("Verify and continue").
///
/// Holds its own editing state; [onSubmit] gets the result only when every
/// field is valid.
class LegalDetailsForm extends StatefulWidget {
  final LegalDetails initialValue;
  final String submitLabel;
  final ValueChanged<LegalDetails> onSubmit;

  /// Called when the user taps Upload/Replace on a document. The screen
  /// decides how to pick the file.
  final VoidCallback? onUploadDocument;

  /// Called by "Upload new document" under the list. New documents go to
  /// Saved documents (not the passport/visa slots). Hidden when null.
  final VoidCallback? onUploadNewDocument;

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
    this.onUploadDocument,
    this.onUploadNewDocument,
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

  /// Show errors as the user types, but only after the first Save attempt.
  late bool _submitted = false;

  LegalDetails get _initial => widget.initialValue;

  @override
  void dispose() {
    _passportNumber.dispose();
    _nationalId.dispose();
    _citizenshipNumber.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      LegalDetails(
        passportNumber: _passportNumber.text.replaceAll(' ', '').toUpperCase(),
        passportExpiry: _passportExpiry,
        nationalId: _nationalId.text.trim(),
        citizenshipCertificateNumber: _citizenshipNumber.text.trim(),
        // Uploads aren't edited by this form yet.
        passportPhotoPage: _initial.passportPhotoPage,
        israelVisaPage: _initial.israelVisaPage,
      ),
    );
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
              spacing: 10,
              children: [
                for (final label in [
                  l10n.uploadPhotoPage,
                  l10n.documentIsraelVisaPage,
                ])
                  Expanded(
                    child: DashedTile.large(
                      label: label,
                      iconAsset: 'assets/icons/plus_bold.svg',
                      onTap: widget.onUploadDocument,
                    ),
                  ),
              ],
            )
          else
            for (final (name, file) in [
              (l10n.documentPassportPhotoPage, _initial.passportPhotoPage),
              (l10n.documentIsraelVisaPage, _initial.israelVisaPage),
            ])
              DocumentRow(
                name: name,
                actionLabel: file == null
                    ? l10n.uploadAction
                    : l10n.replaceAction,
                onAction: widget.onUploadDocument,
              ),
          if (widget.onUploadNewDocument != null)
            DashedButton(
              label: l10n.uploadNewDocument,
              onPressed: widget.onUploadNewDocument,
            ),
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

          FilledButton(onPressed: _submit, child: Text(widget.submitLabel)),
        ],
      ),
    );
  }
}
