import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/work_details.dart';

/// The signed-in user's work details and permit.
///
/// Returns sample data until the backend API exists.
final workDetailsProvider = NotifierProvider<WorkDetailsNotifier, WorkDetails>(
  WorkDetailsNotifier.new,
);

class WorkDetailsNotifier extends Notifier<WorkDetails> {
  @override
  WorkDetails build() => _sample;

  void save(WorkDetails details) => state = details;
}

// Values from the Figma design.
const _sample = WorkDetails(
  businessType: BusinessType.caregiving,
  workPermitLetter: 'work_permit_approval.pdf',
  careArrangement: CareArrangement.liveIn,
  hostFamily: 'Levi family, Rishon LeZion',
);
