import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';
import 'labeled_field.dart';

/// A labeled date input: shows DD/MM/YYYY and opens the date picker on tap.
/// Looks like the text inputs.
class DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? hintText;
  final FormFieldValidator<DateTime>? validator;
  final bool isRequired;

  /// Range the picker allows.
  final DateTime firstDate;
  final DateTime lastDate;

  /// Where the picker opens when there's no value yet (e.g. 30 years ago
  /// for a date of birth).
  final DateTime? initialPickerDate;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.initialPickerDate,
    this.hintText,
    this.validator,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        Future<void> pick() async {
          final picked = await showDatePicker(
            context: context,
            initialDate: field.value ?? initialPickerDate ?? lastDate,
            firstDate: firstDate,
            lastDate: lastDate,
            initialEntryMode: DatePickerEntryMode.calendarOnly,
          );
          if (picked == null) return;
          field.didChange(picked);
          onChanged(picked);
        }

        return LabeledField(
          label: label,
          isRequired: isRequired,
          errorText: field.errorText,
          child: Semantics(
            button: true,
            child: GestureDetector(
              onTap: pick,
              behavior: HitTestBehavior.opaque,
              // InputDecorator draws the same box as a TextField, and shows
              // the hint while empty.
              child: InputDecorator(
                isEmpty: field.value == null,
                decoration: InputDecoration(
                  hintText: hintText,
                  error: field.hasError ? const SizedBox.shrink() : null,
                ),
                child: Text(
                  field.value == null
                      ? ''
                      : TFormatters.shortDate(field.value!),
                  style: TTextStyles.body.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
