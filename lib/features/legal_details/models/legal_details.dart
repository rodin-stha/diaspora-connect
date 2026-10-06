/// Identity documents (Profile → Legal details, and onboarding step 2).
class LegalDetails {
  final String passportNumber;
  final DateTime? passportExpiry;

  /// Nepal National ID number. Optional: not everyone has one yet.
  final String nationalId;
  final String citizenshipCertificateNumber;

  /// Uploaded scans, as file names; null when not uploaded yet.
  final String? passportPhotoPage;
  final String? israelVisaPage;

  const LegalDetails({
    required this.passportNumber,
    this.passportExpiry,
    required this.nationalId,
    required this.citizenshipCertificateNumber,
    required this.passportPhotoPage,
    required this.israelVisaPage,
  });

  const LegalDetails.empty()
    : this(
        passportNumber: '',
        nationalId: '',
        citizenshipCertificateNumber: '',
        passportPhotoPage: '',
        israelVisaPage: '',
      );

  Map<String, dynamic> toJson() => {
    'passport_number': passportNumber,
    'passport_expiry_date': passportExpiry,
    'citizenship_number': citizenshipCertificateNumber,
    'attachment_visa': israelVisaPage,
    'attachment_photo': passportPhotoPage,
  };
}
