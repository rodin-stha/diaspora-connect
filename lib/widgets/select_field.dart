import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import 'labeled_field.dart';

/// Minimum height of a dense `DropdownButton` (Flutter's private
/// `_kDenseButtonHeight`).
const double _dropdownMinHeight = 24.0;

/// A labeled dropdown for picking one of [options], styled like the text
/// inputs.
///
/// Like [LabeledTextField], a `FormField` around a plain `DropdownButton`
/// so the error message lines up with the label.
class SelectField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> options;

  /// Text shown for each option.
  final String Function(T option) optionLabel;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final FormFieldValidator<T>? validator;

  /// Adds a red "*" to the label.
  final bool isRequired;

  const SelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
    this.hintText,
    this.validator,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyle = TTextStyles.body.copyWith(color: colors.textPrimary);

    // A dense DropdownButton is at least 24px tall, taller than our 19.6px
    // text line, so it'd be a few px taller than the text inputs. Take the
    // difference out of the vertical padding. (With a large text size the
    // line is taller than 24px and nothing changes.)
    final lineHeight =
        MediaQuery.textScalerOf(context).scale(textStyle.fontSize!) *
        textStyle.height!;
    final extra = math.max(0.0, _dropdownMinHeight - lineHeight);
    final themePadding = Theme.of(
      context,
    ).inputDecorationTheme.contentPadding!.resolve(Directionality.of(context));
    final contentPadding = themePadding.copyWith(
      top: themePadding.top - extra / 2,
      bottom: themePadding.bottom - extra / 2,
    );

    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (field) => LabeledField(
        label: label,
        isRequired: isRequired,
        errorText: field.errorText,
        // InputDecorator draws the same box as a TextField (from the theme).
        child: InputDecorator(
          isEmpty: field.value == null,
          decoration: InputDecoration(
            contentPadding: contentPadding,
            error: field.hasError ? const SizedBox.shrink() : null,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: field.value,
              items: [
                for (final option in options)
                  DropdownMenuItem(
                    value: option,
                    child: Text(optionLabel(option)),
                  ),
              ],
              onChanged: (selected) {
                field.didChange(selected);
                onChanged(selected);
              },
              hint: hintText == null
                  ? null
                  : Text(
                      hintText!,
                      style: TTextStyles.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
              isExpanded: true,
              // Same height as the text inputs (the default is taller).
              isDense: true,
              style: textStyle,
              dropdownColor: colors.surface,
              borderRadius: BorderRadius.circular(TSizes.inputRadius),
              icon: SvgPicture.asset(
                'assets/icons/chevron_down.svg',
                width: TSizes.iconSm,
                height: TSizes.iconSm,
                colorFilter: ColorFilter.mode(
                  colors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
