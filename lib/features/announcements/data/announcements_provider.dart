import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/announcement.dart';
import 'announcements_repository.dart';

/// Home's carousel shows only the latest few.
const _homeLimit = 5;

/// Fetch again this long before the first image link expires.
const _refreshBeforeExpiry = Duration(minutes: 2);

/// Never refetch more often than this, even if the links look expired
/// already (e.g. the phone's clock is off).
const _minRefreshInterval = Duration(minutes: 1);

/// The latest few announcements, for the carousel on Home.
///
/// autoDispose: only fetched while Home is open.
final announcementsProvider = FutureProvider.autoDispose<List<Announcement>>((
  ref,
) async {
  final announcements = await ref
      .read(announcementsRepositoryProvider)
      .fetchAnnouncements(limit: _homeLimit);
  _refetchBeforeLinksExpire(ref, announcements);
  return announcements;
});

/// All announcements (the first page), for the Notice tab.
final allAnnouncementsProvider = FutureProvider.autoDispose<List<Announcement>>(
  (ref) async {
    final announcements = await ref
        .read(announcementsRepositoryProvider)
        .fetchAnnouncements();
    _refetchBeforeLinksExpire(ref, announcements);
    return announcements;
  },
);

/// The image links expire, and a cached list would show broken images after
/// that. Refetch shortly before, for fresh links. While refetching, Riverpod
/// keeps the current list, so nothing flickers.
void _refetchBeforeLinksExpire(Ref ref, List<Announcement> announcements) {
  if (announcements.isEmpty || !ref.mounted) return;

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
}
