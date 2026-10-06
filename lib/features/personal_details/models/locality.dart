class Locality {
  final int id;
  final String name;

  const Locality({required this.id, required this.name});

  factory Locality.fromJson(Map<String, dynamic> json) => Locality(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
  );

  @override
  String toString() => 'Authority(id: $id, name: $name)';
}
