import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_response.dart';
import '../../../app/api/dio_provider.dart';
import '../models/activity.dart';

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(ref.read(dioProvider)),
);

class ActivityRepository {
  final Dio _dio;

  ActivityRepository(this._dio);

  Future<List<Activity>> fetchActivity() async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>('/activity-logs'),
    );

    return ApiResponse.fromJson(
      res.data!,
      (data) => (data as List)
          .map((item) => Activity.fromJson(item as Map<String, dynamic>))
          .toList(),
    ).data;
  }
}
