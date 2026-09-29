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
  String get navHome => 'गृहपृष्ठ';

  @override
  String get navIssues => 'समस्याहरू';

  @override
  String get navActivity => 'गतिविधि';

  @override
  String get navProfile => 'प्रोफाइल';
}
