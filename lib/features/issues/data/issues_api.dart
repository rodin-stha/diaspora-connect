import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api_client.dart';
import '../models/issue.dart';

/// The issue endpoints. Only does HTTP and JSON; state lives in the
/// providers. Tests override [issuesApiProvider] with a fake.
class IssuesApi {
  final Dio _dio;

  const IssuesApi(this._dio);

  /// One page of the user's issues, newest first (15 per page).
  Future<List<Issue>> fetchIssues({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/issues',
      queryParameters: {'page': page},
    );
    final items = response.data!['data'] as List<dynamic>;
    return [
      for (final item in items) Issue.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<IssueCategory>> fetchCategories() async {
    final response = await _dio.get<Map<String, dynamic>>('/issue-categories');
    final items = response.data!['data'] as List<dynamic>;
    return [
      for (final item in items)
        IssueCategory.fromJson(item as Map<String, dynamic>),
    ];
  }
}

final issuesApiProvider = Provider<IssuesApi>(
  (ref) => IssuesApi(ref.watch(apiClientProvider)),
);
