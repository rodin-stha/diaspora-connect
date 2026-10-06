import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/locale_provider.dart';
import '../models/activity.dart';
import 'activity_repository.dart';

final activityProvider =
    AsyncNotifierProvider<ActivityNotifier, List<Activity>>(
      ActivityNotifier.new,
    );

const _readUntilKey = 'activity_read_until';

class ActivityNotifier extends AsyncNotifier<List<Activity>> {
  @override
  Future<List<Activity>> build() async {
    final activities = await ref
        .read(activityRepositoryProvider)
        .fetchActivity();
    final readUntil = DateTime.tryParse(
      ref.read(sharedPreferencesProvider).getString(_readUntilKey) ?? '',
    );

    return [
      for (final activity in activities)
        activity.copyWith(
          isRead: readUntil != null && !activity.date.isAfter(readUntil),
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Adds something that just happened to the top of the feed, without
  /// waiting for a refetch. For actions the server doesn't log yet.
  void record(ActivityEvent event) {
    final current = state.value;
    if (current == null) return; // Not loaded: the next fetch shows it.
    final now = DateTime.now();
    state = AsyncData([
      Activity(id: 'a${now.microsecondsSinceEpoch}', date: now, event: event),
      ...current,
    ]);
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null || current.isEmpty) return;

    await ref
        .read(sharedPreferencesProvider)
        .setString(_readUntilKey, current.first.date.toIso8601String());
    // Replace the list, never mutate it: Riverpod only notifies listeners
    // when `state` is a new object.
    state = AsyncData([
      for (final activity in current) activity.copyWith(isRead: true),
    ]);
  }
}
