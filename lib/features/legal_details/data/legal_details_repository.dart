import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/dio_provider.dart';
import '../models/legal_details.dart';

final legalDetailsRepositroy = Provider<LegalDetailsRepositroy>(
  (ref) => LegalDetailsRepositroy(ref.read(dioProvider)),
);

class LegalDetailsRepositroy {
  final Dio _dio;

  LegalDetailsRepositroy(this._dio);

  Future<void> saveLegalDetails(LegalDetails details) async {
    await apiCall(
      () => _dio.post('/legal-details', data: details.toJson()),
    );
  }
}
