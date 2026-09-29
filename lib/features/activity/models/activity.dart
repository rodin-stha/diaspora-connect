/// Something that happened on the user's account.
class Activity {
  final String id;
  final DateTime date;
  final bool isRead;
  final ActivityEvent event;

  const Activity({
    required this.id,
    required this.date,
    required this.event,
    this.isRead = false,
  });

  Activity copyWith({bool? isRead}) => Activity(
    id: id,
    date: date,
    event: event,
    isRead: isRead ?? this.isRead,
  );
}

/// What happened. Each kind carries only the data it needs, and a `switch`
/// over it must handle every kind (the compiler checks).
sealed class ActivityEvent {
  const ActivityEvent();
}

class IssueSubmitted extends ActivityEvent {
  final String reference;
  final String issueTitle;

  const IssueSubmitted({required this.reference, required this.issueTitle});
}

class MobileNumberUpdated extends ActivityEvent {
  /// Already masked by the server, e.g. "+972 5X-XXX-XXXX".
  final String maskedNumber;

  const MobileNumberUpdated({required this.maskedNumber});
}

class SignedIn extends ActivityEvent {
  const SignedIn();
}

class DocumentUploaded extends ActivityEvent {
  final String documentName;

  const DocumentUploaded({required this.documentName});
}

class ProfileUpdated extends ActivityEvent {
  const ProfileUpdated();
}
