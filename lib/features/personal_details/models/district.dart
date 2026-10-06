class District {
  final int id;
  final String name;

  const District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) =>
      District(id: (json['id']), name: json['name']);
}
