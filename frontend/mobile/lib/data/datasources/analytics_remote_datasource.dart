import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

final class AnalyticsRemoteDataSource {
  final Dio _dio;

  AnalyticsRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  Future<Map<String, dynamic>> fetchMyAnalytics() async {
    final response = await _dio.get<Map<String, dynamic>>('/analytics/me');
    return response.data!;
  }
}
