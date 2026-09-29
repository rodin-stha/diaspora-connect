import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity.dart';

/// The user's account activity, newest first, and the actions that change it.
///
/// Returns sample data until the backend API exists.
final activityProvider = NotifierProvider<ActivityNotifier, List<Activity>>(
  ActivityNotifier.new,
);

class ActivityNotifier extends Notifier<List<Activity>> {
  @override
  List<Activity> build() =>
      [..._sampleActivity]..sort((a, b) => b.date.compareTo(a.date));

  void markAllRead() {
    // Replace the list, never mutate it: Riverpod only notifies listeners
    // when `state` is a new object.
    state = [for (final activity in state) activity.copyWith(isRead: true)];
  }
}

final _sampleActivity = [
  Activity(
    id: 'a1',
    date: DateTime(2026, 9, 6, 18, 40),
    event: const IssueSubmitted(
      reference: 'GN-2083-004530',
      issueTitle: 'Housing dispute, live-in contract',
    ),
  ),
  Activity(
    id: 'a2',
    date: DateTime(2026, 9, 4, 11, 2),
    event: const MobileNumberUpdated(maskedNumber: '+972 5X-XXX-XXXX'),
  ),
  Activity(
    id: 'a3',
    date: DateTime(2026, 9, 3, 9, 14),
    event: const SignedIn(),
  ),
  Activity(
    id: 'a4',
    date: DateTime(2026, 8, 28, 15, 20),
    event: const DocumentUploaded(documentName: 'Passport photo page'),
    isRead: true,
  ),
  Activity(
    id: 'a5',
    // Figma says 8 Sep but lists it last; a feed is newest first, so it's
    // dated before the item above to keep the design's order.
    date: DateTime(2026, 8, 27, 11, 22),
    event: const ProfileUpdated(),
    isRead: true,
  ),
];
