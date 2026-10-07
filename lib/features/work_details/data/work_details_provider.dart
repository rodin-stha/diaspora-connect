import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employment_type.dart';
import '../models/work_details.dart';
import 'work_details_repository.dart';

/// The signed-in user's work details and permit.
///
/// Starts empty until loading (GET /work-details) is wired up; saving
/// already goes to the API.
final workDetailsProvider = NotifierProvider<WorkDetailsNotifier, WorkDetails>(
  WorkDetailsNotifier.new,
);

/// The types of business to choose from. Fetched once and cached for the
/// session.
final employmentTypesProvider = FutureProvider<List<EmploymentType>>(
  (ref) => ref.read(workDetailsRepositoryProvider).fetchEmploymentTypes(),
);

class WorkDetailsNotifier extends Notifier<WorkDetails> {
  @override
  // Empty, not sample values: saving now reaches the server, and a user
  // tapping Save shouldn't send made-up data.
  // TODO: load from GET /work-details.
  WorkDetails build() => const WorkDetails();

  /// Sends the details to the API. Throws [ApiException] if that fails,
  /// leaving the current details unchanged.
  Future<void> save(WorkDetails details) async {
    await ref.read(workDetailsRepositoryProvider).saveWorkDetails(details);
    state = details;
  }
}
