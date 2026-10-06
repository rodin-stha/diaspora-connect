import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/authority.dart';
import '../models/district.dart';
import '../models/locality.dart';
import '../models/personal_details.dart';
import 'personal_details_repository.dart';

/// Returns sample data until the backend API exists.
final personalDetailsProvider =
    NotifierProvider<PersonalDetailsNotifier, PersonalDetails>(
      PersonalDetailsNotifier.new,
    );

final districtsProvider = FutureProvider<List<District>>(
  (ref) => ref.read(personalDetailsRepository).fetchDistricts(),
);

/// The local authorities for one district and authority type. `.family`
/// makes one cached provider per combination, so switching back to a
/// district you already picked doesn't fetch again.
final authoritiesProvider =
    FutureProvider.family<
      List<Authority>,
      ({int districtId, AuthorityType type})
    >(
      (ref, query) => ref
          .read(personalDetailsRepository)
          .fetchAuthoritiesList(query.districtId, query.type),
    );

final localityProvider =
    FutureProvider.family<List<Locality>, ({int localAuthorityId})>(
      (ref, query) => ref
          .read(personalDetailsRepository)
          .fetchLocality(query.localAuthorityId),
    );

class PersonalDetailsNotifier extends Notifier<PersonalDetails> {
  @override
  PersonalDetails build() => _sample;

  /// Sends the details to the API, then updates the app (Home and Profile
  /// read the name and location from here).
  Future<void> save(PersonalDetails details) async {
    await ref.read(personalDetailsRepository).savePersonalDetails(details);
    state = details;
  }
}

// Values from the Figma design; empty fields are placeholders there.
const _sample = PersonalDetails(
  name: 'Sita Kumari Shrestha',
  gender: Gender.female,
  authorityType: AuthorityType.regionalCouncil,
  localityName: "Emek HaMa'ayanot Regional Council",
  neighborhoodName: 'Kibbutz Afikim',
  postalCode: '',
  contactPersonName: '',
  contactPersonRelationship: '',
  contactPersonContact: '',
  contactPersonEmail: '',
);
