import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_error_message.dart';
import '../../../app/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/labeled_text_field.dart';
import '../data/saved_documents_provider.dart';
import '../data/saved_documents_repository.dart';

/// Asks for a name for the photo at [filePath], then uploads it.
///
/// Stays open with a spinner until the upload finishes, and shows the
/// error inside if it fails, so the user can retry without picking the
/// photo again. Pops `true` once uploaded.
class UploadDocumentDialog extends ConsumerStatefulWidget {
  final String filePath;

  const UploadDocumentDialog({super.key, required this.filePath});

  @override
  ConsumerState<UploadDocumentDialog> createState() =>
      _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends ConsumerState<UploadDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  bool _uploading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      await ref
          .read(savedDocumentsRepositoryProvider)
          .uploadDocument(filePath: widget.filePath, name: _name.text.trim());
      // Fetch the list again so it shows the new document.
      ref.invalidate(savedDocumentsProvider);
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = apiErrorMessage(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final error = _error;

    // While uploading, the Back button / gesture can't close it either.
    return PopScope(
      canPop: !_uploading,
      child: AlertDialog(
        title: Text(l10n.uploadDocumentTitle),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: TSizes.sm,
            children: [
              LabeledTextField(
                label: l10n.documentNameLabel,
                isRequired: true,
                controller: _name,
                hintText: l10n.documentNameHint,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.errorDocumentName
                    : null,
              ),
              if (error != null)
                Text(
                  error,
                  style: TTextStyles.bodySmall.copyWith(color: colors.accent),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            // Null disables it: too late to cancel once the file is sending.
            onPressed: _uploading ? null : () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: _uploading ? null : _upload,
            child: _uploading
                ? SizedBox.square(
                    dimension: TSizes.iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  )
                : Text(l10n.uploadAction),
          ),
        ],
      ),
    );
  }
}
