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

  /// From one entry of `GET /activity-logs`. The API has no read status,
  /// so [isRead] is set afterwards by the provider.
  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json['id'].toString(),
    // The API sends UTC; toLocal() shows it in the phone's time zone.
    date: DateTime.parse(json['created_at'] as String).toLocal(),
    event: ActivityEvent.fromJson(json),
  );
}

/// What happened. Each kind carries only the data it needs, and a `switch`
/// over it must handle every kind (the compiler checks).
sealed class ActivityEvent {
  const ActivityEvent();

  /// Picks the kind from the log's `log_name` and `event` (a Laravel
  /// activity log). Anything the app doesn't know yet becomes [OtherActivity]
  /// with the server's text, so new kinds on the server can't break the feed.
  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    final description = json['description'] as String? ?? '';
    final subjectType = json['subject']?['type'] as String?;
    // An empty list (not an object) when nothing changed, hence the check.
    final changes = json['changes'] is Map ? json['changes'] as Map : null;

    switch ((json['log_name'], json['event'])) {
      case ('auth', 'login'):
        return const SignedIn();
      case ('auth', 'registered'):
        return const AccountCreated();
      case ('profile', 'created' || 'updated')
          when subjectType == 'PersonalDetail':
        return const PersonalDetailsSaved();
      case ('user', 'updated'):
        final newPhone = changes?['attributes']?['phone'] as String?;
        final oldPhone = changes?['old']?['phone'] as String?;
        if (newPhone != null && newPhone != oldPhone) {
          return MobileNumberUpdated(maskedNumber: _maskPhone(newPhone));
        }
        return OtherActivity(description: description);
      default:
        return OtherActivity(description: description);
    }
  }

  /// "+972521234567" → "+9725XXXXXXXX": enough to recognise, not to read
  /// the whole number off someone's screen.
  static String _maskPhone(String phone) => phone.length <= 5
      ? phone
      : phone.substring(0, 5) + 'X' * (phone.length - 5);
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

class AccountCreated extends ActivityEvent {
  const AccountCreated();
}

class PersonalDetailsSaved extends ActivityEvent {
  const PersonalDetailsSaved();
}

/// A kind the app doesn't have its own text for; shows the server's
/// [description] (English only).
class OtherActivity extends ActivityEvent {
  final String description;

  const OtherActivity({required this.description});
}
