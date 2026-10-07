import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/legal_details.dart';
import 'legal_details_repository.dart';

/// The signed-in user's identity documents.
final legalDetailsProvider =
    AsyncNotifierProvider<LegalDetailsNotifier, LegalDetails>(
      LegalDetailsNotifier.new,
    );

class LegalDetailsNotifier extends AsyncNotifier<LegalDetails> {
  @override
  Future<LegalDetails> build() =>
      ref.read(legalDetailsRepositroy).fetchlegalDetails();

  Future<void> save(LegalDetails details) async {
    await ref.read(legalDetailsRepositroy).saveLegalDetails(details);
    state = AsyncData(details);
  }
}
