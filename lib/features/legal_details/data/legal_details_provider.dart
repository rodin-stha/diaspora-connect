import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/legal_details.dart';
import 'legal_details_repository.dart';

/// The signed-in user's identity documents.
///
/// Returns sample data until the backend API exists.
final legalDetailsProvider =
    NotifierProvider<LegalDetailsNotifier, LegalDetails>(
      LegalDetailsNotifier.new,
    );

class LegalDetailsNotifier extends Notifier<LegalDetails> {
  @override
  LegalDetails build() => _sample;

  Future<void> save(LegalDetails details) async {
    await ref.read(legalDetailsRepositroy).saveLegalDetails(details);
    state = details;
  }
}

const _sample = LegalDetails(
  passportNumber: '',
  nationalId: '',
  citizenshipCertificateNumber: '',
  passportPhotoPage: 'passport_photo_page.jpg',
  israelVisaPage: 'israel_visa_page.jpg',
);
