import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_response.dart';
import '../../../app/api/dio_provider.dart';
import '../models/register.dart';
import '../models/verify_otp_response.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(dioProvider)),
);

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);
  Future<RegisterResponse> register(String phone) async {
    final response = await apiCall(
      () => _dio.post<Map<String, dynamic>>(
        '/register',
        data: {'phone': normalizePhone(phone)},
      ),
    );
    return ApiResponse.fromJson(
      response.data!,
      (data) => RegisterResponse.fromJson(data as Map<String, dynamic>),
    ).data;
  }

  Future<VerifyOtpResponse> verifyCode(String phone, String code) async {
    final res = await apiCall(
      () => _dio.post<Map<String, dynamic>>(
        '/register/verify-otp',
        data: {'phone': normalizePhone(phone), 'otp': code},
      ),
    );

    return ApiResponse.fromJson(
      res.data!,
      (data) => VerifyOtpResponse.fromJson(data as Map<String, dynamic>),
    ).data;
  }
}

/// Turns what the user typed ("+972 052-123 4567") into the international
/// format APIs expect ("+972521234567"): no spaces or dashes, and no
/// leading 0 after the country code.
String normalizePhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  return digits.replaceFirstMapped(
    RegExp(r'^(\+\d{3})0'),
    (match) => match[1]!,
  );
}
