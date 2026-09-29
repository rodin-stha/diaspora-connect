import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/validators.dart';
import '../../../widgets/date_field.dart';
import '../../../widgets/form_section_header.dart';
import '../../../widgets/labeled_field.dart';
import '../../../widgets/labeled_text_field.dart';
import '../../../widgets/select_field.dart';
import '../../../widgets/selectable_chip.dart';
import '../models/personal_details.dart';

/// The personal details form, shared by Profile → Personal details
/// ("Save changes") and onboarding step 1 ("Continue").
///
/// Holds its own editing state; [onSubmit] gets the result only when every
/// field is valid. The screen around it decides the title and what happens
/// after submitting.
class PersonalDetailsForm extends StatefulWidget {
  final PersonalDetails initialValue;
  final String submitLabel;
  final ValueChanged<PersonalDetails> onSubmit;

  /// Extra explanations under the address and contact sections. Shown during
  /// onboarding, where people fill this in for the first time.
  final bool showHints;

  const PersonalDetailsForm({
    super.key,
    required this.initialValue,
    required this.submitLabel,
    required this.onSubmit,
    this.showHints = false,
  });

  @override
  State<PersonalDetailsForm> createState() => _PersonalDetailsFormState();
}

class _PersonalDetailsFormState extends State<PersonalDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  // Text fields: a controller each (like a ref to an uncontrolled input).
  late final _fullName = TextEditingController(text: _initial.fullName);
  late final _mobile = TextEditingController(text: _initial.mobileNumber);
  late final _localAuthority = TextEditingController(
    text: _initial.localAuthority,
  );
  late final _neighborhood = TextEditingController(text: _initial.neighborhood);
  late final _postalCode = TextEditingController(text: _initial.postalCode);
  late final _contactName = TextEditingController(text: _initial.contactName);
  late final _relationship = TextEditingController(
    text: _initial.contactRelationship,
  );
  late final _contactPhone = TextEditingController(text: _initial.contactPhone);
  late final _email = TextEditingController(text: _initial.email);

  // Choices: plain state.
  late DateTime? _dob = _initial.dateOfBirth;
  late Gender? _gender = _initial.gender;
  late CouncilType? _councilType = _initial.councilType;
  late IsraelDistrict? _district = _initial.district;

  /// Show errors as the user types, but only after the first Save attempt,
  /// so an untouched form isn't covered in red.
  bool _submitted = false;

  PersonalDetails get _initial => widget.initialValue;

  @override
  void dispose() {
    for (final controller in [
      _fullName,
      _mobile,
      _localAuthority,
      _neighborhood,
      _postalCode,
      _contactName,
      _relationship,
      _contactPhone,
      _email,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      PersonalDetails(
        fullName: _fullName.text.trim(),
        dateOfBirth: _dob,
        gender: _gender,
        mobileNumber: _mobile.text.trim(),
        councilType: _councilType,
        district: _district,
        localAuthority: _localAuthority.text.trim(),
        neighborhood: _neighborhood.text.trim(),
        postalCode: _postalCode.text.trim(),
        contactName: _contactName.text.trim(),
        contactRelationship: _relationship.text.trim(),
        contactPhone: _contactPhone.text.trim(),
        email: _email.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final hintStyle = TTextStyles.bodySmall.copyWith(
      color: colors.textSecondary,
    );

    // Validator builders: each field passes its own message, so the error
    // says what to do ("Enter your postal code"), not just "Required".
    // A validator returns the message when invalid, or null when valid.
    FormFieldValidator<String> required(String message) =>
        (value) => (value == null || value.trim().isEmpty) ? message : null;
    FormFieldValidator<T> requiredChoice<T>(String message) =>
        (value) => value == null ? message : null;
    FormFieldValidator<String> requiredAnd(
      String emptyMessage,
      bool Function(String) isValid,
      String invalidMessage,
    ) =>
        (value) =>
            required(emptyMessage)(value) ??
            (isValid(value!) ? null : invalidMessage);

    return AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // Like CSS `gap`: space between every child.
          spacing: TSizes.formGap,
          children: [
            LabeledTextField(
              label: l10n.fullNameLabel,
              isRequired: true,
              controller: _fullName,
              validator: required(l10n.errorFullName),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Expanded(
                  child: DateField(
                    label: l10n.dateOfBirthLabel,
                    value: _dob,
                    hintText: l10n.dateHint,
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                    initialPickerDate: DateTime(DateTime.now().year - 30),
                    onChanged: (date) => setState(() => _dob = date),
                  ),
                ),
                Expanded(
                  child: SelectField<Gender>(
                    label: l10n.genderLabel,
                    isRequired: true,
                    value: _gender,
                    options: Gender.values,
                    optionLabel: (gender) => _genderLabel(l10n, gender),
                    hintText: l10n.selectHint,
                    validator: requiredChoice(l10n.errorGender),
                    onChanged: (value) => setState(() => _gender = value),
                  ),
                ),
              ],
            ),
            LabeledTextField(
              label: l10n.mobileIsraelLabel,
              isRequired: true,
              controller: _mobile,
              hintText: l10n.mobileIsraelHint,
              validator: requiredAnd(
                l10n.errorMobileEmpty,
                TValidators.isIsraeliMobile,
                l10n.errorIsraeliMobile,
              ),
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),

            FormSectionHeader(title: l10n.homeInIsraelSection),
            FormField<CouncilType>(
              initialValue: _councilType,
              validator: requiredChoice(l10n.errorCouncilType),
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: TSizes.sm,
                    runSpacing: TSizes.formGap,
                    children: [
                      for (final type in CouncilType.values)
                        SelectableChip(
                          label: _councilLabel(l10n, type),
                          isSelected: field.value == type,
                          onTap: () {
                            field.didChange(type);
                            setState(() => _councilType = type);
                          },
                        ),
                    ],
                  ),
                  if (field.hasError) FieldErrorText(field.errorText!),
                ],
              ),
            ),
            SelectField<IsraelDistrict>(
              label: l10n.districtLabel,
              isRequired: true,
              value: _district,
              options: IsraelDistrict.values,
              optionLabel: (district) => _districtLabel(l10n, district),
              hintText: l10n.selectHint,
              validator: requiredChoice(l10n.errorDistrict),
              onChanged: (value) => setState(() => _district = value),
            ),
            LabeledTextField(
              label: l10n.localAuthorityLabel,
              isRequired: true,
              controller: _localAuthority,
              validator: required(l10n.errorLocalAuthority),
              textCapitalization: TextCapitalization.words,
            ),
            LabeledTextField(
              label: l10n.neighborhoodLabel,
              isRequired: true,
              controller: _neighborhood,
              hintText: l10n.neighborhoodHint,
              validator: required(l10n.errorNeighborhood),
              textCapitalization: TextCapitalization.words,
            ),
            LabeledTextField(
              label: l10n.postalCodeLabel,
              isRequired: true,
              controller: _postalCode,
              hintText: '0000000',
              validator: requiredAnd(
                l10n.errorPostalCodeEmpty,
                TValidators.isPostalCode,
                l10n.errorPostalCode,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 7,
              autofillHints: const [AutofillHints.postalCode],
            ),
            if (widget.showHints) Text(l10n.homeHint, style: hintStyle),

            FormSectionHeader(title: l10n.nepalContactSection),
            LabeledTextField(
              label: l10n.contactNameLabel,
              isRequired: true,
              controller: _contactName,
              hintText: l10n.contactNameHint,
              validator: required(l10n.errorContactName),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Expanded(
                  child: LabeledTextField(
                    label: l10n.relationshipLabel,
                    isRequired: true,
                    controller: _relationship,
                    hintText: l10n.relationshipHint,
                    validator: required(l10n.errorRelationship),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                Expanded(
                  child: LabeledTextField(
                    label: l10n.contactPhoneLabel,
                    isRequired: true,
                    controller: _contactPhone,
                    hintText: l10n.contactPhoneHint,
                    validator: requiredAnd(
                      l10n.errorContactPhoneEmpty,
                      TValidators.isNepaliMobile,
                      l10n.errorNepaliMobile,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            LabeledTextField(
              label: l10n.emailLabel,
              controller: _email,
              hintText: l10n.emailHint,
              // Optional: only check the format when something is typed.
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ||
                      TValidators.isEmail(value)
                  ? null
                  : l10n.errorEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
            ),
            if (widget.showHints) Text(l10n.contactHint, style: hintStyle),

            FilledButton(onPressed: _submit, child: Text(widget.submitLabel)),
          ],
        ),
      ),
    );
  }

  static String _genderLabel(AppLocalizations l10n, Gender gender) =>
      switch (gender) {
        Gender.female => l10n.genderFemale,
        Gender.male => l10n.genderMale,
        Gender.other => l10n.genderOther,
      };

  static String _councilLabel(AppLocalizations l10n, CouncilType type) =>
      switch (type) {
        CouncilType.city => l10n.councilCity,
        CouncilType.local => l10n.councilLocal,
        CouncilType.regional => l10n.councilRegional,
      };

  static String _districtLabel(AppLocalizations l10n, IsraelDistrict d) =>
      switch (d) {
        IsraelDistrict.jerusalem => l10n.districtJerusalem,
        IsraelDistrict.northern => l10n.districtNorthern,
        IsraelDistrict.haifa => l10n.districtHaifa,
        IsraelDistrict.central => l10n.districtCentral,
        IsraelDistrict.telAviv => l10n.districtTelAviv,
        IsraelDistrict.southern => l10n.districtSouthern,
      };
}
