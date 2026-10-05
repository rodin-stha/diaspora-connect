import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api_client.dart';
import '../models/issue.dart';

/// One page of `GET /issues`, plus where it sits in the whole list (from
/// the response's `meta`).
class IssuesPage {
  final List<Issue> issues;
  final int page;
  final int lastPage;

  /// Issues across all pages.
  final int total;

  const IssuesPage({
    required this.issues,
    required this.page,
    required this.lastPage,
    required this.total,
  });
}

/// The issue endpoints. Only does HTTP and JSON; state lives in the
/// providers. Tests override [issuesApiProvider] with a fake.
class IssuesApi {
  final Dio _dio;

  const IssuesApi(this._dio);

  /// One page of the user's issues, newest first (15 per page).
  Future<IssuesPage> fetchIssues({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/issues',
      queryParameters: {'page': page},
    );
    final body = response.data!;
    final meta = body['meta'] as Map<String, dynamic>;
    return IssuesPage(
      issues: [
        for (final item in body['data'] as List<dynamic>)
          Issue.fromJson(item as Map<String, dynamic>),
      ],
      page: meta['current_page'] as int,
      lastPage: meta['last_page'] as int,
      total: meta['total'] as int,
    );
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
