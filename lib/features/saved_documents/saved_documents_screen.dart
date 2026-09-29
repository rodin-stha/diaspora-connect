import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/sizes.dart';
import '../../widgets/back_title_bar.dart';
import '../../widgets/dashed_button.dart';
import '../../widgets/document_row.dart';
import 'data/saved_documents_provider.dart';
import 'models/saved_document.dart';

/// Profile → Saved documents: every document, plus uploading a new one.
class SavedDocumentsScreen extends ConsumerWidget {
  const SavedDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final documents = ref.watch(savedDocumentsProvider);

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    void showMessage(String message) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            TSizes.pagePadding,
            topPadding,
            TSizes.pagePadding,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: TSizes.md,
            children: [
              BackTitleBar(
                title: l10n.savedDocuments,
                fallbackLocation: '/profile',
              ),
              for (final document in documents)
                DocumentRow(
                  name: _documentName(l10n, document),
                  actionLabel: l10n.viewAction,
                  // TODO: open the file once documents are stored on the
                  // backend.
                  onAction: () => showMessage(l10n.viewComingSoon),
                ),
              DashedButton(
                label: l10n.uploadNewDocument,
                // TODO: pick a file, ask for its name, then
                // otherDocumentsProvider.notifier.add(...).
                onPressed: () => showMessage(l10n.uploadComingSoon),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _documentName(AppLocalizations l10n, SavedDocument doc) =>
      switch (doc.type) {
        DocumentType.passportPhotoPage => l10n.documentPassportPhotoPage,
        DocumentType.israelVisaPage => l10n.documentIsraelVisaPage,
        DocumentType.workPermitLetter => l10n.documentWorkPermitLetter,
        DocumentType.other => doc.customName ?? doc.fileName,
      };
}
