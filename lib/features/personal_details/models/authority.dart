/// A local authority (city, local council or regional council), as the API
/// lists them for a district. The form shows [name] and saves [id].
class Authority {
  final int id;
  final String name;

  const Authority({required this.id, required this.name});

  factory Authority.fromJson(Map<String, dynamic> json) => Authority(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
  );

  @override
  String toString() => 'Authority(id: $id, name: $name)';
}
