// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appName => 'Diaspora Connect';

  @override
  String greeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get reportIssueTitle => 'समस्या रिपोर्ट गर्नुहोस्';

  @override
  String get reportIssueSubtitle => 'तलब, अनुमतिपत्र, आवास, सुरक्षा र अन्य';

  @override
  String get myIssues => 'मेरा समस्याहरू';

  @override
  String get viewAll => 'सबै हेर्नुहोस्';

  @override
  String dueInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिनमा म्याद सकिन्छ',
      zero: 'आज म्याद सकिन्छ',
    );
    return '$_temp0';
  }

  @override
  String get overdue => 'म्याद नाघेको';

  @override
  String get statusInProgress => 'प्रगतिमा';

  @override
  String get statusEscalated => 'माथि पठाइएको';

  @override
  String get statusNew => 'नयाँ';

  @override
  String get statusResolved => 'समाधान भयो';

  @override
  String get categoryWages => 'तलब';

  @override
  String get categoryPermit => 'अनुमतिपत्र';

  @override
  String get categoryHousing => 'आवास';

  @override
  String get categoryDocuments => 'कागजात';

  @override
  String get issuesTitle => 'समस्याहरू';

  @override
  String get searchIssuesHint => 'टिकट वा विषय खोज्नुहोस्';

  @override
  String filterAll(int count) {
    return 'सबै · $count';
  }

  @override
  String get filterInProgress => 'प्रगतिमा';

  @override
  String get filterAssigned => 'तोकिएको';

  @override
  String get filterResolved => 'समाधान भएका';

  @override
  String get noIssuesFound => 'तपाईंको खोजसँग मिल्ने कुनै समस्या छैन';

  @override
  String get trackIssueTitle => 'समस्या ट्र्याक गर्नुहोस्';

  @override
  String get issueNotFound => 'यो समस्या फेला परेन';

  @override
  String get timelineSubmitted => 'पेश गरियो';

  @override
  String get timelineAssignedToEmployer => 'रोजगारदातालाई तोकियो';

  @override
  String get timelineEscalatedToEmbassy => 'दूतावासको श्रम डेस्कमा पठाइयो';

  @override
  String get timelineResolved => 'समाधान भयो · तपाईंको प्रतिक्रिया बाँकी';

  @override
  String get navHome => 'गृहपृष्ठ';

  @override
  String get navIssues => 'समस्याहरू';

  @override
  String get navActivity => 'गतिविधि';

  @override
  String get navProfile => 'प्रोफाइल';
}
