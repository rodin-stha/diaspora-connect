import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';

class OtpInput extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final String semanticsLabel;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  /// Shows the boxes with a red border.
  final bool hasError;

  const OtpInput({
    super.key,
    required this.controller,
    required this.semanticsLabel,
    this.length = 5,
    this.onChanged,
    this.onCompleted,
    this.hasError = false,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _focusNode = FocusNode();

  static const double _boxWidth = 40;
  static const double _boxHeight = 52;
  static const double _gap = 10;

  @override
  void initState() {
    super.initState();
    // Redraw the boxes when focus changes (the active box is highlighted).
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final code = widget.controller.text;

    return SizedBox(
      // width: widget.length * _boxWidth + (widget.length - 1) * _gap,
      height: _boxHeight,
      child: Stack(
        children: [
          // The real input: transparent text, no cursor, no borders. It
          // fills the row, so tapping any box focuses it.
          Positioned.fill(
            child: Semantics(
              label: widget.semanticsLabel,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: widget.length,
                showCursor: false,
                enableInteractiveSelection: false,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration.collapsed(hintText: null)
                    .copyWith(
                      counterText: '',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                onChanged: (value) {
                  setState(() {});
                  widget.onChanged?.call(value);
                  if (value.length == widget.length) {
                    widget.onCompleted?.call(value);
                  }
                },
              ),
            ),
          ),
          // The boxes, drawn on top but letting taps through to the field.
          IgnorePointer(
            child: ExcludeSemantics(
              child: Row(
                spacing: _gap,
                children: [
                  for (var i = 0; i < widget.length; i++)
                    _box(
                      digit: i < code.length ? code[i] : '',
                      isActive: _focusNode.hasFocus && i == code.length,
                      colors: colors,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box({
    required String digit,
    required bool isActive,
    required AppColors colors,
  }) {
    final borderColor = widget.hasError
        ? colors.onErrorContainer
        : isActive
        ? colors.primary
        : colors.border;

    return Container(
      width: _boxWidth,
      height: _boxHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: borderColor, width: isActive ? 2 : 1),
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
      ),
      child: Text(
        digit,
        style: TTextStyles.titleLarge.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
