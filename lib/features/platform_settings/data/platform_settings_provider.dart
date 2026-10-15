import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/platform_settings.dart';
import 'platform_settings_repository.dart';

/// The SOS and helpline numbers.
///
/// Not autoDispose: they rarely change, so they're fetched once and kept,
/// and the SOS sheet opens with the number already there.
final platformSettingsProvider = FutureProvider<PlatformSettings>(
  (ref) => ref.read(platformSettingsRepositoryProvider).fetchPlatformSettings(),
);
