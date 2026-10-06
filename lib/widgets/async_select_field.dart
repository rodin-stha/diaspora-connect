import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'labeled_field.dart';
import 'link_button.dart';
import 'select_field.dart';

/// A required dropdown whose options come from the API: disabled while
/// they load, and a message with Retry if loading fails.
///
/// Options are matched by id, so [selectedId] can come from saved data
/// before the list has loaded.
class AsyncSelectField<T> extends StatelessWidget {
  final String label;
  final AsyncValue<List<T>> options;
  final int? selectedId;
  final int Function(T option) idOf;
  final String Function(T option) nameOf;
  final String requiredMessage;
  final String loadErrorMessage;
  final VoidCallback onRetry;
  final ValueChanged<T?> onChanged;

  const AsyncSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedId,
    required this.idOf,
    required this.nameOf,
    required this.requiredMessage,
    required this.loadErrorMessage,
    required this.onRetry,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return options.when(
      data: (list) => SelectField<T>(
        // A new key once the list arrives: the dropdown is a FormField,
        // which only reads `value` when first created.
        key: const ValueKey('loaded'),
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
      loading: () => PlaceholderSelectField<T>(
        key: const ValueKey('loading'),
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
}

/// An empty required dropdown showing [hint] ("Loading…", "Choose the
/// district first"). Still fails validation, so the form can't be
/// submitted without a choice.
class PlaceholderSelectField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final String requiredMessage;

  const PlaceholderSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.requiredMessage,
  });

  @override
  Widget build(BuildContext context) => SelectField<T>(
    label: label,
    isRequired: true,
    value: null,
    options: const [],
    optionLabel: (_) => '',
    hintText: hint,
    validator: (_) => requiredMessage,
    onChanged: (_) {},
  );
}
