import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_response.dart';
import '../../../app/api/dio_provider.dart';
import '../models/announcement.dart';

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>(
  (ref) => AnnouncementsRepository(ref.read(dioProvider)),
);

/// Home shows only the latest few.
const _limit = 5;

class AnnouncementsRepository {
  final Dio _dio;

  AnnouncementsRepository(this._dio);

  /// The latest [_limit] announcements, newest first (the API's order).
  Future<List<Announcement>> fetchAnnouncements() async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>(
        '/announcements',
        // Asks the server for just these, so it doesn't send the default
        // 20 to throw away.
        queryParameters: {'per_page': _limit},
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
    return announcements.take(_limit).toList();
  }
}
