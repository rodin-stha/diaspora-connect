enum Gender { female, male, other }

/// Type of Israeli local authority the user lives under.
enum CouncilType { city, local, regional }

/// Israel's six administrative districts.
enum IsraelDistrict { jerusalem, northern, haifa, central, telAviv, southern }

/// Everything on the Personal details form (Profile → Personal details, and
/// onboarding step 1).
///
/// Optional or not-yet-filled fields are `null` (choices) or `''` (text), so
/// onboarding can start from [PersonalDetails.empty].
class PersonalDetails {
  final String fullName;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final String mobileNumber;

  // Home in Israel
  final CouncilType? councilType;
  final IsraelDistrict? district;
  final String localAuthority;
  final String neighborhood;
  final String postalCode;

  // Contact in Nepal (for emergencies, not an address)
  final String contactName;
  final String contactRelationship;
  final String contactPhone;
  final String email;

  const PersonalDetails({
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    required this.mobileNumber,
    this.councilType,
    this.district,
    required this.localAuthority,
    required this.neighborhood,
    required this.postalCode,
    required this.contactName,
    required this.contactRelationship,
    required this.contactPhone,
    required this.email,
  });

  const PersonalDetails.empty()
    : this(
        fullName: '',
        mobileNumber: '',
        localAuthority: '',
        neighborhood: '',
        postalCode: '',
        contactName: '',
        contactRelationship: '',
        contactPhone: '',
        email: '',
      );
}
