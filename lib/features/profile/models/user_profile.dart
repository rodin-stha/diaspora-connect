class UserProfile {
  /// Used in greetings ("Namaste, Sita"). The first word of the full name:
  /// Nepali names put the given name first.
  final String givenName;
  final String fullName;

  /// Workplace and region, e.g. "Kibbutz Afikim · Emek HaMa'ayanot…".
  final String location;

  const UserProfile({
    required this.givenName,
    required this.fullName,
    required this.location,
  });
}
