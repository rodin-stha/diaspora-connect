// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Diaspora Connect';

  @override
  String greeting(String name) {
    return 'Namaste, $name';
  }

  @override
  String get reportIssueTitle => 'Report an issue';

  @override
  String get reportIssueSubtitle => 'Wages, permit, housing, safety and more';

  @override
  String get myIssues => 'My issues';

  @override
  String get viewAll => 'View all';

  @override
  String dueInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Due in $days days',
      one: 'Due in 1 day',
      zero: 'Due today',
    );
    return '$_temp0';
  }

  @override
  String get overdue => 'Overdue';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusEscalated => 'Escalated';

  @override
  String get statusNew => 'New';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get categoryWages => 'Wages';

  @override
  String get categoryPermit => 'Permit';

  @override
  String get categoryHousing => 'Housing';

  @override
  String get categoryDocuments => 'Documents';

  @override
  String get issuesTitle => 'Issues';

  @override
  String get searchIssuesHint => 'Search ticket or subject';

  @override
  String filterAll(int count) {
    return 'All · $count';
  }

  @override
  String get filterInProgress => 'In progress';

  @override
  String get filterAssigned => 'Assigned';

  @override
  String get filterResolved => 'Resolved';

  @override
  String get noIssuesFound => 'No issues match your search';

  @override
  String get trackIssueTitle => 'Track issue';

  @override
  String get issueNotFound => 'This issue could not be found';

  @override
  String get timelineSubmitted => 'Submitted';

  @override
  String get timelineAssignedToEmployer => 'Assigned to employer';

  @override
  String get timelineEscalatedToEmbassy => 'Escalated to Embassy Labour Desk';

  @override
  String get timelineResolved => 'Resolved · pending your feedback';

  @override
  String get activityTitle => 'Activity';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get activityDescription =>
      'Account activity — signing in, updating your number, submitting an issue. Issue status updates live in Issues.';

  @override
  String get noActivity => 'No activity yet';

  @override
  String get activityIssueSubmitted => 'Submitted a new issue';

  @override
  String get activityMobileUpdated => 'Mobile number updated';

  @override
  String activityMobileUpdatedDetail(String number) {
    return 'Changed to $number';
  }

  @override
  String get activitySignedIn => 'Signed in';

  @override
  String get activitySignedInDetail => 'New sign-in verified by OTP';

  @override
  String get activityDocumentUploaded => 'Document uploaded';

  @override
  String activityDocumentUploadedDetail(String document) {
    return '$document added to Saved documents';
  }

  @override
  String get activityProfileUpdated => 'Profile updated';

  @override
  String get activityProfileUpdatedDetail => 'Work details & permit saved';

  @override
  String get navHome => 'Home';

  @override
  String get navIssues => 'Issues';

  @override
  String get navActivity => 'Activity';

  @override
  String get navProfile => 'Profile';
}
