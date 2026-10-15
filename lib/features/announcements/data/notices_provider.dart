import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_exception.dart';
import '../../../app/api/paged.dart';
import '../../../app/api/paged_notifier.dart';
import '../models/announcement.dart';
import 'announcements_provider.dart';
import 'announcements_repository.dart';

/// The Notice tab's list: the first page on open, the next ones as the user
/// scrolls.
///
/// autoDispose: dropped once neither the Notice tab nor a notice page is
/// open.
final noticesProvider =
    AsyncNotifierProvider.autoDispose<NoticesNotifier, PagedList<Announcement>>(
      NoticesNotifier.new,
    );

class NoticesNotifier extends PagedNotifier<Announcement> {
  Timer? _linkRefresh;

  @override
  int get perPage => 5;

  @override
  Future<Paged<Announcement>> fetchPage({
    required int page,
    required int perPage,
  }) => ref
      .read(announcementsRepositoryProvider)
      .fetchAnnouncementsPage(page: page, perPage: perPage);

  @override
  Object idOf(Announcement item) => item.id;

  @override
  Future<PagedList<Announcement>> build() async {
    ref.onDispose(() => _linkRefresh?.cancel());
    final list = await super.build();
    _scheduleLinkRefresh(list.items);
    return list;
  }

  /// The image links expire, and the list would show broken images after
  /// that. Shortly before, fetch the loaded notices again for fresh links.
  void _scheduleLinkRefresh(List<Announcement> items) {
    _linkRefresh?.cancel();
    final delay = linkRefreshDelay(items);
    if (delay != null) _linkRefresh = Timer(delay, _refreshLinks);
  }

  Future<void> _refreshLinks() async {
    try {
      await reloadLoaded();
    } on ApiException {
      // Keep the current list; try again at the next refresh.
    }
    if (ref.mounted) _scheduleLinkRefresh(state.value?.items ?? const []);
  }
}
