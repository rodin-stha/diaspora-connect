/// What the user fills in on Report an issue, as sent to `POST /issues`.
class NewIssue {
  final int categoryId;
  final String subject;
  final String description;

  /// Employer or embassy the issue is about; may be empty.
  final String employer;

  // Evidence, all optional. Paths are files on this device.
  final String? photoPath;
  final String? recordingPath;
  final double? latitude;
  final double? longitude;

  const NewIssue({
    required this.categoryId,
    required this.subject,
    required this.description,
    required this.employer,
    this.photoPath,
    this.recordingPath,
    this.latitude,
    this.longitude,
  });

  /// The text fields of the request. The files are added by the repository.
  Map<String, dynamic> toJson() => {
    'issue_category_id': categoryId,
    'subject': subject,
    'description': description,
    'employer': employer,
    'latitude': latitude,
    'longitude': longitude,
  };
}
