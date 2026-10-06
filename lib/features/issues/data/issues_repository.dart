import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_response.dart';
import '../../../app/api/dio_provider.dart';
import '../models/issue.dart';
import '../models/new_issue.dart';

final issuesRepositoryProvider = Provider<IssuesRepository>(
  (ref) => IssuesRepository(ref.read(dioProvider)),
);

class IssuesRepository {
  final Dio _dio;

  IssuesRepository(this._dio);

  /// Sent as multipart form data because of the photo and recording.
  Future<void> createIssue(NewIssue issue) async {
    final photo = issue.photoPath;
    final recording = issue.recordingPath;
    final form = FormData.fromMap({
      ...issue.toJson()..removeWhere((_, value) => value == null),
      if (photo != null) 'evidence_photo': await MultipartFile.fromFile(photo),
      if (recording != null)
        'recording': await MultipartFile.fromFile(recording),
    });

    await apiCall(() => _dio.post<void>('/issues', data: form));
  }

  /// The user's issues, newest first.
  ///
  /// Only the first page (15 issues) for now. TODO: load more on scroll
  /// using `meta.last_page`.
  Future<List<Issue>> fetchIssues() async {
    final res = await apiCall(() => _dio.get<Map<String, dynamic>>('/issues'));

    return ApiResponse.fromJson(
      res.data!,
      (data) => (data as List)
          .map((item) => Issue.fromJson(item as Map<String, dynamic>))
          .toList(),
    ).data;
  }

  Future<List<IssueCategory>> fetchCategories() async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>('/issue-categories'),
    );

    return ApiResponse.fromJson(
      res.data!,
      (data) => (data as List)
          .map((item) => IssueCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
    ).data;
  }
}
