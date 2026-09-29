import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/selectable_chip.dart';
import 'data/auth_provider.dart';

/// Only Israeli numbers for now (the app is for workers in Israel).
const _countryCode = '+972';

/// 01 · Login: enter a mobile number to get a code by SMS.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    await ref
        .read(authProvider.notifier)
        .sendCode('$_countryCode ${_number.text.trim()}');
    if (!mounted) return;
    setState(() => _sending = false);
    context.push('/login/verify');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final language = ref.watch(localeProvider).languageCode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(26, 90, 26, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 28,
            children: [
              // Logo and app name
              Column(
                spacing: 10,
                children: [
                  // Same logo as the app icon. A PNG, not a themed SVG: it's
                  // multicoloured artwork, so it isn't tinted.
                  Image.asset(
                    'assets/images/logo.png',
                    height: TSizes.logoSize,
                    semanticLabel: l10n.appName,
                  ),
                  Text(
                    l10n.appName,
                    style: TTextStyles.brandTitle.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: TSizes.formGap,
                  children: [
                    FormField<String>(
                      validator: (_) => _number.text.trim().isEmpty
                          ? l10n.errorLoginMobile
                          : null,
                      builder: (field) => LabeledField(
                        label: l10n.mobileNumberLabel,
                        // As in the design, the field sits in an 80px block
                        // with room for the error message below it.
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: TSizes.fieldMinHeight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: TSizes.sm,
                                children: [
                                  _CountryCodeBox(code: _countryCode),
                                  Expanded(
                                    child: TextField(
                                      controller: _number,
                                      onChanged: field.didChange,
                                      keyboardType: TextInputType.phone,
                                      autofillHints: const [
                                        AutofillHints.telephoneNumberNational,
                                      ],
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9\- ]'),
                                        ),
                                      ],
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _sendCode(),
                                      style: TTextStyles.body.copyWith(
                                        color: colors.textPrimary,
                                      ),
                                      cursorColor: colors.primary,
                                      decoration: InputDecoration(
                                        hintText: l10n.mobileNumberHint,
                                        error: field.hasError
                                            ? const SizedBox.shrink()
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (field.hasError)
                                FieldErrorText(field.errorText!),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: _sending ? null : _sendCode,
                      child: Text(l10n.sendOtp),
                    ),
                    Wrap(
                      spacing: TSizes.sm,
                      children: [
                        // Language names in their own script, so people can
                        // find theirs whatever the current language.
                        for (final (code, name) in [
                          ('ne', 'नेपाली'),
                          ('en', 'English'),
                        ])
                          SelectableChip(
                            label: name,
                            isSelected: language == code,
                            onTap: () => ref
                                .read(localeProvider.notifier)
                                .setLocale(Locale(code)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              Text(
                l10n.loginConsent,
                style: TTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The fixed "+972" box next to the number field.
class _CountryCodeBox extends StatelessWidget {
  final String code;

  const _CountryCodeBox({required this.code});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
      ),
      child: Text(
        code,
        style: TTextStyles.body.copyWith(color: colors.textSecondary),
      ),
    );
  }
}
