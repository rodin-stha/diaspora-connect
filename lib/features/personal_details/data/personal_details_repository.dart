import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_response.dart';
import '../../../app/api/dio_provider.dart';
import '../models/authority.dart';
import '../models/district.dart';
import '../models/locality.dart';
import '../models/personal_details.dart';

final personalDetailsRepository = Provider<PersonalDetailsRepository>(
  (ref) => PersonalDetailsRepository(ref.read(dioProvider)),
);

class PersonalDetailsRepository {
  final Dio _dio;

  PersonalDetailsRepository(this._dio);

  Future<void> savePersonalDetails(PersonalDetails details) async {
    await apiCall(
      () => _dio.post<void>('/personal-details', data: details.toJson()),
    );
  }

  Future<List<District>> fetchDistricts() async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>('/il/districts'),
    );

    return ApiResponse.fromJson(
      res.data!,
      (data) => (data as List)
          .map((item) => District.fromJson(item as Map<String, dynamic>))
          .toList(),
    ).data;
  }

  /// The local authorities of one [type] in a district.
  Future<List<Authority>> fetchAuthoritiesList(
    int districtId,
    AuthorityType type,
  ) async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>(
        '/il/districts/$districtId/authorities',
        // Dio builds and encodes the query string.
        queryParameters: {'authority_type': type.apiValue},
      ),
    );

    return ApiResponse.fromJson(
      res.data!,
      (data) => (data as List)
          .map((item) => Authority.fromJson(item as Map<String, dynamic>))
          .toList(),
    ).data;
  }

  // Locality list
  Future<List<Locality>> fetchLocality(int localAuthorityId) async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>(
        '/il/authorities/$localAuthorityId/localities',
      ),
    );

    return ApiResponse.fromJson(
      res.data!,
      (data) => (data as List)
          .map((item) => Locality.fromJson(item as Map<String, dynamic>))
          .toList(),
    ).data;
  }
}
