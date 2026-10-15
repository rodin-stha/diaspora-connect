import 'package:diaspora_connect/app/api/paged.dart';
import 'package:diaspora_connect/features/issues/data/issues_repository.dart';
import 'package:diaspora_connect/features/issues/models/issue.dart';
import 'package:diaspora_connect/features/issues/widgets/info_reply_form.dart';
import 'package:diaspora_connect/l10n/app_localizations.dart';
import 'package:diaspora_connect/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records replies instead of calling the API.
class _FakeIssuesRepository extends IssuesRepository {
  _FakeIssuesRepository() : super(Dio());

  final replies = <({String message, String? photoPath})>[];

  // The notifier fetches the list when it's first used.
  @override
  Future<Paged<Issue>> fetchIssues({
    required int page,
    required int perPage,
    String? search,
    String? type,
  }) async => const Paged(items: [], hasMore: false);

  @override
  Future<void> replyToIssue(
    String reference, {
    required String message,
    String? photoPath,
  }) async => replies.add((message: message, photoPath: photoPath));
}

void main() {
  Future<_FakeIssuesRepository> pumpForm(WidgetTester tester) async {
    final repository = _FakeIssuesRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [issuesRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: TAppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: InfoReplyForm(reference: '52')),
        ),
      ),
    );
    return repository;
  }

  testWidgets('sending with no text and no photo shows an error', (
    tester,
  ) async {
    final repository = await pumpForm(tester);

    await tester.tap(find.text('Send reply'));
    await tester.pump();

    expect(find.text('Write a reply or add a photo'), findsOneWidget);
    expect(repository.replies, isEmpty);
  });

  testWidgets('sending with text needs no photo', (tester) async {
    final repository = await pumpForm(tester);

    await tester.enterText(find.byType(TextField), 'Here it is');
    await tester.tap(find.text('Send reply'));
    await tester.pump();

    expect(find.text('Write a reply or add a photo'), findsNothing);
    expect(repository.replies.single.message, 'Here it is');
  });
}
