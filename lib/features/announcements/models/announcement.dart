/// An Embassy or DoFE announcement (GET /announcements): a text notice, a
/// poster image, or both.
class Announcement {
  final int id;
  final String? title;
  final String? description;

  /// Null for a text-only announcement.
  final AnnouncementImage? image;

  /// When it was posted, in the phone's time zone.
  final DateTime? createdAt;

  const Announcement({
    required this.id,
    this.title,
    this.description,
    this.image,
    this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    return Announcement(
      id: json['id'] as int,
      title: _nonEmpty(json['title'] as String?),
      description: _nonEmpty(json['description'] as String?),
      image: image == null ? null : AnnouncementImage.fromJson(image),
      // The API sends UTC; toLocal() shows the day it is for the user.
      createdAt: DateTime.tryParse(
        json['created_at'] as String? ?? '',
      )?.toLocal(),
    );
  }

  static String? _nonEmpty(String? text) =>
      (text == null || text.trim().isEmpty) ? null : text.trim();
}

class AnnouncementImage {
  /// Signed link to the image. It stops working at [expiresAt] (about an
  /// hour), so lists are fetched again before then.
  final String url;
  final DateTime expiresAt;

  const AnnouncementImage({required this.url, required this.expiresAt});

  factory AnnouncementImage.fromJson(Map<String, dynamic> json) =>
      AnnouncementImage(
        url: json['url'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );
}
