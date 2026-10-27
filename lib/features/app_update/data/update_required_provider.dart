import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/api/api_exception.dart';
import '../../platform_settings/data/platform_settings_provider.dart';
import '../../platform_settings/models/platform_settings.dart';
import '../version.dart';

/// This build's name, version and package ID, as set in pubspec.yaml.
final appInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

/// Whether this version is too old to use (see [MinVersion]).
///
/// False when the API can't be reached: blocking someone over a network
/// error would be worse than letting an old version run a little longer.
final updateRequiredProvider = FutureProvider<bool>((ref) async {
  final MinVersion minVersion;
  try {
    minVersion = (await ref.watch(platformSettingsProvider.future)).minVersion;
  } on ApiException {
    return false;
  }

  final minimum = switch (defaultTargetPlatform) {
    TargetPlatform.android => minVersion.android,
    TargetPlatform.iOS => minVersion.ios,
    _ => null,
  };
  if (minimum == null) return false;

  final current = (await ref.watch(appInfoProvider.future)).version;
  return isOlderVersion(current, minimum);
});
