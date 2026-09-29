import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/legal_details.dart';

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

  void save(LegalDetails details) => state = details;
}

// As in the Figma design: fields empty (placeholders), both scans uploaded.
const _sample = LegalDetails(
  passportNumber: '',
  nationalId: '',
  citizenshipCertificateNumber: '',
  passportPhotoPage: 'passport_photo_page.jpg',
  israelVisaPage: 'israel_visa_page.jpg',
);
