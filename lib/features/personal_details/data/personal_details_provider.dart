import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/personal_details.dart';

/// The signed-in user's personal details. Home and Profile read their name
/// and location from here (via `currentUserProvider`), so saving updates
/// them too.
///
/// Returns sample data until the backend API exists.
final personalDetailsProvider =
    NotifierProvider<PersonalDetailsNotifier, PersonalDetails>(
      PersonalDetailsNotifier.new,
    );

class PersonalDetailsNotifier extends Notifier<PersonalDetails> {
  @override
  PersonalDetails build() => _sample;

  void save(PersonalDetails details) => state = details;
}

// Values from the Figma design; empty fields are placeholders there.
const _sample = PersonalDetails(
  fullName: 'Sita Kumari Shrestha',
  gender: Gender.female,
  mobileNumber: '+972 52 123 4567',
  councilType: CouncilType.regional,
  district: IsraelDistrict.central,
  localAuthority: "Emek HaMa'ayanot Regional Council",
  neighborhood: 'Kibbutz Afikim',
  postalCode: '',
  contactName: '',
  contactRelationship: '',
  contactPhone: '',
  email: '',
);
