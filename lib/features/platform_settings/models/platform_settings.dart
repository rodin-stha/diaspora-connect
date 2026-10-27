/// App-wide settings set by the admins (GET /platform-settings).
class PlatformSettings {
  /// Emergency number for the SOS button; null until the admins set one.
  final String? sosNumber;
  final String? helplineNumber;

  /// Shown in place of an announcement's image when it has none or it
  /// can't load. Null until the admins set one.
  final FallbackImage? fallbackImage;

  /// The oldest app version still allowed; older ones must update first.
  final MinVersion minVersion;

  const PlatformSettings({
    this.sosNumber,
    this.helplineNumber,
    this.fallbackImage,
    this.minVersion = const MinVersion(),
  });

  factory PlatformSettings.fromJson(Map<String, dynamic> json) {
    final fallbackImage = json['fallback_image'] as Map<String, dynamic>?;
    final minVersion = json['min_version'] as Map<String, dynamic>?;
    return PlatformSettings(
      sosNumber: _nonEmpty(json['sos_number'] as String?),
      helplineNumber: _nonEmpty(json['helpline_number'] as String?),
      fallbackImage: fallbackImage == null
          ? null
          : FallbackImage.fromJson(fallbackImage),
      minVersion: minVersion == null
          ? const MinVersion()
          : MinVersion.fromJson(minVersion),
    );
  }

  static String? _nonEmpty(String? text) =>
      (text == null || text.trim().isEmpty) ? null : text.trim();
}

class FallbackImage {
  /// Changes when the admins upload a new image: the cue to download again.
  final int id;
  final String fileName;

  /// Signed link; stops working after about an hour, so the image is saved
  /// on the device rather than loaded from here each time.
  final String url;

  const FallbackImage({
    required this.id,
    required this.fileName,
    required this.url,
  });

  factory FallbackImage.fromJson(Map<String, dynamic> json) => FallbackImage(
    id: json['id'] as int,
    fileName: json['file_name'] as String,
    url: json['url'] as String,
  );
}

/// The oldest allowed version per platform, e.g. "1.2.0". One per store,
/// since Apple's review can take days longer than Google's: Android can be
/// made to update while the iOS version is still waiting for approval.
///
/// Null (or missing from the API) means any version is fine.
class MinVersion {
  final String? android;
  final String? ios;

  const MinVersion({this.android, this.ios});

  factory MinVersion.fromJson(Map<String, dynamic> json) => MinVersion(
    android: PlatformSettings._nonEmpty(json['android'] as String?),
    ios: PlatformSettings._nonEmpty(json['ios'] as String?),
  );
}
