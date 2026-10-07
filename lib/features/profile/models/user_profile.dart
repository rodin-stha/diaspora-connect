class UserProfile {
  /// Used in greetings ("Namaste, Sita"). The first word of the full name:
  /// Nepali names put the given name first.
  final String givenName;
  final String fullName;

  /// Where the user lives: district • local authority • locality.
  final String location;

  const UserProfile({
    required this.givenName,
    required this.fullName,
    required this.location,
  });
}
