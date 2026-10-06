import 'user.dart';

class VerifyOtpResponse {
  final String token;
  final bool isNewUser;
  final User user;

  const VerifyOtpResponse({
    required this.token,
    required this.isNewUser,
    required this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResponse(
        token: json['token'],
        isNewUser: json['is_new_user'],
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );
}
