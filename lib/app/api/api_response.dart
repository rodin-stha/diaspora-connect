class ApiResponse<T> {
  final T data;

  const ApiResponse({required this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromData,
  ) => ApiResponse(data: fromData(json['data']));
}
