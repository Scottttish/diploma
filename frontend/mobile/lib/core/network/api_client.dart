import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import 'auth_interceptor.dart';

/// Singleton Dio instance shared across all data sources.
/// The auth interceptor is attached here so every request automatically
/// carries the JWT without any feature code needing to think about it.
final class ApiClient {
  ApiClient._();

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _build();
    return _instance!;
  }

  static Dio _build() {
    const storage = FlutterSecureStorage();

    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseApiUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(dio: dio, storage: storage));
    dio.interceptors.add(_errorInterceptor());

    return dio;
  }

  /// Converts Dio's own exception types into our sealed AppException hierarchy
  /// so higher layers never import Dio directly.
  static Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) {
        AppException mapped;

        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          mapped = NetworkException(e.message ?? 'Connection failed.');
        } else if (e.response?.statusCode == 401) {
          mapped = const UnauthorizedException();
        } else {
          final code = e.response?.statusCode ?? 0;
          final msg = e.response?.data?['detail'] as String? ??
              e.message ??
              'Unexpected server error.';
          mapped = ApiException(msg, statusCode: code);
        }

        handler.reject(
          DioException(
            requestOptions: e.requestOptions,
            error: mapped,
            message: mapped.message,
          ),
        );
      },
    );
  }
}
