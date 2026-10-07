/// Whether a worker lives at their workplace (the employer's home, a farm…).
enum CareArrangement {
  liveIn,
  liveOut;

  /// The `live_in_situation` value the API uses.
  String get apiValue => switch (this) {
    CareArrangement.liveIn => 'live_in',
    CareArrangement.liveOut => 'live_out',
  };
}

/// Work details and permit (Profile → Work details & permit, and onboarding
/// step 3).
class WorkDetails {
  /// An [EmploymentType] id; null until chosen.
  final int? employmentTypeId;

  /// Work permit (Rishayon Avoda) scan, as a file name; null when not
  /// uploaded yet.
  final String? workPermitLetter;

  /// A permit photo picked on this device that isn't uploaded yet (local
  /// path). Sent as a file with the next save.
  final String? workPermitFile;

  // Only for types that allow live-in: null/empty for the others.
  final CareArrangement? careArrangement;
  final String hostFamily;

  const WorkDetails({
    this.employmentTypeId,
    this.workPermitLetter,
    this.workPermitFile,
    this.careArrangement,
    this.hostFamily = '',
  });

  /// The text fields of the save request. The permit is added as a file by
  /// the repository. Unset fields are null, so they can be left out.
  Map<String, dynamic> toJson() => {
    'employment_type_id': employmentTypeId,
    'employer_name': hostFamily.isEmpty ? null : hostFamily,
    'live_in_situation': careArrangement?.apiValue,
  };
}
