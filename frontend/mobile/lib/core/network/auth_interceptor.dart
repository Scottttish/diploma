import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Attaches the Bearer token to every outgoing request.
/// If a 401 is received, we attempt one silent refresh before giving up.
/// The lock pattern prevents multiple simultaneous refreshes when parallel
/// requests all fail at the same time — only the first one wins the race.
final class AuthInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage storage;

  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor({required this.dio, required this.storage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.read(key: AppConstants.storageKeyAccessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final requestOptions = err.requestOptions;

    if (_isRefreshing) {
      _pendingRequests.add(requestOptions);
      return;
    }

    _isRefreshing = true;

    try {
      final newToken = await _refreshToken();
      await storage.write(
        key: AppConstants.storageKeyAccessToken,
        value: newToken,
      );

      // Replay the original request and any requests that queued up while
      // the refresh was in flight.
      final response = await _retry(requestOptions, newToken);
      for (final pending in _pendingRequests) {
        _retry(pending, newToken);
      }
      _pendingRequests.clear();

      handler.resolve(response);
    } catch (_) {
      // Refresh failed — clear credentials and let the UI redirect to login.
      await storage.deleteAll();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<String> _refreshToken() async {
    final refreshToken =
        await storage.read(key: AppConstants.storageKeyRefreshToken);
    final response = await Dio().post<Map<String, dynamic>>(
      '${AppConstants.baseApiUrl}/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    final newAccess = response.data!['access_token'] as String;
    final newRefresh = response.data!['refresh_token'] as String?;
    if (newRefresh != null) {
      await storage.write(
          key: AppConstants.storageKeyRefreshToken, value: newRefresh,);
    }
    return newAccess;
  }

  Future<Response<dynamic>> _retry(
      RequestOptions options, String newToken) async {
    options.headers['Authorization'] = 'Bearer $newToken';
    return dio.fetch(options);
  }
}
