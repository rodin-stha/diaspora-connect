import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diaspora_connect/app/locale_provider.dart';
import 'package:diaspora_connect/features/issues/data/issues_api.dart';
import 'package:diaspora_connect/features/issues/models/issue.dart';
import 'package:diaspora_connect/features/personal_details/models/personal_details.dart';
import 'package:diaspora_connect/main.dart';
import 'package:diaspora_connect/theme/sizes.dart';
import 'package:diaspora_connect/widgets/issue_card.dart';
import 'package:diaspora_connect/widgets/labeled_field.dart';
import 'package:diaspora_connect/widgets/selectable_chip.dart';
import 'package:diaspora_connect/widgets/toggle_row.dart';
import 'package:diaspora_connect/widgets/toggle_switch.dart';

/// Stands in for the backend: tests have no network.
class FakeIssuesApi implements IssuesApi {
  final bool fails;

  /// Issues per page; the real API uses 15.
  final int pageSize;

  /// Pages from this one on fail (to test "load more" errors).
  final int? failFromPage;

  /// All issues on the "server"; the sample issues unless given.
  final List<Issue>? issues;

  const FakeIssuesApi({
    this.fails = false,
    this.pageSize = 15,
    this.failFromPage,
    this.issues,
  });

  static const categories = [
    IssueCategory(id: 2, name: 'Financial'),
    IssueCategory(id: 3, name: 'Health'),
    IssueCategory(id: 6, name: 'Housing'),
    IssueCategory(id: 7, name: 'Immigration'),
  ];

  @override
  Future<IssuesPage> fetchIssues({int page = 1}) async {
    if (fails || (failFromPage != null && page >= failFromPage!)) {
      throw Exception('No connection');
    }
    final all = issues ?? _sampleIssues;
    final start = (page - 1) * pageSize;
    return IssuesPage(
      issues: all.skip(start).take(pageSize).toList(),
      page: page,
      lastPage: (all.length / pageSize).ceil(),
      total: all.length,
    );
  }

  @override
  Future<List<IssueCategory>> fetchCategories() async => categories;
}

final _sampleIssues = [
  Issue(
    id: 4512,
    title: 'Wage shortfall, October pay',
    category: FakeIssuesApi.categories[0],
    status: IssueStatus.inProgress,
    createdAt: DateTime(2026, 9, 3, 10, 42),
    dueInDays: 4,
    assignedTo: 'Case worker',
    timeline: [
      IssueEvent(IssueEventType.submitted, DateTime(2026, 9, 3, 10, 42)),
      IssueEvent(IssueEventType.assignedToEmployer, DateTime(2026, 9, 3, 14)),
      const IssueEvent(IssueEventType.resolved),
    ],
  ),
  Issue(
    id: 4498,
    title: 'Permit renewal delayed',
    category: FakeIssuesApi.categories[3],
    status: IssueStatus.escalated,
    createdAt: DateTime(2026, 8, 28),
    dueInDays: -1,
    assignedTo: 'Case worker',
  ),
  Issue(
    id: 4530,
    title: 'Housing dispute, live-in contract',
    category: FakeIssuesApi.categories[2],
    status: IssueStatus.submitted,
    createdAt: DateTime(2026, 9, 6),
  ),
  Issue(
    id: 4533,
    title: 'Passport held by employer',
    category: FakeIssuesApi.categories[3],
    status: IssueStatus.escalated,
    createdAt: DateTime(2026, 9, 4),
    dueInDays: 2,
    assignedTo: 'Case worker',
  ),
];

