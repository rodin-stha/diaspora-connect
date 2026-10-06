/// A place the user pinned on the map. Our own type, not the map SDK's
/// `LatLng`, so the rest of the app doesn't depend on Google Maps.
class PinnedLocation {
  final double latitude;
  final double longitude;

  const PinnedLocation({required this.latitude, required this.longitude});

  /// "32.79412, 34.98962": 5 decimals is about 1 m, plenty for a pin.
  String get display =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

/// A recorded voice note: the audio file on this device and its length.
class VoiceNote {
  final String path;
  final Duration duration;

  const VoiceNote({required this.path, required this.duration});
}
