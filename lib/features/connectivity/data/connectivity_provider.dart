import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The plugin instance, as a provider so tests can override it.
final connectivityProvider = Provider((ref) => Connectivity());

/// Whether the device is connected to a network (Wi-Fi, mobile data, …).
///
/// Checks once at startup, then follows changes. Note it only knows about
/// the connection, not the internet behind it: Wi-Fi with no internet
/// (e.g. a hotel login page) still counts as online.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = ref.watch(connectivityProvider);
  yield _isOnline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_isOnline);
});

bool _isOnline(List<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);
