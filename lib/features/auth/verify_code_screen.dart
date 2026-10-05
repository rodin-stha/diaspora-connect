import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/api/api_error_message.dart';
import '../../app/api/api_exception.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/back_title_bar.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/link_button.dart';
import '../../widgets/loading_button.dart';
import 'data/auth_provider.dart';
import 'widgets/otp_input.dart';

class VerifyCodeScreen extends ConsumerStatefulWidget {
  const VerifyCodeScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  static const _codeLength = 6;

  final _code = TextEditingController();
  String? _error;
  bool _verifying = false;

  // "Resend in 00:42" countdown.
  Timer? _timer;
  Duration _resendIn = Duration(seconds: 60);

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
    final expireOtpTime = ref.read(authProvider).otpExpireTime ?? 60;
    setState(() => _resendIn = Duration(seconds: expireOtpTime));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _resendIn -= const Duration(seconds: 1));
      if (_resendIn == Duration.zero) timer.cancel();
    });
  }

  Future<void> _resend() async {
    final phone = ref.read(authProvider).pendingPhone;
    if (phone == null) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authProvider.notifier).register(phone);
      _startCountdown();
      messenger.showSnackBar(SnackBar(content: Text(l10n.codeResent)));
    } on ApiException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("failed")),
      );
    }
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    try {
      if (_code.text.length < _codeLength) {
        setState(() => _error = l10n.errorOtpIncomplete);
        return;
      }
      setState(() => _verifying = true);
      await ref
          .read(authProvider.notifier)
          .verifyCode(widget.phone, _code.text);
      if (!mounted) return;
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiErrorMessage(AppLocalizations.of(context), e)),
        ),
      );
    } finally {
      setState(() {
        _verifying = false;
      });
    }
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
                LoadingButton(
                  label: l10n.verifyAction,
                  onPressed: _verify,
                  isLoading: _verifying,
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
