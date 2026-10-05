class RegisterResponse {
  final int expiresIn; // seconds

  const RegisterResponse({required this.expiresIn});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(expiresIn: (json['expires_in'] as num).toInt());
}
