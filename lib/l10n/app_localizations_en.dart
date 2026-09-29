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
  String get appLanguage => 'App language';

  @override
  String get profileSectionProfile => 'Profile';

  @override
  String get profileSectionPreferences => 'Preferences';

  @override
  String get personalDetails => 'Personal details';

  @override
  String get legalDetails => 'Legal details · Citizenship / NID';

  @override
  String get workDetails => 'Work details & permit';

  @override
  String get savedDocuments => 'Saved documents';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get logOut => 'Log out';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get dateOfBirthLabel => 'Date of birth · optional';

  @override
  String get dateOfBirthHint => 'DD/MM/YYYY';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get genderOther => 'Other';

  @override
  String get selectHint => 'Select';

  @override
  String get mobileIsraelLabel => 'Mobile number (Israel)';

  @override
  String get mobileIsraelHint => '+972 5X-XXX-XXXX';

  @override
  String get homeInIsraelSection => 'Your home in Israel';

  @override
  String get councilCity => 'City Council';

  @override
  String get councilLocal => 'Local Council';

  @override
  String get councilRegional => 'Regional Council';

  @override
  String get districtLabel => 'District';

  @override
  String get districtJerusalem => 'Jerusalem District';

  @override
  String get districtNorthern => 'Northern District';

  @override
  String get districtHaifa => 'Haifa District';

  @override
  String get districtCentral => 'Central District';

  @override
  String get districtTelAviv => 'Tel Aviv District';

  @override
  String get districtSouthern => 'Southern District';

  @override
  String get localAuthorityLabel => 'Local Authority';

  @override
  String get neighborhoodLabel => 'Neighborhood or Settlement';

  @override
  String get neighborhoodHint => 'e.g. Kibbutz Afikim';

  @override
  String get postalCodeLabel => 'Postal code · 7 digits';

  @override
  String get homeHint =>
      'Sub-district is recorded automatically for official records. If you live on a Kibbutz or Moshav, search for it directly rather than the Regional Council name.';

  @override
  String get nepalContactSection => 'Contact in Nepal · not an address';

  @override
  String get contactNameLabel => 'Contact person\'s name';

  @override
  String get contactNameHint => 'e.g. a parent, spouse or sibling';

  @override
  String get relationshipLabel => 'Relationship';

  @override
  String get relationshipHint => 'e.g. Mother';

  @override
  String get contactPhoneLabel => 'Phone number';

  @override
  String get contactPhoneHint => '+977 98XXXXXXXX';

  @override
  String get emailLabel => 'Email address · optional';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get contactHint =>
      'Used only to reach your family in an emergency, or for official correspondence — this is not treated as your home address.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get detailsSaved => 'Your details have been saved';

  @override
  String get errorFullName => 'Enter your full name';

  @override
  String get errorGender => 'Select your gender';

  @override
  String get errorMobileEmpty => 'Enter your Israeli mobile number';

  @override
  String get errorCouncilType => 'Select the type of council where you live';

  @override
  String get errorDistrict => 'Select the district where you live';

  @override
  String get errorLocalAuthority =>
      'Enter your local authority, e.g. a city or regional council';

  @override
  String get errorNeighborhood => 'Enter your neighborhood, kibbutz or moshav';

  @override
  String get errorPostalCodeEmpty => 'Enter your 7-digit postal code';

  @override
  String get errorContactName =>
      'Enter the name of someone we can contact in Nepal';

  @override
  String get errorRelationship => 'Enter how they\'re related to you';

  @override
  String get errorContactPhoneEmpty => 'Enter their phone number';

  @override
  String get errorIsraeliMobile =>
      'Enter an Israeli mobile number, e.g. +972 52 123 4567';

  @override
  String get errorNepaliMobile => 'Enter a Nepali mobile, e.g. +977 98XXXXXXXX';

  @override
  String get errorPostalCode => 'Postal code must be 7 digits';

  @override
  String get errorEmail => 'Enter a valid email address';

  @override
  String get requiredField => 'required';

  @override
  String get navHome => 'Home';

  @override
  String get navIssues => 'Issues';

  @override
  String get navActivity => 'Activity';

  @override
  String get navProfile => 'Profile';
}
