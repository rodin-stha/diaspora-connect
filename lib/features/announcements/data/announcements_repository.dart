import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/dio_provider.dart';
import '../../../app/api/paged.dart';
import '../models/announcement.dart';

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>(
  (ref) => AnnouncementsRepository(ref.read(dioProvider)),
);

class AnnouncementsRepository {
  final Dio _dio;

  AnnouncementsRepository(this._dio);

  /// One page of announcements, newest first (the API's order). [page]
  /// starts at 1.
  Future<Paged<Announcement>> fetchAnnouncementsPage({
    required int page,
    required int perPage,
  }) async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>(
        '/announcements',
        queryParameters: {'page': page, 'per_page': perPage},
      ),
    );

    return Paged.fromJson(res.data!, Announcement.fromJson, perPage: perPage);
  }
}
