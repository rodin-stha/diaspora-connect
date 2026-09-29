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

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @activityDescription.
  ///
  /// In en, this message translates to:
  /// **'Account activity — signing in, updating your number, submitting an issue. Issue status updates live in Issues.'**
  String get activityDescription;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivity;

  /// No description provided for @activityIssueSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted a new issue'**
  String get activityIssueSubmitted;

  /// No description provided for @activityMobileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Mobile number updated'**
  String get activityMobileUpdated;

  /// No description provided for @activityMobileUpdatedDetail.
  ///
  /// In en, this message translates to:
  /// **'Changed to {number}'**
  String activityMobileUpdatedDetail(String number);

  /// No description provided for @activitySignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get activitySignedIn;

  /// No description provided for @activitySignedInDetail.
  ///
  /// In en, this message translates to:
  /// **'New sign-in verified by OTP'**
  String get activitySignedInDetail;

  /// No description provided for @activityDocumentUploaded.
  ///
  /// In en, this message translates to:
  /// **'Document uploaded'**
  String get activityDocumentUploaded;

  /// No description provided for @activityDocumentUploadedDetail.
  ///
  /// In en, this message translates to:
  /// **'{document} added to Saved documents'**
  String activityDocumentUploadedDetail(String document);

  /// No description provided for @activityProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get activityProfileUpdated;

  /// No description provided for @activityProfileUpdatedDetail.
  ///
  /// In en, this message translates to:
  /// **'Work details & permit saved'**
  String get activityProfileUpdatedDetail;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @profileSectionProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSectionProfile;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get personalDetails;

  /// No description provided for @legalDetails.
  ///
  /// In en, this message translates to:
  /// **'Legal details · Citizenship / NID'**
  String get legalDetails;

  /// No description provided for @workDetails.
  ///
  /// In en, this message translates to:
  /// **'Work details & permit'**
  String get workDetails;

  /// No description provided for @savedDocuments.
  ///
  /// In en, this message translates to:
  /// **'Saved documents'**
  String get savedDocuments;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth · optional'**
  String get dateOfBirthLabel;

  /// No description provided for @dateOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get dateOfBirthHint;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @selectHint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectHint;

  /// No description provided for @mobileIsraelLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number (Israel)'**
  String get mobileIsraelLabel;

  /// No description provided for @mobileIsraelHint.
  ///
  /// In en, this message translates to:
  /// **'+972 5X-XXX-XXXX'**
  String get mobileIsraelHint;

  /// No description provided for @homeInIsraelSection.
  ///
  /// In en, this message translates to:
  /// **'Your home in Israel'**
  String get homeInIsraelSection;

  /// No description provided for @councilCity.
  ///
  /// In en, this message translates to:
  /// **'City Council'**
  String get councilCity;

  /// No description provided for @councilLocal.
  ///
  /// In en, this message translates to:
  /// **'Local Council'**
  String get councilLocal;

  /// No description provided for @councilRegional.
  ///
  /// In en, this message translates to:
  /// **'Regional Council'**
  String get councilRegional;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get districtLabel;

  /// No description provided for @districtJerusalem.
  ///
  /// In en, this message translates to:
  /// **'Jerusalem District'**
  String get districtJerusalem;

  /// No description provided for @districtNorthern.
  ///
  /// In en, this message translates to:
  /// **'Northern District'**
  String get districtNorthern;

  /// No description provided for @districtHaifa.
  ///
  /// In en, this message translates to:
  /// **'Haifa District'**
  String get districtHaifa;

  /// No description provided for @districtCentral.
  ///
  /// In en, this message translates to:
  /// **'Central District'**
  String get districtCentral;

  /// No description provided for @districtTelAviv.
  ///
  /// In en, this message translates to:
  /// **'Tel Aviv District'**
  String get districtTelAviv;

  /// No description provided for @districtSouthern.
  ///
  /// In en, this message translates to:
  /// **'Southern District'**
  String get districtSouthern;

  /// No description provided for @localAuthorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Local Authority'**
  String get localAuthorityLabel;

  /// No description provided for @neighborhoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood or Settlement'**
  String get neighborhoodLabel;

  /// No description provided for @neighborhoodHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kibbutz Afikim'**
  String get neighborhoodHint;

  /// No description provided for @postalCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Postal code · 7 digits'**
  String get postalCodeLabel;

  /// No description provided for @homeHint.
  ///
  /// In en, this message translates to:
  /// **'Sub-district is recorded automatically for official records. If you live on a Kibbutz or Moshav, search for it directly rather than the Regional Council name.'**
  String get homeHint;

  /// No description provided for @nepalContactSection.
  ///
  /// In en, this message translates to:
  /// **'Contact in Nepal · not an address'**
  String get nepalContactSection;

  /// No description provided for @contactNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact person\'s name'**
  String get contactNameLabel;

  /// No description provided for @contactNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. a parent, spouse or sibling'**
  String get contactNameHint;

  /// No description provided for @relationshipLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationshipLabel;

  /// No description provided for @relationshipHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mother'**
  String get relationshipHint;

  /// No description provided for @contactPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get contactPhoneLabel;

  /// No description provided for @contactPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+977 98XXXXXXXX'**
  String get contactPhoneHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address · optional'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @contactHint.
  ///
  /// In en, this message translates to:
  /// **'Used only to reach your family in an emergency, or for official correspondence — this is not treated as your home address.'**
  String get contactHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @detailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Your details have been saved'**
  String get detailsSaved;

  /// No description provided for @errorFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get errorFullName;

  /// No description provided for @errorGender.
  ///
  /// In en, this message translates to:
  /// **'Select your gender'**
  String get errorGender;

  /// No description provided for @errorMobileEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your Israeli mobile number'**
  String get errorMobileEmpty;

  /// No description provided for @errorCouncilType.
  ///
  /// In en, this message translates to:
  /// **'Select the type of council where you live'**
  String get errorCouncilType;

  /// No description provided for @errorDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select the district where you live'**
  String get errorDistrict;

  /// No description provided for @errorLocalAuthority.
  ///
  /// In en, this message translates to:
  /// **'Enter your local authority, e.g. a city or regional council'**
  String get errorLocalAuthority;

  /// No description provided for @errorNeighborhood.
  ///
  /// In en, this message translates to:
  /// **'Enter your neighborhood, kibbutz or moshav'**
  String get errorNeighborhood;

  /// No description provided for @errorPostalCodeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your 7-digit postal code'**
  String get errorPostalCodeEmpty;

  /// No description provided for @errorContactName.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of someone we can contact in Nepal'**
  String get errorContactName;

  /// No description provided for @errorRelationship.
  ///
  /// In en, this message translates to:
  /// **'Enter how they\'re related to you'**
  String get errorRelationship;

  /// No description provided for @errorContactPhoneEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter their phone number'**
  String get errorContactPhoneEmpty;

  /// No description provided for @errorIsraeliMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter an Israeli mobile number, e.g. +972 52 123 4567'**
  String get errorIsraeliMobile;

  /// No description provided for @errorNepaliMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a Nepali mobile, e.g. +977 98XXXXXXXX'**
  String get errorNepaliMobile;

  /// No description provided for @errorPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code must be 7 digits'**
  String get errorPostalCode;

  /// No description provided for @errorEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get errorEmail;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'required'**
  String get requiredField;

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
