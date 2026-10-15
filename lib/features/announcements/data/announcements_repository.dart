import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_response.dart';
import '../../../app/api/dio_provider.dart';
import '../models/announcement.dart';

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>(
  (ref) => AnnouncementsRepository(ref.read(dioProvider)),
);

class AnnouncementsRepository {
  final Dio _dio;

  AnnouncementsRepository(this._dio);

  /// The latest announcements, newest first (the API's order): [limit] of
  /// them, or the server's first page if null.
  ///
  /// TODO: load more on scroll (Notice tab) using `meta.last_page`.
  Future<List<Announcement>> fetchAnnouncements({int? limit}) async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>(
        '/announcements',
        // Asks the server for just these, so it doesn't send a full page
        // to throw away.
        queryParameters: {'per_page': ?limit},
      ),
    );

    final announcements = ApiResponse.fromJson(
      res.data!,
      (data) => [
        for (final item in (data as List).cast<Map<String, dynamic>>())
          // The carousel shows images; one without has nothing to show.
          if (item['image'] != null) Announcement.fromJson(item),
      ],
    ).data;

    // In case the server ignores `per_page`.
    return limit == null ? announcements : announcements.take(limit).toList();
  }
}
