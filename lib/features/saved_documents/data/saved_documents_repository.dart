import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_response.dart';
import '../../../app/api/dio_provider.dart';
import '../models/saved_document.dart';

final savedDocumentsRepositoryProvider = Provider<SavedDocumentsRepository>(
  (ref) => SavedDocumentsRepository(ref.read(dioProvider)),
);

class SavedDocumentsRepository {
  final Dio _dio;

  SavedDocumentsRepository(this._dio);

  /// The first page only (20 per page): enough for the handful of documents
  /// a user has. Follow `links.next` if that stops being true.
  Future<List<SavedDocument>> fetchDocuments() async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>('/attachments'),
    );

    return ApiResponse.fromJson(
      res.data!,
      (data) => (data as List)
          .map((item) => SavedDocument.fromJson(item as Map<String, dynamic>))
          .toList(),
    ).data;
  }
}
