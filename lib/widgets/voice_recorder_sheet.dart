import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';

/// Records a voice note in a bottom sheet with a timer, Stop and Cancel.
/// Returns the audio file and its length, or null if the user cancelled or
/// microphone access was denied (then it shows a message).
Future<({String path, Duration duration})?> recordVoiceNote(
  BuildContext context,
) async {
  final recorder = AudioRecorder();
  // Asks the first time; false if the user said no (now or before).
  if (!await recorder.hasPermission()) {
    await recorder.dispose();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorMicrophoneAccess),
        ),
      );
    }
    return null;
  }
  if (!context.mounted) {
    await recorder.dispose();
    return null;
  }

  return showModalBottomSheet<({String path, Duration duration})>(
    context: context,
    backgroundColor: context.colors.surface,
    // No swipe/tap-outside to close: losing a recording by accident is
    // worse than one extra tap on Cancel.
    isDismissible: false,
    enableDrag: false,
    builder: (_) => _VoiceRecorderSheet(recorder: recorder),
  );
}

class _VoiceRecorderSheet extends StatefulWidget {
  final AudioRecorder recorder;

  const _VoiceRecorderSheet({required this.recorder});

  @override
  State<_VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

class _VoiceRecorderSheetState extends State<_VoiceRecorderSheet> {
  /// Long enough to explain what happened, short enough to upload on a
  /// slow connection. Stops by itself at this length.
  static const _maxLength = Duration(minutes: 3);

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    // AAC in .m4a: small files, and plays on both iOS and Android.
    await widget.recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
      if (_elapsed >= _maxLength) _stop();
    });
  }

  Future<void> _stop() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    final path = await widget.recorder.stop();
    if (!mounted) return;
    Navigator.pop(
      context,
      path == null ? null : (path: path, duration: _elapsed),
    );
  }

  Future<void> _cancel() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    await widget.recorder.cancel(); // Stops and deletes the file.
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: TSizes.lg,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: TSizes.sm,
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  size: TSizes.iconSm,
                  color: colors.accent,
                ),
                Text(
                  l10n.recordingTitle,
                  style: TTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '${TFormatters.duration(_elapsed)} / '
              '${TFormatters.duration(_maxLength)}',
              style: TTextStyles.titleLarge.copyWith(
                color: colors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Row(
              spacing: TSizes.md,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancel,
                    child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel,
                    ),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: _stop,
                    child: Text(l10n.stopRecording),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
