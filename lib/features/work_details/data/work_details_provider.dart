import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employment_type.dart';
import '../models/work_details.dart';
import 'work_details_repository.dart';

/// The signed-in user's work details and permit.
final workDetailsProvider =
    AsyncNotifierProvider<WorkDetailsNotifier, WorkDetails>(
      WorkDetailsNotifier.new,
    );

/// The types of business to choose from. Fetched once and cached for the
/// session.
final employmentTypesProvider = FutureProvider<List<EmploymentType>>(
  (ref) => ref.read(workDetailsRepositoryProvider).fetchEmploymentTypes(),
);

class WorkDetailsNotifier extends AsyncNotifier<WorkDetails> {
  @override
  Future<WorkDetails> build() =>
      ref.read(workDetailsRepositoryProvider).fetchWorkDetails();

  /// Sends the details to the API. Throws [ApiException] if that fails,
  /// leaving the current details unchanged.
  Future<void> save(WorkDetails details) async {
    await ref.read(workDetailsRepositoryProvider).saveWorkDetails(details);
    state = AsyncData(details);
  }
}
