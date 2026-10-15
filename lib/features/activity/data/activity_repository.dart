import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/dio_provider.dart';
import '../../../app/api/paged.dart';
import '../models/activity.dart';

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(ref.read(dioProvider)),
);

class ActivityRepository {
  final Dio _dio;

  ActivityRepository(this._dio);

  /// One page of the activity log, newest first.
  Future<Paged<Activity>> fetchActivity({
    required int page,
    required int perPage,
  }) async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>(
        '/activity-logs',
        queryParameters: {'page': page, 'per_page': perPage},
      ),
    );

    return Paged.fromJson(res.data!, Activity.fromJson, perPage: perPage);
  }
}
