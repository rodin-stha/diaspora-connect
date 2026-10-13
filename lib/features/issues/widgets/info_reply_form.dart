import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_error_message.dart';
import '../../../app/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/sizes.dart';
import '../../../widgets/dashed_tile.dart';
import '../../../widgets/image_source_sheet.dart';
import '../../../widgets/labeled_text_field.dart';
import '../../../widgets/loading_button.dart';
import '../../../widgets/removable_thumbnail.dart';
import '../data/issues_provider.dart';

/// The user's answer to a case worker on an issue that "Needs info": a
/// message, a photo, or both.
class InfoReplyForm extends ConsumerStatefulWidget {
  /// The issue being answered.
  final String reference;

  const InfoReplyForm({super.key, required this.reference});

  @override
  ConsumerState<InfoReplyForm> createState() => _InfoReplyFormState();
}

class _InfoReplyFormState extends ConsumerState<InfoReplyForm> {
  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();

  /// Path of the picked photo on this device; null for none.
  String? _photo;

  /// Show errors as the user types, but only after the first Send attempt.
  bool _submitted = false;

  /// True while the reply is being sent: shows the spinner and blocks a
  /// second tap from sending it twice.
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  /// Picks the photo; a new one replaces the previous (the API takes one).
  Future<void> _pickPhoto() async {
    final image = await pickImage(context);
    if (image == null) return;
    setState(() => _photo = image.path);
    // A photo alone is a valid reply: clear "write a reply or add a photo".
    if (_submitted) _formKey.currentState!.validate();
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _send() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(issuesProvider.notifier)
          .reply(
            widget.reference,
            message: _message.text.trim(),
            photoPath: _photo,
          );
    } on ApiException catch (e) {
      if (mounted) _showMessage(apiErrorMessage(l10n, e));
      return;
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    if (!mounted) return;

    // Empty the form: if the issue still needs info, it stays on screen.
    _message.clear();
    setState(() {
      _photo = null;
      _submitted = false;
    });
    _showMessage(l10n.replySent);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: TSizes.lg,
        children: [
          LabeledTextField(
            label: l10n.replyLabel,
            controller: _message,
            hintText: l10n.replyHint,
            // Optional, but a reply needs something: text or a photo.
            validator: (value) =>
                (value == null || value.trim().isEmpty) && _photo == null
                ? l10n.errorReply
                : null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 6,
          ),
          if (_photo case final photo?)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: RemovableThumbnail(
                imagePath: photo,
                onRemove: () => setState(() => _photo = null),
              ),
            )
          else
            DashedTile(
              label: l10n.replyAddPhoto,
              iconAsset: 'assets/icons/camera.svg',
              onTap: _pickPhoto,
            ),
          LoadingButton(
            label: l10n.sendReply,
            isLoading: _sending,
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}
