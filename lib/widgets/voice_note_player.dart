import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../utils/formatters.dart';
import 'attachment_row.dart';

/// A recorded voice note as an attachment: ▶/⏸ to listen back, how far it
/// has played, and ✕ to remove it.
class VoiceNotePlayer extends StatefulWidget {
  final String title;
  final String path;
  final Duration duration;
  final VoidCallback onRemove;

  const VoiceNotePlayer({
    super.key,
    required this.title,
    required this.path,
    required this.duration,
    required this.onRemove,
  });

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  final _player = AudioPlayer();
  final _subscriptions = <StreamSubscription<Object?>>[];
  bool _playing = false;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Streams are like event listeners: keep the subscriptions so they can
    // be cancelled in dispose (like removeEventListener on unmount).
    _subscriptions
      ..add(
        _player.onPlayerStateChanged.listen(
          (state) => setState(() => _playing = state == PlayerState.playing),
        ),
      )
      ..add(
        _player.onPositionChanged.listen(
          (position) => setState(() => _position = position),
        ),
      )
      ..add(
        _player.onPlayerComplete.listen(
          (_) => setState(() => _position = Duration.zero),
        ),
      );
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _player.pause();
    } else if (_position > Duration.zero) {
      await _player.resume();
    } else {
      await _player.play(DeviceFileSource(widget.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final progress = _position > Duration.zero
        ? '${TFormatters.duration(_position)} / '
        : '';

    return AttachmentRow(
      leading: IconButton.filledTonal(
        onPressed: _togglePlay,
        tooltip: _playing ? l10n.pauseAction : l10n.playAction,
        icon: Icon(
          _playing ? Icons.pause : Icons.play_arrow,
          size: TSizes.iconMd,
        ),
        color: colors.primary,
      ),
      title: widget.title,
      subtitle: '$progress${TFormatters.duration(widget.duration)}',
      onRemove: widget.onRemove,
    );
  }
}
