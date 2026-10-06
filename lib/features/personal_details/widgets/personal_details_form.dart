import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/validators.dart';
import '../../../widgets/date_field.dart';
import '../../../widgets/form_section_header.dart';
import '../../../widgets/labeled_field.dart';
import '../../../widgets/labeled_text_field.dart';
import '../../../widgets/link_button.dart';
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

            FormSectionHeader(title: l10n.homeInIsraelSection),
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
    _localityName = '';
    _localityId = null;
  }

  Widget _districtField(AppLocalizations l10n) => _apiSelectField<District>(
    key: 'districts',
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
    }),
  );

  /// Depends on the local authority: until one is chosen there's nothing
  /// to fetch, so it says to choose it first.
  Widget _localityField(AppLocalizations l10n) {
    final localAuthorityId = _localAuthorityId;
    if (localAuthorityId == null) {
      return _placeholderSelect<Locality>(
        key: 'localities-waiting',
        label: l10n.localityLabel,
        hint: l10n.chooseLocalAuthorityFirst,
        requiredMessage: l10n.errorLocality,
      );
    }

    final query = (localAuthorityId: localAuthorityId);
    return _apiSelectField<Locality>(
      key: ('localities', query),
      label: l10n.localityLabel,
      options: ref.watch(localityProvider(query)),
      selectedId: _localityId,
      idOf: (locality) => locality.id,
      nameOf: (locality) => locality.name,
      requiredMessage: l10n.errorLocality,
      loadErrorMessage: l10n.errorLoadLocalities,
      onRetry: () => ref.invalidate(localityProvider(query)),
      onChanged: (locality) => setState(() => _localityId = locality?.id),
    );
  }

  /// Depends on the district and authority type: until both are chosen
  /// there's nothing to fetch, so it says to choose them first.
  Widget _localAuthorityField(AppLocalizations l10n) {
    final districtId = _districtId;
    final type = _authorityType;
    if (districtId == null || type == null) {
      return _placeholderSelect<Authority>(
        key: 'authorities-waiting',
        label: l10n.localAuthorityLabel,
        hint: l10n.chooseDistrictFirst,
        requiredMessage: l10n.errorLocalAuthority,
      );
    }

    final query = (districtId: districtId, type: type);
    return _apiSelectField<Authority>(
      // Includes the query, so picking another district or type starts a
      // fresh dropdown with nothing selected.
      key: ('authorities', query),
      label: l10n.localAuthorityLabel,
      options: ref.watch(authoritiesProvider(query)),
      selectedId: _localAuthorityId,
      idOf: (authority) => authority.id,
      nameOf: (authority) => authority.name,
      requiredMessage: l10n.errorLocalAuthority,
      loadErrorMessage: l10n.errorLoadAuthorities,
      onRetry: () => ref.invalidate(authoritiesProvider(query)),
      onChanged: (authority) => setState(() {
        // Localities belong to one authority.
        if (authority?.id != _localAuthorityId) _localityId = null;
        _localAuthorityId = authority?.id;
        _localityName = authority?.name ?? '';
      }),
    );
  }

  /// A required dropdown whose options come from the API: disabled while
  /// they load, and a message with Retry if loading fails.
  Widget _apiSelectField<T>({
    required Object key,
    required String label,
    required AsyncValue<List<T>> options,
    required int? selectedId,
    required int Function(T option) idOf,
    required String Function(T option) nameOf,
    required String requiredMessage,
    required String loadErrorMessage,
    required VoidCallback onRetry,
    required ValueChanged<T?> onChanged,
  }) {
    final l10n = AppLocalizations.of(context);

    return options.when(
      data: (list) => SelectField<T>(
        // A new key once the list arrives: the dropdown is a FormField,
        // which only reads `value` when first created.
        key: ValueKey((key, 'loaded')),
        label: label,
        isRequired: true,
        // Taken from the list itself: the dropdown needs the exact same
        // object as one of its options.
        value: list.where((option) => idOf(option) == selectedId).firstOrNull,
        options: list,
        optionLabel: nameOf,
        hintText: l10n.selectHint,
        validator: (option) => option == null ? requiredMessage : null,
        onChanged: onChanged,
      ),
      loading: () => _placeholderSelect<T>(
        key: (key, 'loading'),
        label: label,
        hint: l10n.loadingHint,
        requiredMessage: requiredMessage,
      ),
      error: (error, _) => LabeledField(
        label: label,
        isRequired: true,
        errorText: loadErrorMessage,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          // Invalidating drops the failed result, so it fetches again.
          child: LinkButton(label: l10n.retry, onPressed: onRetry),
        ),
      ),
    );
  }

  /// An empty dropdown showing [hint]. Still fails validation, so Save
  /// can't go through without a choice.
  Widget _placeholderSelect<T>({
    required Object key,
    required String label,
    required String hint,
    required String requiredMessage,
  }) => SelectField<T>(
    key: ValueKey(key),
    label: label,
    isRequired: true,
    value: null,
    options: const [],
    optionLabel: (_) => '',
    hintText: hint,
    validator: (_) => requiredMessage,
    onChanged: (_) {},
  );

  static String _councilLabel(AppLocalizations l10n, AuthorityType type) =>
      switch (type) {
        AuthorityType.city => l10n.councilCity,
        AuthorityType.localCouncil => l10n.councilLocal,
        AuthorityType.regionalCouncil => l10n.councilRegional,
      };
}
