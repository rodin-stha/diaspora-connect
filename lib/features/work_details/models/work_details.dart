/// The sector the user works in. Each type has its own details section on
/// the form (only caregiving is designed so far).
enum BusinessType { caregiving, agriculture, entrepreneur, employee }

/// Whether a caregiver lives in the employer's home.
enum CareArrangement { liveIn, liveOut }

/// Work details and permit (Profile → Work details & permit, and onboarding
/// step 3).
class WorkDetails {
  final BusinessType? businessType;

  /// Work permit (Rishayon Avoda) scan, as a file name; null when not
  /// uploaded yet.
  final String? workPermitLetter;

  // Caregiving only: null/empty for other business types.
  final CareArrangement? careArrangement;
  final String hostFamily;

  const WorkDetails({
    this.businessType,
    this.workPermitLetter,
    this.careArrangement,
    this.hostFamily = '',
  });
}
