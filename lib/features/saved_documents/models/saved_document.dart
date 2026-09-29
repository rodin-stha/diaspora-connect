/// Kinds of document the app knows by name (shown translated). Anything
/// else the user uploads is [other], with a name they give it.
enum DocumentType { passportPhotoPage, israelVisaPage, workPermitLetter, other }

class SavedDocument {
  final DocumentType type;
  final String fileName;

  /// The user's own name for an [DocumentType.other] document.
  final String? customName;

  const SavedDocument({
    required this.type,
    required this.fileName,
    this.customName,
  });
}
