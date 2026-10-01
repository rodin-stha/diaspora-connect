import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/back_title_bar.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/link_button.dart';
import 'data/auth_provider.dart';
import 'widgets/otp_input.dart';

/// 02 · Verify code: enter the 6-digit code sent by SMS.
///
/// On success there's no navigation here: signing in changes [authProvider],
/// and the router's redirect takes the user to Home (or to onboarding, the
/// first time).
class VerifyCodeScreen extends ConsumerStatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  static const _codeLength = 6;
  static const _resendAfter = Duration(seconds: 60);

  final _code = TextEditingController();
  String? _error;
  bool _verifying = false;

  // "Resend in 00:42" countdown.
  Timer? _timer;
  Duration _resendIn = _resendAfter;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    // Timers keep running after the screen closes unless cancelled.
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendIn = _resendAfter);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _resendIn -= const Duration(seconds: 1));
      if (_resendIn == Duration.zero) timer.cancel();
    });
  }

  Future<void> _resend() async {
    final phone = ref.read(authProvider).pendingPhone;
    if (phone == null) return;
    await ref.read(authProvider.notifier).sendCode(phone);
    if (!mounted) return;
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).codeResent)),
    );
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    if (_code.text.length < _codeLength) {
      setState(() => _error = l10n.errorOtpIncomplete);
      return;
    }
    setState(() => _verifying = true);
    final ok = await ref.read(authProvider.notifier).verifyCode(_code.text);
    if (!mounted) return;
    setState(() {
      _verifying = false;
      if (!ok) _error = l10n.errorOtpWrong;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final phone = ref.watch(authProvider).pendingPhone ?? '';
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);
    final smallText = TTextStyles.bodySmall.copyWith(
      color: colors.textSecondary,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              TSizes.pagePadding,
              topPadding,
              TSizes.pagePadding,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: TSizes.lg,
              children: [
                const BackTitleBar(fallbackLocation: '/login'),
                Text(
                  l10n.verifyTitle,
                  style: TTextStyles.pageHeading.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(l10n.verifySubtitle(phone), style: smallText),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OtpInput(
                      controller: _code,
                      length: _codeLength,
                      semanticsLabel: l10n.otpFieldLabel,
                      hasError: _error != null,
                      // Clear the error as soon as the user edits the code.
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                    ),
                    if (_error != null) FieldErrorText(_error!),
                  ],
                ),
                Row(
                  children: [
                    Text('${l10n.resendPrompt} ', style: smallText),
                    if (_resendIn > Duration.zero)
                      Text(l10n.resendIn(_format(_resendIn)), style: smallText)
                    else
                      LinkButton(label: l10n.resendAction, onPressed: _resend),
                  ],
                ),
                FilledButton(
                  onPressed: _verifying ? null : _verify,
                  child: Text(l10n.verifyAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 42 seconds → "00:42".
  static String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }
}
