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

  /// Uploads a document the user named themselves (salary slip, contract…).
  /// Multipart form data, because JSON can't carry the file.
  Future<void> uploadDocument({
    required String filePath,
    required String name,
  }) async {
    final form = FormData.fromMap({
      'name': name,
      'file': await MultipartFile.fromFile(filePath),
    });

    await apiCall(() => _dio.post<void>('/attachments', data: form));
  }

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
