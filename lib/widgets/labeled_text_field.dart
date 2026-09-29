import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'labeled_field.dart';

/// A labeled text input for forms. Border, padding and hint style come from
/// the theme's `inputDecorationTheme`.
///
/// Built as a `FormField` around a plain `TextField` (instead of using
/// `TextFormField`) so the error message can sit under the box, aligned with
/// the label. Flutter's built-in error text is always indented to line up
/// with the text inside the box.
class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final FormFieldValidator<String>? validator;

  /// Adds a red "*" to the label. Separate from [validator] because optional
  /// fields can still be validated (e.g. email format).
  final bool isRequired;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// Lets the OS offer saved values (name, phone, email…).
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.validator,
    this.isRequired = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FormField<String>(
      // Always validate the controller's current text, so changes made in
      // code (e.g. a date picker filling the field) are seen too.
      validator: validator == null ? null : (_) => validator!(controller.text),
      builder: (field) => LabeledField(
        label: label,
        isRequired: isRequired,
        errorText: field.errorText,
        child: TextField(
          controller: controller,
          // Tells the Form the value changed, so live validation re-runs.
          onChanged: field.didChange,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          maxLength: maxLength,
          readOnly: readOnly,
          onTap: onTap,
          style: TTextStyles.body.copyWith(color: colors.textPrimary),
          cursorColor: colors.primary,
          decoration: InputDecoration(
            hintText: hintText,
            // Hide the "3/7" counter that maxLength adds.
            counterText: '',
            // Red border without Flutter's own (indented) message;
            // LabeledField shows the message instead.
            error: field.hasError ? const SizedBox.shrink() : null,
          ),
        ),
      ),
    );
  }
}
