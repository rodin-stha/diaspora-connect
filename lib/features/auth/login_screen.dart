import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/api/api_error_message.dart';
import '../../app/api/api_exception.dart';
import '../../app/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/selectable_chip.dart';
import 'data/auth_provider.dart';

/// Only Israeli numbers for now (the app is for workers in Israel).
const _countryCode = '+977';

/// A brand name, so it's the same in every language (not in the ARB files).
const _companyName = 'Kumo Labs™';

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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    final phoneNumber = '$_countryCode ${_number.text.trim()}';
    try {
      await ref.read(authProvider.notifier).register(phoneNumber);
      if (!mounted) return;
      context.push('/login/verify', extra: phoneNumber);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiErrorMessage(AppLocalizations.of(context), e)),
        ),
      );
    } finally {
      // Runs on success and failure, so the button never stays disabled.
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final language = ref.watch(localeProvider).languageCode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
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
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(),
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
                                        onSubmitted: (_) => _register(),
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
                      LoadingButton(
                        label: l10n.sendOtp,
                        onPressed: _register,
                        isLoading: _sending,
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
          // Scaffold's bottom slot keeps the credit pinned to the bottom of
          // the screen, below the scrolling form. The keyboard covers it
          // instead of pushing it up over the form.
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.only(bottom: TSizes.lg),
            child: Text(
              l10n.developedBy(_companyName),
              textAlign: TextAlign.center,
              style: TTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
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
