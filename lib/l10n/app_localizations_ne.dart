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
  String get activityTitle => 'गतिविधि';

  @override
  String get markAllRead => 'सबै पढिएको बनाउनुहोस्';

  @override
  String get activityDescription =>
      'खाता गतिविधि — साइन इन, नम्बर परिवर्तन, समस्या पेश। समस्याको स्थितिका अपडेटहरू समस्याहरूमा हेर्नुहोस्।';

  @override
  String get noActivity => 'अहिलेसम्म कुनै गतिविधि छैन';

  @override
  String get activityIssueSubmitted => 'नयाँ समस्या पेश गरियो';

  @override
  String get activityMobileUpdated => 'मोबाइल नम्बर परिवर्तन गरियो';

  @override
  String activityMobileUpdatedDetail(String number) {
    return '$number मा परिवर्तन गरियो';
  }

  @override
  String get activitySignedIn => 'साइन इन गरियो';

  @override
  String get activitySignedInDetail => 'नयाँ साइन इन OTP द्वारा प्रमाणित';

  @override
  String get activityDocumentUploaded => 'कागजात अपलोड गरियो';

  @override
  String activityDocumentUploadedDetail(String document) {
    return '$document सुरक्षित कागजातहरूमा थपियो';
  }

  @override
  String get activityProfileUpdated => 'प्रोफाइल अपडेट गरियो';

  @override
  String get activityProfileUpdatedDetail =>
      'कामको विवरण र अनुमतिपत्र सुरक्षित गरियो';

  @override
  String get appLanguage => 'एपको भाषा';

  @override
  String get profileSectionProfile => 'प्रोफाइल';

  @override
  String get profileSectionPreferences => 'प्राथमिकताहरू';

  @override
  String get personalDetails => 'व्यक्तिगत विवरण';

  @override
  String get legalDetails => 'कानुनी विवरण · नागरिकता / राष्ट्रिय परिचयपत्र';

  @override
  String get workDetails => 'कामको विवरण र अनुमतिपत्र';

  @override
  String get savedDocuments => 'सुरक्षित कागजातहरू';

  @override
  String get notificationSettings => 'सूचना सेटिङहरू';

  @override
  String get logOut => 'लग आउट';

  @override
  String get fullNameLabel => 'पूरा नाम';

  @override
  String get dateOfBirthLabel => 'जन्म मिति · ऐच्छिक';

  @override
  String get dateOfBirthHint => 'DD/MM/YYYY';

  @override
  String get genderLabel => 'लिङ्ग';

  @override
  String get genderFemale => 'महिला';

  @override
  String get genderMale => 'पुरुष';

  @override
  String get genderOther => 'अन्य';

  @override
  String get selectHint => 'छान्नुहोस्';

  @override
  String get mobileIsraelLabel => 'मोबाइल नम्बर (इजरायल)';

  @override
  String get mobileIsraelHint => '+972 5X-XXX-XXXX';

  @override
  String get homeInIsraelSection => 'इजरायलमा तपाईंको घर';

  @override
  String get councilCity => 'सिटी काउन्सिल';

  @override
  String get councilLocal => 'लोकल काउन्सिल';

  @override
  String get councilRegional => 'रिजनल काउन्सिल';

  @override
  String get districtLabel => 'जिल्ला';

  @override
  String get districtJerusalem => 'जेरुसलेम जिल्ला';

  @override
  String get districtNorthern => 'उत्तरी जिल्ला';

  @override
  String get districtHaifa => 'हाइफा जिल्ला';

  @override
  String get districtCentral => 'मध्य जिल्ला';

  @override
  String get districtTelAviv => 'तेल अभिभ जिल्ला';

  @override
  String get districtSouthern => 'दक्षिणी जिल्ला';

  @override
  String get localAuthorityLabel => 'स्थानीय निकाय';

  @override
  String get neighborhoodLabel => 'टोल वा बस्ती';

  @override
  String get neighborhoodHint => 'जस्तै: Kibbutz Afikim';

  @override
  String get postalCodeLabel => 'पोस्टल कोड · ७ अङ्क';

  @override
  String get homeHint =>
      'आधिकारिक अभिलेखका लागि उप-जिल्ला आफैं रेकर्ड हुन्छ। तपाईं किबुत्ज वा मोशाभमा बस्नुहुन्छ भने रिजनल काउन्सिलको नामको सट्टा सिधै त्यसैलाई खोज्नुहोस्।';

  @override
  String get nepalContactSection => 'नेपालमा सम्पर्क · ठेगाना होइन';

  @override
  String get contactNameLabel => 'सम्पर्क व्यक्तिको नाम';

  @override
  String get contactNameHint =>
      'जस्तै: आमाबुबा, श्रीमान्/श्रीमती वा दाजुभाइ-दिदीबहिनी';

  @override
  String get relationshipLabel => 'नाता';

  @override
  String get relationshipHint => 'जस्तै: आमा';

  @override
  String get contactPhoneLabel => 'फोन नम्बर';

  @override
  String get contactPhoneHint => '+977 98XXXXXXXX';

  @override
  String get emailLabel => 'इमेल ठेगाना · ऐच्छिक';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get contactHint =>
      'आपतकालमा परिवारलाई सम्पर्क गर्न वा आधिकारिक पत्राचारका लागि मात्र प्रयोग हुन्छ — यसलाई तपाईंको घरको ठेगाना मानिँदैन।';

  @override
  String get saveChanges => 'परिवर्तनहरू सुरक्षित गर्नुहोस्';

  @override
  String get detailsSaved => 'तपाईंको विवरण सुरक्षित भयो';

  @override
  String get errorFullName => 'आफ्नो पूरा नाम लेख्नुहोस्';

  @override
  String get errorGender => 'आफ्नो लिङ्ग छान्नुहोस्';

  @override
  String get errorMobileEmpty => 'आफ्नो इजरायली मोबाइल नम्बर लेख्नुहोस्';

  @override
  String get errorCouncilType =>
      'तपाईं बस्ने ठाउँको काउन्सिलको प्रकार छान्नुहोस्';

  @override
  String get errorDistrict => 'तपाईं बस्ने जिल्ला छान्नुहोस्';

  @override
  String get errorLocalAuthority =>
      'आफ्नो स्थानीय निकाय लेख्नुहोस्, जस्तै सिटी वा रिजनल काउन्सिल';

  @override
  String get errorNeighborhood => 'आफ्नो टोल, किबुत्ज वा मोशाभ लेख्नुहोस्';

  @override
  String get errorPostalCodeEmpty => 'आफ्नो ७ अङ्कको पोस्टल कोड लेख्नुहोस्';

  @override
  String get errorContactName =>
      'नेपालमा सम्पर्क गर्न सकिने व्यक्तिको नाम लेख्नुहोस्';

  @override
  String get errorRelationship => 'उहाँ तपाईंको को हुनुहुन्छ, लेख्नुहोस्';

  @override
  String get errorContactPhoneEmpty => 'उहाँको फोन नम्बर लेख्नुहोस्';

  @override
  String get errorIsraeliMobile =>
      'इजरायली मोबाइल नम्बर लेख्नुहोस्, जस्तै +972 52 123 4567';

  @override
  String get errorNepaliMobile =>
      'नेपाली मोबाइल नम्बर लेख्नुहोस्, जस्तै +977 98XXXXXXXX';

  @override
  String get errorPostalCode => 'पोस्टल कोड ७ अङ्कको हुनुपर्छ';

  @override
  String get errorEmail => 'सही इमेल ठेगाना लेख्नुहोस्';

  @override
  String get requiredField => 'आवश्यक';

  @override
  String get navHome => 'गृहपृष्ठ';

  @override
  String get navIssues => 'समस्याहरू';

  @override
  String get navActivity => 'गतिविधि';

  @override
  String get navProfile => 'प्रोफाइल';
}
