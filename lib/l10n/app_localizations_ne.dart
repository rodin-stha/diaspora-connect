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
  String get categoryLabel => 'वर्ग';

  @override
  String get concernedLabel => 'सम्बन्धित रोजगारदाता / दूतावास · ऐच्छिक';

  @override
  String get concernedHint => 'रोजगारदाता वा दूतावासको नाम';

  @override
  String get subjectLabel => 'विषय';

  @override
  String get subjectHint => 'जस्तै: अक्टोबरको तलब कम';

  @override
  String get descriptionLabel => 'समस्याको विवरण · ऐच्छिक';

  @override
  String get descriptionHint => 'के भयो, कहाँ र कहिलेदेखि?';

  @override
  String get evidenceSection => 'प्रमाण थप्नुहोस् · ऐच्छिक';

  @override
  String get evidencePhoto => 'फोटो';

  @override
  String get evidenceLocation => 'नक्सामा स्थान';

  @override
  String get evidenceVoice => 'आवाज रेकर्ड';

  @override
  String get voiceNoteHint =>
      'लेख्न सहज लाग्दैन? के भयो भनेर छोटो आवाज सन्देश रेकर्ड गर्नुहोस्।';

  @override
  String get submitIssue => 'समस्या पेश गर्नुहोस्';

  @override
  String get issueSubmitted => 'तपाईंको समस्या पेश भयो';

  @override
  String get errorCategory => 'समस्या केको बारेमा हो, छान्नुहोस्';

  @override
  String get errorSubject => 'समस्याको छोटो शीर्षक लेख्नुहोस्';

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
  String get completedToday => 'आज सम्पन्न भयो';

  @override
  String completedOn(String date) {
    return '$date मा सम्पन्न भयो';
  }

  @override
  String get overdue => 'म्याद नाघेको';

  @override
  String get statusAssigned => 'सुम्पिइएको';

  @override
  String get statusInProgress => 'प्रगतिमा';

  @override
  String get statusEscalated => 'माथि पठाइएको';

  @override
  String get statusNew => 'नयाँ';

  @override
  String get statusRejected => 'अस्वीकृत';

  @override
  String get statusResolved => 'समाधान भयो';

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
  String get timelineSubmitted => 'पेश गरियो';

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
  String get dateHint => 'DD/MM/YYYY';

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
  String get legalDetailsTitle => 'कानुनी विवरण';

  @override
  String get passportNumberLabel => 'राहदानी नम्बर';

  @override
  String get passportNumberHint => 'जस्तै: 09XXXXXX';

  @override
  String get passportExpiryLabel => 'राहदानीको म्याद';

  @override
  String get nationalIdLabel => 'राष्ट्रिय परिचयपत्र नं. · ऐच्छिक';

  @override
  String get nationalIdHint => 'राष्ट्रिय परिचयपत्र नम्बर लेख्नुहोस्';

  @override
  String get citizenshipNumberLabel => 'नागरिकता प्रमाणपत्र नं.';

  @override
  String get citizenshipNumberHint => 'जस्तै: 27-01-73-01234';

  @override
  String get uploadedDocumentsSection => 'अपलोड गरिएका कागजात';

  @override
  String get documentPassportPhotoPage => 'राहदानी · फोटो पृष्ठ';

  @override
  String get documentIsraelVisaPage => 'इजरायली भिसा पृष्ठ';

  @override
  String get replaceAction => 'बदल्नुहोस्';

  @override
  String get uploadAction => 'अपलोड गर्नुहोस्';

  @override
  String get errorPassportNumber => 'आफ्नो राहदानी नम्बर लेख्नुहोस्';

  @override
  String get errorPassportNumberFormat =>
      'राहदानीमा छापिएजस्तै लेख्नुहोस्: ६–९ अक्षर वा अङ्क';

  @override
  String get errorPassportExpiry => 'म्याद सकिने मिति छान्नुहोस्';

  @override
  String get errorCitizenshipNumber =>
      'आफ्नो नागरिकता प्रमाणपत्र नम्बर लेख्नुहोस्';

  @override
  String get documentWorkPermitLetter => 'कार्य अनुमति स्वीकृति पत्र';

  @override
  String get viewAction => 'हेर्नुहोस्';

  @override
  String get errorOpenDocument =>
      'कागजात खोल्न सकिएन। तल तानेर रिफ्रेस गर्नुहोस् र फेरि प्रयास गर्नुहोस्।';

  @override
  String get noSavedDocuments =>
      'तपाईंले अहिलेसम्म कुनै कागजात अपलोड गर्नुभएको छैन।';

  @override
  String get errorLoadDocuments => 'तपाईंका कागजातहरू लोड गर्न सकिएन।';

  @override
  String get uploadDocumentTitle => 'कागजात अपलोड गर्नुहोस्';

  @override
  String get documentNameLabel => 'कागजातको नाम';

  @override
  String get documentNameHint => 'जस्तै: तलब पर्ची – मार्च';

  @override
  String get errorDocumentName => 'कागजातको नाम लेख्नुहोस्';

  @override
  String get documentUploaded => 'कागजात अपलोड भयो';

  @override
  String get uploadNewDocument => 'नयाँ कागजात अपलोड गर्नुहोस्';

  @override
  String get errorLoadEmploymentTypes => 'व्यवसायका प्रकारहरू लोड गर्न सकिएन।';

  @override
  String get businessTypeLabel => 'व्यवसायको प्रकार';

  @override
  String get workPermitSection => 'कार्य अनुमति';

  @override
  String get caregivingDetailsSection => 'हेरचाह कामको विवरण';

  @override
  String get careArrangementLabel => 'घरमै बस्ने वा बाहिर बस्ने';

  @override
  String get liveIn => 'घरमै बस्ने';

  @override
  String get liveOut => 'बाहिर बस्ने';

  @override
  String get hostFamilyLabel => 'होस्ट परिवार / हेरचाह संस्था · ऐच्छिक';

  @override
  String get hostFamilyHint => 'परिवार वा संस्थाको नाम';

  @override
  String get errorBusinessType => 'तपाईं काम गर्ने व्यवसायको प्रकार छान्नुहोस्';

  @override
  String get errorCareArrangement => 'घरमै बस्ने वा बाहिर बस्ने छान्नुहोस्';

  @override
  String alertIssueStatusChanged(String title, String status) {
    return '“$title” अब $status छ';
  }

  @override
  String alertIssueAssigned(String title, String caseWorker) {
    return '“$title” $caseWorker लाई सुम्पिइयो';
  }

  @override
  String alertIssuesUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'तपाईंका $count वटा समस्याहरू अपडेट भए',
    );
    return '$_temp0';
  }

  @override
  String get howNotifiedSection => 'तपाईंलाई कसरी सूचना दिइन्छ';

  @override
  String get whatNotifiedSection => 'केको बारेमा सूचना दिइन्छ';

  @override
  String get notifySms => 'SMS सूचना';

  @override
  String get notifyInApp => 'एपभित्रको सूचना';

  @override
  String get notifyIssueStatus => 'समस्याको स्थिति परिवर्तन';

  @override
  String get notifyDocumentExpiry => 'कागजातको म्याद सकिने सम्झना';

  @override
  String get notifyAnnouncements => 'दूतावास र वैदेशिक रोजगार विभागका सूचना';

  @override
  String get mobileNumberLabel => 'मोबाइल नम्बर';

  @override
  String get mobileNumberHint => '5X-XXX-XXXX';

  @override
  String get sendOtp => 'OTP पठाउनुहोस्';

  @override
  String get loginConsent =>
      'अगाडि बढेर, तपाईंको पहिचान प्रमाणित गर्न यो नम्बर प्रयोग गरिनेमा सहमत हुनुहुन्छ।';

  @override
  String get errorLoginMobile => 'आफ्नो मोबाइल नम्बर लेख्नुहोस्';

  @override
  String developedBy(String company) {
    return '$company द्वारा विकसित';
  }

  @override
  String get verifyTitle => 'आफ्नो नम्बर प्रमाणित गर्नुहोस्';

  @override
  String verifySubtitle(String phone) {
    return '$phone मा SMS बाट पठाइएको ६ अङ्कको कोड लेख्नुहोस्';
  }

  @override
  String get otpFieldLabel => '६ अङ्कको कोड';

  @override
  String get resendPrompt => 'कोड आएन?';

  @override
  String resendIn(String time) {
    return '$time मा फेरि पठाउन सकिन्छ';
  }

  @override
  String get resendAction => 'फेरि पठाउनुहोस्';

  @override
  String get codeResent => 'नयाँ कोड पठाइयो';

  @override
  String get verifyAction => 'प्रमाणित गर्नुहोस्';

  @override
  String get errorOtpIncomplete => 'सबै ६ अङ्क लेख्नुहोस्';

  @override
  String get errorOtpWrong => 'कोड मिलेन। SMS हेरेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get logOutConfirmTitle => 'लग आउट गर्ने?';

  @override
  String get logOutConfirmBody =>
      'के तपाईं पक्का लग आउट गर्न चाहनुहुन्छ? फेरि साइन इन गर्न तपाईंको मोबाइल नम्बर र नयाँ कोड चाहिन्छ।';

  @override
  String get navHome => 'गृहपृष्ठ';

  @override
  String get navIssues => 'समस्याहरू';

  @override
  String get navActivity => 'गतिविधि';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String onboardingStep(int step, int total) {
    return 'चरण $step / $total';
  }

  @override
  String get onboardingWorkTitle => 'कामको विवरण';

  @override
  String get continueAction => 'जारी राख्नुहोस्';

  @override
  String get verifyAndContinue => 'प्रमाणित गरी जारी राख्नुहोस्';

  @override
  String get saveProfile => 'प्रोफाइल सुरक्षित गर्नुहोस्';

  @override
  String get uploadPhotoPage => 'फोटो पृष्ठ';

  @override
  String get uploadWorkPermit =>
      'कार्य अनुमतिपत्र अपलोड गर्नुहोस् (Rishayon Avoda)';

  @override
  String get identityConsent => 'म पहिचान प्रमाणीकरणमा सहमत छु';

  @override
  String get errorIdentityConsent => 'जारी राख्न बाकसमा टिक लगाउनुहोस्';

  @override
  String get errorNoConnection =>
      'इन्टरनेट जडान छैन। जडान जाँचेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get errorTimeout =>
      'सर्भरले धेरै समय लियो। केही बेरपछि फेरि प्रयास गर्नुहोस्।';

  @override
  String get errorGeneric => 'केही गडबड भयो। फेरि प्रयास गर्नुहोस्।';

  @override
  String get loadingHint => 'लोड हुँदैछ…';

  @override
  String get errorLoadDistricts => 'जिल्लाहरू लोड गर्न सकिएन।';

  @override
  String get retry => 'फेरि प्रयास गर्नुहोस्';

  @override
  String get chooseDistrictFirst =>
      'पहिले काउन्सिलको प्रकार र जिल्ला छान्नुहोस्';

  @override
  String get errorLoadAuthorities => 'स्थानीय निकायहरू लोड गर्न सकिएन।';

  @override
  String get localityLabel => 'बस्ती';

  @override
  String get errorLocality => 'आफ्नो बस्ती छान्नुहोस्';

  @override
  String get chooseLocalAuthorityFirst => 'पहिले स्थानीय निकाय छान्नुहोस्';

  @override
  String get errorLoadLocalities => 'बस्तीहरू लोड गर्न सकिएन।';

  @override
  String get takePhoto => 'फोटो खिच्नुहोस्';

  @override
  String get chooseFromGallery => 'ग्यालरीबाट छान्नुहोस्';

  @override
  String get errorImageAccess =>
      'कागजात अपलोड गर्न सेटिङमा क्यामेरा र फोटो पहुँच दिनुहोस्।';

  @override
  String get errorPhotoPage => 'राहदानीको फोटो पेज अपलोड गर्नुहोस्';

  @override
  String get errorVisaPage => 'इजरायलको भिसा पेज अपलोड गर्नुहोस्';

  @override
  String get activityPersonalDetailsSavedDetail =>
      'व्यक्तिगत विवरण सुरक्षित गरियो';

  @override
  String get activityAccountCreated => 'खाता बनाइयो';

  @override
  String get activityAccountCreatedDetail =>
      'तपाईंको मोबाइल नम्बरबाट साइन अप गरियो';

  @override
  String get errorLoadActivity => 'तपाईंको गतिविधि लोड गर्न सकिएन।';

  @override
  String get errorLoadCategories => 'श्रेणीहरू लोड गर्न सकिएन।';

  @override
  String get pinLocationTitle => 'स्थान पिन गर्नुहोस्';

  @override
  String get pinLocationHint =>
      'घटना भएको ठाउँमा पिन पर्ने गरी नक्सा सार्नुहोस्।';

  @override
  String get useThisLocation => 'यो स्थान प्रयोग गर्नुहोस्';

  @override
  String get locationPinned => 'स्थान पिन गरियो';

  @override
  String get voiceNote => 'भ्वाइस नोट';

  @override
  String get recordingTitle => 'रेकर्ड हुँदैछ…';

  @override
  String get stopRecording => 'रोक्नुहोस्';

  @override
  String get playAction => 'बजाउनुहोस्';

  @override
  String get pauseAction => 'रोक्नुहोस्';

  @override
  String get errorMicrophoneAccess =>
      'भ्वाइस नोट रेकर्ड गर्न सेटिङमा माइक्रोफोन पहुँच दिनुहोस्।';

  @override
  String get noIssuesYet =>
      'तपाईंले अहिलेसम्म कुनै समस्या रिपोर्ट गर्नुभएको छैन।';

  @override
  String get errorLoadIssues => 'तपाईंका समस्याहरू लोड गर्न सकिएन।';

  @override
  String get reportNewIssue => 'नयाँ समस्या रिपोर्ट गर्नुहोस्';

  @override
  String get noInternetConnection => 'इन्टरनेट जडान छैन';

  @override
  String get backOnline => 'फेरि अनलाइन भयो';
}
