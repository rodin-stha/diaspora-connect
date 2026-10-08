/// An Embassy or DoFE announcement (GET /announcements). For now each one
/// is an image (a poster); title and description are optional.
class Announcement {
  final int id;
  final String? title;
  final String? description;

  /// Signed link to the image. It stops working at [imageExpiresAt] (about
  /// an hour), so the list is fetched again before then.
  final String imageUrl;
  final DateTime imageExpiresAt;

  const Announcement({
    required this.id,
    this.title,
    this.description,
    required this.imageUrl,
    required this.imageExpiresAt,
  });

  /// Expects an `image`: the repository skips announcements without one.
  factory Announcement.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>;
    return Announcement(
      id: json['id'] as int,
      title: _nonEmpty(json['title'] as String?),
      description: _nonEmpty(json['description'] as String?),
      imageUrl: image['url'] as String,
      imageExpiresAt: DateTime.parse(image['expires_at'] as String),
    );
  }

  static String? _nonEmpty(String? text) =>
      (text == null || text.trim().isEmpty) ? null : text.trim();
}
