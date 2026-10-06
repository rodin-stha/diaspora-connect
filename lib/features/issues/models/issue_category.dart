/// What an issue is about ("Housing", "Employment"…). The list comes from
/// the API, so new categories need no app update. The form shows [name]
/// and sends [id].
class IssueCategory {
  final int id;
  final String name;

  const IssueCategory({required this.id, required this.name});

  factory IssueCategory.fromJson(Map<String, dynamic> json) => IssueCategory(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
  );

  @override
  String toString() => 'IssueCategory(id: $id, name: $name)';
}
