import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../personal_details/data/personal_details_provider.dart';
import '../models/user_profile.dart';

/// The signed-in user, as shown in Home (greeting) and Profile (header).
///
/// Derived from [personalDetailsProvider]: when the details are saved, this
/// recomputes and both screens update.
final currentUserProvider = Provider<UserProfile>((ref) {
  final details = ref.watch(personalDetailsProvider).value;
  final name = details?.name ?? '';
  final names = name.trim().split(RegExp(r'\s+'));

  return UserProfile(
    givenName: names.first,
    fullName: name,
    // "Haifa • Hof HaCarmel • Geva Karmel"; parts not filled in are skipped.
    location: [
      details?.districtName ?? '',
      details?.localAuthorityName ?? '',
      details?.localityName ?? '',
    ].where((part) => part.isNotEmpty).join(' • '),
  );
});
