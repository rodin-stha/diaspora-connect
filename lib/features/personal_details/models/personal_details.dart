enum Gender { female, male, other }

/// Type of Israeli local authority the user lives under.
enum AuthorityType {
  city('city'),
  localCouncil('local_council'),
  regionalCouncil('regional_council');

  const AuthorityType(this.apiValue);

  /// How the API spells it.
  final String apiValue;
}

class PersonalDetails {
  final String name;
  final DateTime? dob;
  final Gender? gender;

  // Home in Israel
  final AuthorityType? authorityType;
  final int? districtId;
  final int? localAuthorityId;
  final int? localityId;

  /// The chosen authority's name, kept so Profile can show it without
  /// fetching the list.
  final String localityName;
  final String neighborhoodName;
  final String postalCode;

  // Contact in Nepal (for emergencies, not an address)
  final String contactPersonName;
  final String contactPersonRelationship;
  final String contactPersonContact;
  final String contactPersonEmail;

  const PersonalDetails({
    required this.name,
    this.dob,
    this.gender,
    this.authorityType,
    this.districtId,
    this.localAuthorityId,
    this.localityId,
    required this.localityName,
    required this.neighborhoodName,
    required this.postalCode,
    required this.contactPersonName,
    required this.contactPersonRelationship,
    required this.contactPersonContact,
    required this.contactPersonEmail,
  });

  const PersonalDetails.empty()
    : this(
        name: 'Rodin Shrestha',
        localityName: '',
        neighborhoodName: 'Test',
        postalCode: '1231231',
        contactPersonName: 'Rodin Shrestha',
        contactPersonRelationship: 'Mother',
        contactPersonContact: '+977 9845687142',
        contactPersonEmail: 'test@gmail.com',
      );

  /// The request body for saving the details. The API's snake_case keys
  /// live only here.
  Map<String, dynamic> toJson() => {
    'name': name,
    'dob': dob?.toIso8601String().split('T').first, // yyyy-MM-dd
    'gender': gender?.name,
    'authority_type': authorityType?.apiValue,
    'district_id': districtId,
    'local_authority_id': localAuthorityId,
    'locality_id': localityId,
    'neighborhood_name': neighborhoodName,
    'postal_code': postalCode,
    'contact_person_name': contactPersonName,
    'contact_person_relationship': contactPersonRelationship,
    'contact_person_contact': contactPersonContact,
    'contact_person_email': contactPersonEmail,
  };
}
