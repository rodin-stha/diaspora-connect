import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../legal_details/data/legal_details_provider.dart';
import '../../work_details/data/work_details_provider.dart';
import '../models/saved_document.dart';

/// Every document the user has saved, as listed on Profile → Saved
/// documents.
///
/// The passport and visa scans belong to Legal details, and the work permit
/// to Work details, so they're read from those providers rather than copied
/// here: one source of truth, and replacing a scan there updates this list.
final savedDocumentsProvider = Provider<List<SavedDocument>>((ref) {
  final legal = ref.watch(legalDetailsProvider);
  final work = ref.watch(workDetailsProvider);

  return [
    if (legal.passportPhotoPage case final file?)
      SavedDocument(type: DocumentType.passportPhotoPage, fileName: file),
    if (legal.israelVisaPage case final file?)
      SavedDocument(type: DocumentType.israelVisaPage, fileName: file),
    if (work.workPermitLetter case final file?)
      SavedDocument(type: DocumentType.workPermitLetter, fileName: file),
    ...ref.watch(otherDocumentsProvider),
  ];
});

/// Documents the user uploaded that don't belong to another form (salary
/// slips, contracts, …). Empty until uploads exist.
final otherDocumentsProvider =
    NotifierProvider<OtherDocumentsNotifier, List<SavedDocument>>(
      OtherDocumentsNotifier.new,
    );

class OtherDocumentsNotifier extends Notifier<List<SavedDocument>> {
  @override
  List<SavedDocument> build() => const [];

  void add(SavedDocument document) => state = [...state, document];
}
