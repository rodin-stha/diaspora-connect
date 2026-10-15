import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_response.dart';
import '../../../app/api/dio_provider.dart';
import '../../../app/api/paged.dart';
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

  /// Adds the user's answer to an issue, e.g. when a case worker asked for
  /// more details: a [message], a photo, or both. Multipart because of the
  /// photo.
  Future<void> replyToIssue(
    String reference, {
    required String message,
    String? photoPath,
  }) async {
    final form = FormData.fromMap({
      if (message.isNotEmpty) 'body': message,
      if (photoPath != null)
        'attachment': await MultipartFile.fromFile(photoPath),
    });

    await apiCall(
      () => _dio.post<void>('/issues/$reference/updates', data: form),
    );
  }

  /// One page of the user's issues, newest first. [search] and [type]
  /// narrow the list on the server; leave them null for all issues.
  Future<Paged<Issue>> fetchIssues({
    required int page,
    required int perPage,
    String? search,
    String? type,
  }) async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>(
        '/issues',
        // Dio builds and URL-encodes the query string: ?search=…&type=…
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'search': ?search,
          'type': ?type,
        },
      ),
    );

    return Paged.fromJson(res.data!, Issue.fromJson, perPage: perPage);
  }

  /// One issue with its full status history.
  Future<Issue> fetchIssue(String reference) async {
    final res = await apiCall(
      () => _dio.get<Map<String, dynamic>>('/issues/$reference'),
    );

    return ApiResponse.fromJson(
      res.data!,
      (data) => Issue.fromJson(data as Map<String, dynamic>),
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
