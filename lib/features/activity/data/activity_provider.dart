import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/paged.dart';
import '../../../app/api/paged_notifier.dart';
import '../../../app/locale_provider.dart';
import '../models/activity.dart';
import 'activity_repository.dart';

/// The activity feed, newest first, loaded a page at a time as it scrolls.
final activityProvider =
    AsyncNotifierProvider<ActivityNotifier, PagedList<Activity>>(
      ActivityNotifier.new,
    );

const _readUntilKey = 'activity_read_until';

class ActivityNotifier extends PagedNotifier<Activity> {
  @override
  int get perPage => 20;

  @override
  Object idOf(Activity item) => item.id;

  /// A page, with read/unread set: the API has no read status, so anything
  /// up to the last "Mark all read" counts as read.
  @override
  Future<Paged<Activity>> fetchPage({
    required int page,
    required int perPage,
  }) async {
    final result = await ref
        .read(activityRepositoryProvider)
        .fetchActivity(page: page, perPage: perPage);
    final readUntil = DateTime.tryParse(
      ref.read(sharedPreferencesProvider).getString(_readUntilKey) ?? '',
    );

    return Paged(
      items: [
        for (final activity in result.items)
          activity.copyWith(
            isRead: readUntil != null && !activity.date.isAfter(readUntil),
          ),
      ]..sort((a, b) => b.date.compareTo(a.date)),
      hasMore: result.hasMore,
      total: result.total,
    );
  }

  /// Adds something that just happened to the top of the feed, without
  /// waiting for a refetch. For actions the server doesn't log yet.
  void record(ActivityEvent event) {
    final current = state.value;
    if (current == null) return; // Not loaded: the next fetch shows it.
    final now = DateTime.now();
    state = AsyncData(
      current.copyWith(
        items: [
          Activity(
            id: 'a${now.microsecondsSinceEpoch}',
            date: now,
            event: event,
          ),
          ...current.items,
        ],
      ),
    );
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null || current.items.isEmpty) return;

    // Saved as a date, so pages loaded later are marked read too.
    await ref
        .read(sharedPreferencesProvider)
        .setString(_readUntilKey, current.items.first.date.toIso8601String());
    // Replace the list, never mutate it: Riverpod only notifies listeners
    // when `state` is a new object.
    state = AsyncData(
      current.copyWith(
        items: [
          for (final activity in current.items) activity.copyWith(isRead: true),
        ],
      ),
    );
  }
}
