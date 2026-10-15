/// App-wide settings set by the admins (GET /platform-settings).
class PlatformSettings {
  /// Emergency number for the SOS button; null until the admins set one.
  final String? sosNumber;
  final String? helplineNumber;

  const PlatformSettings({this.sosNumber, this.helplineNumber});

  factory PlatformSettings.fromJson(Map<String, dynamic> json) =>
      PlatformSettings(
        sosNumber: _nonEmpty(json['sos_number'] as String?),
        helplineNumber: _nonEmpty(json['helpline_number'] as String?),
      );

  static String? _nonEmpty(String? text) =>
      (text == null || text.trim().isEmpty) ? null : text.trim();
}
