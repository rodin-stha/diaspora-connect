/// Kinds of document the app knows by name (shown translated). Anything
/// else is [other] and shows the name the server sends.
enum DocumentType {
  passportPhotoPage,
  israelVisaPage,
  workPermitLetter,
  other;

  /// Maps the API's `type.value`. Unknown values become [other], so a new
  /// type on the server shows its name instead of crashing the list.
  factory DocumentType.fromJson(String? value) => switch (value) {
    'passport' => passportPhotoPage,
    'visa' => israelVisaPage,
    'work_permit' => workPermitLetter,
    _ => other,
  };
}

/// A file the user has uploaded (GET /attachments), from any form: Legal
/// details, Work details, or Saved documents itself.
class SavedDocument {
  final int id;
  final DocumentType type;

  /// The server's name for it: the type's label, or what the user called it.
  final String name;
  final String mimeType;

  /// Signed link to the file. It expires (about 30 minutes), so fetch the
  /// list again rather than keeping it around.
  final String url;

  const SavedDocument({
    required this.id,
    required this.type,
    required this.name,
    required this.mimeType,
    required this.url,
  });

  factory SavedDocument.fromJson(Map<String, dynamic> json) => SavedDocument(
    id: json['id'] as int,
    type: DocumentType.fromJson(
      (json['type'] as Map<String, dynamic>?)?['value'] as String?,
    ),
    name: json['name'] as String? ?? json['file_name'] as String? ?? '',
    mimeType: json['mime_type'] as String? ?? '',
    url: json['url'] as String,
  );
}
