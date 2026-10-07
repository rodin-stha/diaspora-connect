/// A type of business to choose from on the work details form
/// (GET /employment-types).
class EmploymentType {
  final int id;
  final String name;

  /// Whether workers of this type may live at their workplace. When true,
  /// the form asks live-in or live-out and for the host.
  final bool allowsLiveIn;

  const EmploymentType({
    required this.id,
    required this.name,
    required this.allowsLiveIn,
  });

  factory EmploymentType.fromJson(Map<String, dynamic> json) => EmploymentType(
    id: json['id'] as int,
    name: json['name'] as String,
    allowsLiveIn: json['allow_live_in_status'] as bool? ?? false,
  );
}
