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

/// The latest few announcements with an image, for the carousel on Home.
/// Text-only ones are left out (a slide needs a picture); they're on the
/// Notice tab.
///
/// autoDispose: only fetched while Home is open.
final announcementsProvider = FutureProvider.autoDispose<List<Announcement>>((
  ref,
) async {
  final page = await ref
      .read(announcementsRepositoryProvider)
      .fetchAnnouncementsPage(page: 1, perPage: _homeLimit);
  final announcements = page.items
      .where((announcement) => announcement.image != null)
      .toList();

  // The image links expire, and a cached list would show broken images
  // after that. Refetch shortly before, for fresh links. While refetching,
  // Riverpod keeps the current list, so the carousel doesn't flicker.
  final delay = linkRefreshDelay(announcements);
  if (delay != null && ref.mounted) {
    final timer = Timer(delay, ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return announcements;
});

/// How long until [announcements] should be fetched again for fresh image
/// links, or null if none has an image.
Duration? linkRefreshDelay(List<Announcement> announcements) {
  final expiries = [
    for (final announcement in announcements)
      if (announcement.image case final image?) image.expiresAt,
  ];
  if (expiries.isEmpty) return null;

  final firstExpiry = expiries.reduce((a, b) => a.isBefore(b) ? a : b);
  final untilRefresh =
      firstExpiry.difference(DateTime.now()) - _refreshBeforeExpiry;
  return untilRefresh < _minRefreshInterval
      ? _minRefreshInterval
      : untilRefresh;
}
