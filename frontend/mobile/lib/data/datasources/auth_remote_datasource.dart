import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

final class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  Future<Map<String, String>> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data!;
    return {
      'access_token': data['access_token'] as String,
      'refresh_token': data['refresh_token'] as String,
    };
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return response.data!;
  }

  Future<void> changePassword(String current, String newPassword) async {
    await _dio.patch<void>(
      '/users/me/password',
      data: {'current_password': current, 'new_password': newPassword},
    );
  }
}
