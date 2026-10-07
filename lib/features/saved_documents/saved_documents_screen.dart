import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/sizes.dart';
import '../../widgets/app_background.dart';
import '../../widgets/back_title_bar.dart';
import '../../widgets/dashed_button.dart';
import '../../widgets/document_row.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/load_error.dart';
import '../../widgets/skeleton.dart';
import 'data/saved_documents_provider.dart';
import 'models/saved_document.dart';

// Placeholder rows while the list loads: most users have a passport,
// a visa and a work permit.
const _skeletonCount = 3;

/// Profile → Saved documents: every uploaded document, plus uploading a
/// new one.
class SavedDocumentsScreen extends ConsumerWidget {
  const SavedDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final documentsAsync = ref.watch(savedDocumentsProvider);

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    void showMessage(String message) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    // Opens the file over the app (Safari View Controller / Chrome Custom
    // Tabs), which shows images and PDFs alike; closing it returns here.
    Future<void> view(SavedDocument document) async {
      final opened = await launchUrl(
        Uri.parse(document.url),
        mode: LaunchMode.inAppBrowserView,
      );
      if (!opened && context.mounted) showMessage(l10n.errorOpenDocument);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          // Pull down to fetch again, e.g. after a file link has expired.
          body: RefreshIndicator(
            onRefresh: () => ref.refresh(savedDocumentsProvider.future),
            child: SingleChildScrollView(
              // Lets the pull work even when the list is too short to scroll.
              physics: const AlwaysScrollableScrollPhysics(),
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
                  documentsAsync.when(
                    data: (documents) => documents.isEmpty
                        ? EmptyState(
                            iconAsset: 'assets/icons/document.svg',
                            message: l10n.noSavedDocuments,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: TSizes.md,
                            children: [
                              for (final document in documents)
                                DocumentRow(
                                  name: _documentName(l10n, document),
                                  actionLabel: l10n.viewAction,
                                  onAction: () => view(document),
                                ),
                            ],
                          ),
                    // Placeholder rows in the shape of the real list, so
                    // nothing jumps when it arrives.
                    loading: () => Skeleton(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: TSizes.md,
                        children: [
                          for (var i = 0; i < _skeletonCount; i++)
                            const DocumentRowSkeleton(),
                        ],
                      ),
                    ),
                    error: (error, _) => LoadError(
                      message: l10n.errorLoadDocuments,
                      onRetry: () => ref.invalidate(savedDocumentsProvider),
                    ),
                    // Retry after an error shows the spinner; a pull-to-refresh
                    // keeps the list (the pull has its own spinner).
                    skipLoadingOnRefresh: !documentsAsync.hasError,
                  ),
                  DashedButton(
                    label: l10n.uploadNewDocument,
                    // TODO: pick a file, ask for its name, upload it, then
                    // ref.invalidate(savedDocumentsProvider).
                    onPressed: () => showMessage(l10n.uploadComingSoon),
                  ),
                ],
              ),
            ),
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
        DocumentType.other => doc.name,
      };
}
