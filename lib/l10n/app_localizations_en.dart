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
  String get navHome => 'Home';

  @override
  String get navIssues => 'Issues';

  @override
  String get navActivity => 'Activity';

  @override
  String get navProfile => 'Profile';
}
