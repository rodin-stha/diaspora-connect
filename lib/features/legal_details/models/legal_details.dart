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

  /// Photos picked on this device that aren't uploaded yet (local paths).
  /// Sent as files with the next save.
  final String? passportPhotoPageFile;
  final String? israelVisaPageFile;

  const LegalDetails({
    required this.passportNumber,
    this.passportExpiry,
    required this.nationalId,
    required this.citizenshipCertificateNumber,
    this.passportPhotoPage,
    this.israelVisaPage,
    this.passportPhotoPageFile,
    this.israelVisaPageFile,
  });

  const LegalDetails.empty()
    : this(
        passportNumber: '',
        nationalId: '',
        citizenshipCertificateNumber: '',
      );

  /// The text fields of the save request. The photos are added as files
  /// by the repository.
  Map<String, dynamic> toJson() => {
    'passport_number': passportNumber,
    'passport_expiry_date': passportExpiry
        ?.toIso8601String()
        .split('T')
        .first, // yyyy-MM-dd
    'citizenship_number': citizenshipCertificateNumber,
    'national_id_number': nationalId,
  };

  factory LegalDetails.fromJson(Map<String, dynamic> json) => LegalDetails(
    passportNumber: json['passport_number'] as String? ?? '',
    passportExpiry: DateTime.tryParse(
      json['passport_expiry_date'] as String? ?? '',
    ),
    nationalId: json['national_id_number'] as String? ?? '',
    citizenshipCertificateNumber: json['citizenship_number'] as String? ?? '',
  );
}
