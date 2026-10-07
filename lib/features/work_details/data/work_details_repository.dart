import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_response.dart';
import '../../../app/api/dio_provider.dart';
import '../models/employment_type.dart';
import '../models/work_details.dart';

final workDetailsRepositoryProvider = Provider<WorkDetailsRepository>(
  (ref) => WorkDetailsRepository(ref.read(dioProvider)),
);

class WorkDetailsRepository {
  final Dio _dio;

  WorkDetailsRepository(this._dio);

  /// Sent as multipart form data, because JSON can't carry the permit photo.
  Future<void> saveWorkDetails(WorkDetails details) async {
    final permit = details.workPermitFile;
    final form = FormData.fromMap({
      ...details.toJson()..removeWhere((_, value) => value == null),
      if (permit != null) 'work_permit': await MultipartFile.fromFile(permit),
    });

    await apiCall(() => _dio.post<void>('/work-details', data: form));
  }

  Future<List<EmploymentType>> fetchEmploymentTypes() async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>('/employment-types'),
    );

    return ApiResponse.fromJson(
      res.data!,
      (data) => (data as List)
          .map((item) => EmploymentType.fromJson(item as Map<String, dynamic>))
          .toList(),
    ).data;
  }
}