Future<void> pumpApp(
  WidgetTester tester, {
  IssuesApi issuesApi = const FakeIssuesApi(),
  Map<String, Object> savedPrefs = const {},
  bool signedIn = true,
  // null = never saved (a session from before onboarding existed).
  bool? onboarded = true,
}) async {
  SharedPreferences.setMockInitialValues({
    'signed_in': signedIn,
    'onboarded': ?onboarded,
    ...savedPrefs,
  });
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      // Fail at once in tests; by default Riverpod retries failed providers.
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        issuesApiProvider.overrideWithValue(issuesApi),
      ],
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // Tests have no network access, so don't try to download fonts.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('Login', () {
    testWidgets('signed-out users start on login, 111111 signs in', (
      tester,
    ) async {
      await pumpApp(tester, signedIn: false);

      expect(find.text('Send OTP'), findsOneWidget);
      expect(find.text('Namaste, Sita'), findsNothing);

      // Any number is accepted for now, but not an empty one
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your mobile number'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '52 123 4567');
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      expect(find.text('Verify your number'), findsOneWidget);
      expect(
        find.text('Enter the 6-digit code sent by SMS to +972 52 123 4567'),
        findsOneWidget,
      );
      expect(find.text('Resend in 01:00'), findsOneWidget);

      // Wrong code shows an error and stays here
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();
      expect(
        find.text("That code isn't right. Check the SMS and try again."),
        findsOneWidget,
      );

      // The dev code signs in; the route guard moves us to Home
      await tester.enterText(find.byType(TextField), '111111');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();
      expect(find.text('Namaste, Sita'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('signed_in'), isTrue);
    });

    testWidgets('Log out asks first, then returns to login', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Last row on Profile; scroll to it first
      await tester.ensureVisible(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.text('Log out?'), findsOneWidget);
      expect(
        find.textContaining('Are you sure you want to log out?'),
        findsOneWidget,
      );

      // Cancel keeps you signed in
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Log out?'), findsNothing);
      expect(find.text('PROFILE'), findsOneWidget);

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log out').last); // the dialog's button
      await tester.pumpAndSettle();
      expect(find.text('Send OTP'), findsOneWidget);
    });
  });

  group('Onboarding', () {
    testWidgets('starts only after logging in', (tester) async {
      await pumpApp(tester, signedIn: false, onboarded: null);
      expect(find.text('Send OTP'), findsOneWidget);
      expect(find.text('STEP 1 OF 3'), findsNothing);

      await tester.enterText(find.byType(TextField), '52 123 4567');
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '111111');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      expect(find.text('STEP 1 OF 3'), findsOneWidget);
    });

    testWidgets('an existing session skips it', (tester) async {
      await pumpApp(tester, onboarded: null);

      expect(find.text('Namaste, Sita'), findsOneWidget);
      expect(find.text('STEP 1 OF 3'), findsNothing);
    });

    // Signed in but not onboarded = the app was closed mid-onboarding.
    testWidgets('new users go through 3 steps, then Home', (tester) async {
      await pumpApp(tester, onboarded: false);

      expect(find.text('STEP 1 OF 3'), findsOneWidget);
      expect(find.text('Personal details'), findsOneWidget);
      expect(find.text('Namaste, Sita'), findsNothing);

      /// The text box under a required field's label ("Full name *").
      Finder field(String requiredLabel) => find.descendant(
        of: find.ancestor(
          of: find.text('$requiredLabel *'),
          matching: find.byType(LabeledField),
        ),
        matching: find.byType(TextField),
      );
      Future<void> fill(Finder finder, String value) async {
        await tester.ensureVisible(finder);
        await tester.enterText(finder, value);
      }

      Future<void> choose(String hint, String option) async {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(hint).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(hint).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(option).last);
        await tester.pumpAndSettle();
      }

      Future<void> tapButton(String label) async {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      // Step 1 starts empty (sample data isn't shown to a new user)
      await fill(field('Full name'), 'Gita Shrestha');
      await choose('Select', 'Female');
      await fill(field('Mobile number (Israel)'), '052 123 4567');
      await tester.ensureVisible(find.text('Regional Council'));
      await tester.tap(find.text('Regional Council'));
      await choose('Select', 'Central District');
      await fill(field('Local Authority'), 'Emek HaMaayanot');
      await fill(field('Neighborhood or Settlement'), 'Kibbutz Afikim');
      await fill(field('Postal code · 7 digits'), '1234567');
      await fill(field("Contact person's name"), 'Hari Shrestha');
      await fill(field('Relationship'), 'Father');
      await fill(field('Phone number'), '+977 9812345678');
      await tapButton('Continue');

      // Step 2: upload tiles instead of rows, and consent is required
      expect(find.text('STEP 2 OF 3'), findsOneWidget);
      expect(find.text('Photo page'), findsOneWidget);
      expect(find.text('Replace'), findsNothing);
      await fill(field('Passport number'), '09123456');
      await fill(field('Citizenship certificate no.'), '27-01-73-01234');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.text('DD/MM/YYYY'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tapButton('Verify and continue');
      expect(find.text('Tick the box to continue'), findsOneWidget);
      expect(find.text('STEP 2 OF 3'), findsOneWidget); // still here

      await tester.tap(find.text('I consent to identity verification'));
      await tapButton('Verify and continue');

      // Step 3
      expect(find.text('STEP 3 OF 3'), findsOneWidget);
      expect(find.text('Upload work permit (Rishayon Avoda)'), findsOneWidget);
      await choose('Select', 'Caregiving');
      await choose('Select', 'Live-in');
      await tapButton('Save profile');

      // Done: Home, greeting the name from step 1
      expect(find.text('Namaste, Gita'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarded'), isTrue);
    });
  });

  testWidgets('Home screen shows greeting, report card and issues', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Namaste, Sita'), findsOneWidget);
    expect(find.text('Report an issue'), findsOneWidget);
    expect(find.text('Wage shortfall, October pay'), findsOneWidget);
    expect(find.text('#4512 · Due in 4 days'), findsOneWidget);
    expect(find.text('#4498 · Overdue'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('Escalated'), findsOneWidget);
  });

  testWidgets('View all opens the Issues tab', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();

    expect(find.text('Search ticket or subject'), findsOneWidget);
    expect(find.text('All · 4'), findsOneWidget);
  });

  group('Report an issue', () {
    Future<void> openReportIssue(WidgetTester tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Report an issue'));
      await tester.pumpAndSettle();
    }

    testWidgets('needs a category and subject', (tester) async {
      await openReportIssue(tester);

      // Employer is pre-filled from Work details
      expect(find.text('Levi family, Rishon LeZion'), findsOneWidget);

      final submit = find.text('Submit issue');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.text('Select what the issue is about'), findsOneWidget);
      expect(find.text('Give your issue a short title'), findsOneWidget);
    });

    testWidgets('submitting opens Track issue and adds it everywhere', (
      tester,
    ) async {
      await openReportIssue(tester);

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      // Options come from the categories API
      await tester.tap(find.text('Health').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. Wage shortfall, October pay'),
        'No safety equipment on site',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      final submit = find.text('Submit issue');
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();

      // Track issue for the new one, with the next id
      expect(find.text('Track issue'), findsOneWidget);
      expect(find.text('#4534'), findsOneWidget);
      expect(find.text('No safety equipment on site'), findsOneWidget);
      expect(find.text('New'), findsOneWidget); // status pill

      // Back goes Home (the form was replaced), which now lists it first
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Report an issue'), findsOneWidget);
      expect(find.text('No safety equipment on site'), findsOneWidget);

      // …and the Activity feed recorded it
      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();
      expect(
        find.text('#4534 · No safety equipment on site'),
        findsOneWidget,
      );
    });
  });

  group('Issues screen', () {
    Future<void> openIssuesTab(WidgetTester tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('View all'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows all issues with category in the subtitle', (
      tester,
    ) async {
      await openIssuesTab(tester);

      expect(find.byType(IssueCard), findsNWidgets(4));
      expect(
        find.text('#4512 · Financial · Due in 4 days'),
        findsOneWidget,
      );
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('In progress filter includes escalated issues', (
      tester,
    ) async {
      await openIssuesTab(tester);

      // Tap the chip, not the "In progress" status pill on a card
      await tester.tap(find.widgetWithText(SelectableChip, 'In progress'));
      await tester.pumpAndSettle();

      // 1 in progress + 2 escalated; the "New" one is hidden
      expect(find.byType(IssueCard), findsNWidgets(3));
      expect(find.text('Housing dispute, live-in contract'), findsNothing);
    });

    testWidgets('Assigned filter hides issues without a case worker', (
      tester,
    ) async {
      await openIssuesTab(tester);

      await tester.tap(find.text('Assigned'));
      await tester.pumpAndSettle();

      expect(find.byType(IssueCard), findsNWidgets(3));
      expect(find.text('Housing dispute, live-in contract'), findsNothing);
    });

    testWidgets('Resolved filter shows the empty state', (tester) async {
      await openIssuesTab(tester);

      await tester.tap(find.text('Resolved'));
      await tester.pumpAndSettle();

      expect(find.byType(IssueCard), findsNothing);
      expect(find.text('No issues match your search'), findsOneWidget);
    });

    testWidgets('search matches reference number or title', (tester) async {
      await openIssuesTab(tester);

      await tester.enterText(find.byType(TextField), '4530');
      await tester.pumpAndSettle();
      expect(find.byType(IssueCard), findsOneWidget);
      expect(find.text('Housing dispute, live-in contract'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'PASSPORT');
      await tester.pumpAndSettle();
      expect(find.byType(IssueCard), findsOneWidget);
      expect(find.text('Passport held by employer'), findsOneWidget);
    });

    testWidgets('a failed load shows an error with Try again', (tester) async {
      await pumpApp(tester, issuesApi: const FakeIssuesApi(fails: true));
      await tester.tap(find.text('View all'));
      await tester.pumpAndSettle();

      expect(find.byType(IssueCard), findsNothing);
      expect(
        find.text(
          "Couldn't load your issues. Check your connection and try again.",
        ),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
    });

    group('infinite scroll', () {
      Future<void> openWithPages(
        WidgetTester tester, {
        int? failFromPage,
      }) async {
        await pumpApp(
          tester,
          issuesApi: FakeIssuesApi(pageSize: 2, failFromPage: failFromPage),
        );
        await tester.tap(find.text('View all'));
        await tester.pumpAndSettle();
      }

      testWidgets('loads the next page at the end of the list', (
        tester,
      ) async {
        await openWithPages(tester);

        // Page 2 loads by itself: the 2 cards of page 1 don't fill the
        // screen, so the footer is already in view.
        expect(find.text('Passport held by employer'), findsOneWidget);
        expect(find.byType(IssueCard), findsNWidgets(4));
        // The count is all issues on the server, not just loaded ones
        expect(find.text('All · 4'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('scrolling down loads more pages until the last', (
        tester,
      ) async {
        final manyIssues = [
          for (var id = 30; id >= 1; id--)
            Issue(
              id: id,
              title: 'Issue number $id',
              category: FakeIssuesApi.categories[0],
              status: IssueStatus.submitted,
              createdAt: DateTime(2026, 9, id),
            ),
        ];
        await pumpApp(
          tester,
          issuesApi: FakeIssuesApi(pageSize: 10, issues: manyIssues),
        );
        await tester.tap(find.text('View all'));
        await tester.pumpAndSettle();

        // Only page 1 so far: the list is longer than the screen
        expect(find.text('All · 30'), findsOneWidget);
        expect(find.text('Issue number 11', skipOffstage: false), findsNothing);

        // Scrolling to the end of each page loads the next one
        await tester.scrollUntilVisible(
          find.text('Issue number 1'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Issue number 1'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('a failed page keeps loaded issues and offers Try again', (
        tester,
      ) async {
        await openWithPages(tester, failFromPage: 2);

        expect(find.byType(IssueCard), findsNWidgets(2));
        expect(find.text("Couldn't load more issues."), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
      });
    });

    testWidgets('tapping an issue opens Track issue, back returns', (
      tester,
    ) async {
      await openIssuesTab(tester);

      await tester.tap(find.text('Wage shortfall, October pay'));
      await tester.pumpAndSettle();

      expect(find.text('Track issue'), findsOneWidget);
      expect(find.text('#4512'), findsOneWidget);
      expect(find.text('Submitted'), findsOneWidget);
      expect(find.text('3 Sep, 10:42 AM'), findsOneWidget);
      expect(find.text('Resolved · pending your feedback'), findsOneWidget);
      // Detail page covers the bottom nav
      expect(find.text('Activity'), findsNothing);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Search ticket or subject'), findsOneWidget);
    });
  });

  group('Activity screen', () {
    Future<void> openActivityTab(WidgetTester tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows account activity newest first', (tester) async {
      await openActivityTab(tester);

      expect(find.text('Submitted a new issue'), findsOneWidget);
      expect(find.text('Changed to +972 5X-XXX-XXXX'), findsOneWidget);
      expect(
        find.text('Passport photo page added to Saved documents'),
        findsOneWidget,
      );
      expect(find.text('6 Sep, 6:40 PM'), findsOneWidget);

      final first = tester.getTopLeft(find.text('Submitted a new issue'));
      final last = tester.getTopLeft(find.text('Profile updated'));
      expect(first.dy, lessThan(last.dy));
    });

    testWidgets('Mark all read disables itself once everything is read', (
      tester,
    ) async {
      await openActivityTab(tester);

      TextButton markAllRead() => tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Mark all read'),
      );
      expect(markAllRead().onPressed, isNotNull);

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      expect(markAllRead().onPressed, isNull);
    });
  });

  group('Profile screen', () {
    Future<void> openProfileTab(WidgetTester tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the user and menu sections', (tester) async {
      await openProfileTab(tester);

      expect(find.text('Sita Kumari Shrestha'), findsOneWidget);
      expect(find.text('PROFILE'), findsOneWidget);
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('Personal details'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('Personal details: required fields block saving', (
      tester,
    ) async {
      await openProfileTab(tester);
      await tester.tap(find.text('Personal details'));
      await tester.pumpAndSettle();

      final save = find.text('Save changes');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      // Sample data has no postal code or Nepal contact yet; each error
      // says what to fill in.
      expect(find.text('Enter your 7-digit postal code'), findsOneWidget);
      expect(find.text("Enter how they're related to you"), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget); // still here

      // Error text is indented a little from the field's left edge, not by
      // the full 14px inner padding like Flutter's default.
      final errorLeft = tester
          .getTopLeft(find.text('Enter your 7-digit postal code'))
          .dx;
      expect(errorLeft, TSizes.pagePadding + TSizes.xs);

      // Dropdowns are the same height as text inputs.
      final textBox = tester.getSize(find.byType(TextField).first).height;
      final selectBox = tester
          .getSize(
            find
                .ancestor(
                  of: find.byType(DropdownButton<Gender>),
                  matching: find.byType(InputDecorator),
                )
                .first,
          )
          .height;
      expect(selectBox, closeTo(textBox, 0.5));
    });

    testWidgets('Personal details: saving updates the Profile header', (
      tester,
    ) async {
      await openProfileTab(tester);
      await tester.tap(find.text('Personal details'));
      await tester.pumpAndSettle();

      Future<void> fill(String currentText, String value) async {
        final field = find.widgetWithText(TextField, currentText);
        await tester.ensureVisible(field);
        await tester.enterText(field, value);
      }

      await fill('Sita Kumari Shrestha', 'Gita Shrestha');
      await fill('0000000', '1234567');
      await fill('e.g. a parent, spouse or sibling', 'Hari Shrestha');
      await fill('e.g. Mother', 'Father');
      await fill('+977 98XXXXXXXX', '+977 9812345678');

      // Close the keyboard, otherwise the focused field keeps scrolling
      // itself back into view and the button moves off screen.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      final save = find.text('Save changes');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(find.text('Your details have been saved'), findsOneWidget);
      expect(find.text('Gita Shrestha'), findsOneWidget); // Profile header
      expect(find.text('GS'), findsOneWidget); // avatar initials
    });

    testWidgets('Legal details: validates, then saves', (tester) async {
      await openProfileTab(tester);
      await tester.tap(find.text('Legal details · Citizenship / NID'));
      await tester.pumpAndSettle();

      expect(find.text('Passport · photo page'), findsOneWidget);
      expect(find.text('Replace'), findsNWidgets(2));
      expect(find.text('Upload new document'), findsOneWidget);

      final save = find.text('Save changes');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(find.text('Enter your passport number'), findsOneWidget);
      expect(find.text('Select the expiry date'), findsOneWidget);
      expect(
        find.text('Enter your citizenship certificate number'),
        findsOneWidget,
      );

      // Fill in, including the expiry date through the date picker
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. 09XXXXXX'),
        '09123456',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. 27-01-73-01234'),
        '27-01-73-01234',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.text('DD/MM/YYYY'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(find.text('Your details have been saved'), findsOneWidget);
      expect(find.text('PROFILE'), findsOneWidget); // back on Profile
    });

    testWidgets('Saved documents lists legal scans and other documents', (
      tester,
    ) async {
      await openProfileTab(tester);
      await tester.tap(find.text('Saved documents'));
      await tester.pumpAndSettle();

      // Passport + visa come from Legal details, the letter from its own list
      expect(find.text('Passport · photo page'), findsOneWidget);
      expect(find.text('Israel visa page'), findsOneWidget);
      expect(find.text('Work permit approval letter'), findsOneWidget);
      expect(find.text('View'), findsNWidgets(3));

      await tester.tap(find.text('Upload new document'));
      await tester.pump();
      expect(
        find.text("Uploading documents isn't available yet"),
        findsOneWidget,
      );
    });

    testWidgets('Work details: caregiving section follows business type', (
      tester,
    ) async {
      await openProfileTab(tester);
      await tester.tap(find.text('Work details & permit'));
      await tester.pumpAndSettle();

      expect(find.text('Work permit approval letter'), findsOneWidget);
      expect(find.text('CAREGIVING DETAILS'), findsOneWidget);
      expect(find.text('Live-in'), findsOneWidget);

      // Switch to Agriculture: caregiving questions no longer apply
      await tester.tap(find.text('Caregiving'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agriculture').last);
      await tester.pumpAndSettle();
      expect(find.text('CAREGIVING DETAILS'), findsNothing);

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text('Your details have been saved'), findsOneWidget);
    });

    testWidgets('Notification settings: toggles save on the device', (
      tester,
    ) async {
      await openProfileTab(tester);
      await tester.tap(find.text('Notification settings'));
      await tester.pumpAndSettle();

      bool isOn(String title) => tester
          .widget<ToggleSwitch>(
            find.descendant(
              of: find.widgetWithText(ToggleRow, title),
              matching: find.byType(ToggleSwitch),
            ),
          )
          .value;

      expect(isOn('SMS alerts'), isTrue);
      expect(isOn('Embassy & DoFE announcements'), isFalse);

      // Tapping the row label (not just the switch) flips it
      await tester.tap(find.text('Embassy & DoFE announcements'));
      await tester.pumpAndSettle();
      expect(isOn('Embassy & DoFE announcements'), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notify_embassyAnnouncements'), isTrue);
    });

    testWidgets('language pill switches the app to Nepali', (tester) async {
      await openProfileTab(tester);

      await tester.tap(find.text('नेपाली'));
      await tester.pumpAndSettle();

      expect(find.text('एपको भाषा'), findsOneWidget);
      expect(find.text('लग आउट'), findsOneWidget);
    });
  });

  testWidgets('Language toggle switches to Nepali and saves the choice', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('ने'));
    await tester.pumpAndSettle();

    expect(find.text('नमस्ते, Sita'), findsOneWidget);
    expect(find.text('समस्या रिपोर्ट गर्नुहोस्'), findsOneWidget);
    expect(find.text('गृहपृष्ठ'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), 'ne');

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Namaste, Sita'), findsOneWidget);
  });

  testWidgets('Saved language is used on launch', (tester) async {
    await pumpApp(tester, savedPrefs: {'app_locale': 'ne'});

    expect(find.text('नमस्ते, Sita'), findsOneWidget);
  });
}
