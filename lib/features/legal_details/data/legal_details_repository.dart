import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_response.dart';
import '../../../app/api/dio_provider.dart';
import '../models/legal_details.dart';

final legalDetailsRepositroy = Provider<LegalDetailsRepositroy>(
  (ref) => LegalDetailsRepositroy(ref.read(dioProvider)),
);

class LegalDetailsRepositroy {
  final Dio _dio;

  LegalDetailsRepositroy(this._dio);

  /// Sent as multipart form data (like a browser form with file inputs),
  /// because JSON can't carry the photos.
  Future<void> saveLegalDetails(LegalDetails details) async {
    final photo = details.passportPhotoPageFile;
    final visa = details.israelVisaPageFile;
    final form = FormData.fromMap({
      ...details.toJson()..removeWhere((_, value) => value == null),
      if (photo != null)
        'attachment_photo': await MultipartFile.fromFile(photo),
      if (visa != null) 'attachment_visa': await MultipartFile.fromFile(visa),
    });

    await apiCall(() => _dio.post<void>('/legal-details', data: form));
  }

  Future<LegalDetails> fetchlegalDetails() async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>('/legal-details'),
    );

    return ApiResponse.fromJson(
      res.data!,
      (data) => LegalDetails.fromJson(data as Map<String, dynamic>),
    ).data;
  }
}
