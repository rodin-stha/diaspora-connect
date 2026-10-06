import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/authority.dart';
import '../models/district.dart';
import '../models/locality.dart';
import '../models/personal_details.dart';
import 'personal_details_repository.dart';

/// Returns sample data until the backend API exists.
final personalDetailsProvider =
    AsyncNotifierProvider<PersonalDetailsNotifier, PersonalDetails>(
      PersonalDetailsNotifier.new,
    );

final districtsProvider = FutureProvider<List<District>>(
  (ref) => ref.read(personalDetailsRepository).fetchDistricts(),
);

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

class PersonalDetailsNotifier extends AsyncNotifier<PersonalDetails> {
  @override
  Future<PersonalDetails> build() =>
      ref.read(personalDetailsRepository).fetchPersonalDetails();

  Future<void> save(PersonalDetails details) async {
    await ref.read(personalDetailsRepository).savePersonalDetails(details);
    state = AsyncData(details);
  }
}
