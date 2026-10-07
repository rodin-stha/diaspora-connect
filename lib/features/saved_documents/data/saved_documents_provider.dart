import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/saved_document.dart';
import 'saved_documents_repository.dart';

/// Every document the user has uploaded, as listed on Profile → Saved
/// documents.
///
/// autoDispose: thrown away when the screen closes, so each visit fetches
/// again. That picks up scans just replaced in Legal details, and fresh
/// links (the file URLs expire).
final savedDocumentsProvider = FutureProvider.autoDispose<List<SavedDocument>>(
  (ref) => ref.read(savedDocumentsRepositoryProvider).fetchDocuments(),
);
