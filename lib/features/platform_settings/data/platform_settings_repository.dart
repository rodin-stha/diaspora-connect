import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_response.dart';
import '../../../app/api/dio_provider.dart';
import '../models/platform_settings.dart';

final platformSettingsRepositoryProvider = Provider<PlatformSettingsRepository>(
  (ref) => PlatformSettingsRepository(ref.read(dioProvider)),
);

class PlatformSettingsRepository {
  final Dio _dio;

  PlatformSettingsRepository(this._dio);

  Future<PlatformSettings> fetchPlatformSettings() async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>('/platform-settings'),
    );

    return ApiResponse.fromJson(
      res.data!,
      (data) => PlatformSettings.fromJson(data as Map<String, dynamic>),
    ).data;
  }
}
