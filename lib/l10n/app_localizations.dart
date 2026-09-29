import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Diaspora Connect'**
  String get appName;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {name}'**
  String greeting(String name);

  /// No description provided for @reportIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportIssueTitle;

  /// No description provided for @reportIssueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wages, permit, housing, safety and more'**
  String get reportIssueSubtitle;

  /// No description provided for @myIssues.
  ///
  /// In en, this message translates to:
  /// **'My issues'**
  String get myIssues;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Due today} =1{Due in 1 day} other{Due in {days} days}}'**
  String dueInDays(int days);

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusEscalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated'**
  String get statusEscalated;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @categoryWages.
  ///
  /// In en, this message translates to:
  /// **'Wages'**
  String get categoryWages;

  /// No description provided for @categoryPermit.
  ///
  /// In en, this message translates to:
  /// **'Permit'**
  String get categoryPermit;

  /// No description provided for @categoryHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get categoryHousing;

  /// No description provided for @categoryDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get categoryDocuments;

  /// No description provided for @issuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get issuesTitle;

  /// No description provided for @searchIssuesHint.
  ///
  /// In en, this message translates to:
  /// **'Search ticket or subject'**
  String get searchIssuesHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All · {count}'**
  String filterAll(int count);

  /// No description provided for @filterInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get filterInProgress;

  /// No description provided for @filterAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get filterAssigned;

  /// No description provided for @filterResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get filterResolved;

  /// No description provided for @noIssuesFound.
  ///
  /// In en, this message translates to:
  /// **'No issues match your search'**
  String get noIssuesFound;

  /// No description provided for @trackIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Track issue'**
  String get trackIssueTitle;

  /// No description provided for @issueNotFound.
  ///
  /// In en, this message translates to:
  /// **'This issue could not be found'**
  String get issueNotFound;

  /// No description provided for @timelineSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get timelineSubmitted;

  /// No description provided for @timelineAssignedToEmployer.
  ///
  /// In en, this message translates to:
  /// **'Assigned to employer'**
  String get timelineAssignedToEmployer;

  /// No description provided for @timelineEscalatedToEmbassy.
  ///
  /// In en, this message translates to:
  /// **'Escalated to Embassy Labour Desk'**
  String get timelineEscalatedToEmbassy;

  /// No description provided for @timelineResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved · pending your feedback'**
  String get timelineResolved;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navIssues.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get navIssues;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navActivity;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
