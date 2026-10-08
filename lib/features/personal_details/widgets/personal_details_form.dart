import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/validators.dart';
import '../../../widgets/async_select_field.dart';
import '../../../widgets/date_field.dart';
import '../../../widgets/form_section_header.dart';
import '../../../widgets/labeled_field.dart';
import '../../../widgets/labeled_text_field.dart';
import '../../../widgets/loading_button.dart';
import '../../../widgets/select_field.dart';
import '../../../widgets/selectable_chip.dart';
import '../data/personal_details_provider.dart';
import '../models/authority.dart';
import '../models/district.dart';
import '../models/locality.dart';
import '../models/personal_details.dart';

class PersonalDetailsForm extends ConsumerStatefulWidget {
  final PersonalDetails initialValue;
  final String submitLabel;

  final Future<void> Function(PersonalDetails) onSubmit;

  final bool showHints;

  const PersonalDetailsForm({
    super.key,
    required this.initialValue,
    required this.submitLabel,
    required this.onSubmit,
    this.showHints = false,
  });

  @override
  ConsumerState<PersonalDetailsForm> createState() =>
      _PersonalDetailsFormState();
}

class _PersonalDetailsFormState extends ConsumerState<PersonalDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  // Text fields: a controller each (like a ref to an uncontrolled input).
  late final _fullName = TextEditingController(text: _initial.name);
  late final _neighborhood = TextEditingController(
    text: _initial.neighborhoodName,
  );
  late final _postalCode = TextEditingController(text: _initial.postalCode);
  late final _contactName = TextEditingController(
    text: _initial.contactPersonName,
  );
  late final _relationship = TextEditingController(
    text: _initial.contactPersonRelationship,
  );
  late final _contactPhone = TextEditingController(
    text: _initial.contactPersonContact,
  );
  late final _email = TextEditingController(text: _initial.contactPersonEmail);

  // Choices: plain state.
  late DateTime? _dob = _initial.dob;
  late Gender? _gender = _initial.gender;
  late AuthorityType? _authorityType = _initial.authorityType;

  late int? _districtId = _initial.districtId;
  late int? _localAuthorityId = _initial.localAuthorityId;
  late int? _localityId = _initial.localityId;
  // Names of the choices above, for Home and Profile to show.
  late String _districtName = _initial.districtName;
  late String _localAuthorityName = _initial.localAuthorityName;
  late String _localityName = _initial.localityName;

  bool _submitted = false;

  bool _saving = false;

  PersonalDetails get _initial => widget.initialValue;

  @override
  void dispose() {
    for (final controller in [
      _fullName,
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

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await widget.onSubmit(
        PersonalDetails(
          name: _fullName.text.trim(),
          dob: _dob,
          gender: _gender,
          authorityType: _authorityType,
          districtId: _districtId,
          localAuthorityId: _localAuthorityId,
          localityId: _localityId,
          districtName: _districtName,
          localAuthorityName: _localAuthorityName,
          localityName: _localityName,
          neighborhoodName: _neighborhood.text.trim(),
          postalCode: _postalCode.text.trim(),
          contactPersonName: _contactName.text.trim(),
          contactPersonRelationship: _relationship.text.trim(),
          contactPersonContact: _contactPhone.text.trim(),
          contactPersonEmail: _email.text.trim(),
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

            // The council type chips below have no label of their own:
            // this heading is it, so it carries their "required" mark.
            FormSectionHeader(
              title: l10n.homeInIsraelSection,
              isRequired: true,
            ),
            FormField<AuthorityType>(
              initialValue: _authorityType,
              validator: requiredChoice(l10n.errorCouncilType),
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: TSizes.sm,
                    runSpacing: TSizes.formGap,
                    children: [
                      for (final type in AuthorityType.values)
                        SelectableChip(
                          label: _councilLabel(l10n, type),
                          isSelected: field.value == type,
                          onTap: () {
                            field.didChange(type);
                            setState(() {
                              if (type != _authorityType) {
                                _clearLocalAuthority();
                              }
                              _authorityType = type;
                            });
                          },
                        ),
                    ],
                  ),
                  if (field.hasError) FieldErrorText(field.errorText!),
                ],
              ),
            ),
            _districtField(l10n),
            _localAuthorityField(l10n),
            _localityField(l10n),
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

            LoadingButton(
              label: widget.submitLabel,
              isLoading: _saving,
              onPressed: _submit,
            ),
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

  /// The chosen authority belongs to a district and type, so it's cleared
  /// when either changes (and the locality with it). Call inside setState.
  void _clearLocalAuthority() {
    _localAuthorityId = null;
    _localAuthorityName = '';
    _clearLocality();
  }

  /// The chosen locality belongs to one authority. Call inside setState.
  void _clearLocality() {
    _localityId = null;
    _localityName = '';
  }

  Widget _districtField(AppLocalizations l10n) => AsyncSelectField<District>(
    key: const ValueKey('districts'),
    label: l10n.districtLabel,
    options: ref.watch(districtsProvider),
    selectedId: _districtId,
    idOf: (district) => district.id,
    nameOf: (district) => district.name,
    requiredMessage: l10n.errorDistrict,
    loadErrorMessage: l10n.errorLoadDistricts,
    onRetry: () => ref.invalidate(districtsProvider),
    onChanged: (district) => setState(() {
      if (district?.id != _districtId) _clearLocalAuthority();
      _districtId = district?.id;
      _districtName = district?.name ?? '';
    }),
  );

  /// Depends on the local authority: until one is chosen there's nothing
  /// to fetch, so it says to choose it first.
  Widget _localityField(AppLocalizations l10n) {
    final localAuthorityId = _localAuthorityId;
    if (localAuthorityId == null) {
      return PlaceholderSelectField<Locality>(
        key: const ValueKey('localities-waiting'),
        label: l10n.localityLabel,
        hint: l10n.chooseLocalAuthorityFirst,
        requiredMessage: l10n.errorLocality,
      );
    }

    final query = (localAuthorityId: localAuthorityId);
    return AsyncSelectField<Locality>(
      key: ValueKey(('localities', query)),
      label: l10n.localityLabel,
      options: ref.watch(localityProvider(query)),
      selectedId: _localityId,
      idOf: (locality) => locality.id,
      nameOf: (locality) => locality.name,
      requiredMessage: l10n.errorLocality,
      loadErrorMessage: l10n.errorLoadLocalities,
      onRetry: () => ref.invalidate(localityProvider(query)),
      onChanged: (locality) => setState(() {
        _localityId = locality?.id;
        _localityName = locality?.name ?? '';
      }),
    );
  }

  /// Depends on the district and authority type: until both are chosen
  /// there's nothing to fetch, so it says to choose them first.
  Widget _localAuthorityField(AppLocalizations l10n) {
    final districtId = _districtId;
    final type = _authorityType;
    if (districtId == null || type == null) {
      return PlaceholderSelectField<Authority>(
        key: const ValueKey('authorities-waiting'),
        label: l10n.localAuthorityLabel,
        hint: l10n.chooseDistrictFirst,
        requiredMessage: l10n.errorLocalAuthority,
      );
    }

    final query = (districtId: districtId, type: type);
    return AsyncSelectField<Authority>(
      // Includes the query, so picking another district or type starts a
      // fresh dropdown with nothing selected.
      key: ValueKey(('authorities', query)),
      label: l10n.localAuthorityLabel,
      options: ref.watch(authoritiesProvider(query)),
      selectedId: _localAuthorityId,
      idOf: (authority) => authority.id,
      nameOf: (authority) => authority.name,
      requiredMessage: l10n.errorLocalAuthority,
      loadErrorMessage: l10n.errorLoadAuthorities,
      onRetry: () => ref.invalidate(authoritiesProvider(query)),
      onChanged: (authority) => setState(() {
        if (authority?.id != _localAuthorityId) _clearLocality();
        _localAuthorityId = authority?.id;
        _localAuthorityName = authority?.name ?? '';
      }),
    );
  }

  static String _councilLabel(AppLocalizations l10n, AuthorityType type) =>
      switch (type) {
        AuthorityType.city => l10n.councilCity,
        AuthorityType.localCouncil => l10n.councilLocal,
        AuthorityType.regionalCouncil => l10n.councilRegional,
      };
}
