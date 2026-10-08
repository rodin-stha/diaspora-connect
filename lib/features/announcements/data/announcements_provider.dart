import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/announcement.dart';
import 'announcements_repository.dart';

/// Fetch again this long before the first image link expires.
const _refreshBeforeExpiry = Duration(minutes: 2);

/// Never refetch more often than this, even if the links look expired
/// already (e.g. the phone's clock is off).
const _minRefreshInterval = Duration(minutes: 1);

/// The announcements shown on Home.
///
/// autoDispose: only fetched while Home shows them, i.e. while "Embassy &
/// DoFE announcements" is on in Notification settings.
final announcementsProvider = FutureProvider.autoDispose<List<Announcement>>((
  ref,
) async {
  final announcements = await ref
      .read(announcementsRepositoryProvider)
      .fetchAnnouncements();
  if (announcements.isEmpty || !ref.mounted) return announcements;

  // The image links expire, and a cached list would show broken images
  // after that. Refetch shortly before, for fresh links. While refetching,
  // Riverpod keeps the current list, so the carousel doesn't flicker.
  final firstExpiry = announcements
      .map((announcement) => announcement.imageExpiresAt)
      .reduce((a, b) => a.isBefore(b) ? a : b);
  final untilRefresh =
      firstExpiry.difference(DateTime.now()) - _refreshBeforeExpiry;
  final timer = Timer(
    untilRefresh < _minRefreshInterval ? _minRefreshInterval : untilRefresh,
    ref.invalidateSelf,
  );
  ref.onDispose(timer.cancel);

  return announcements;
});
