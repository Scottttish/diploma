/// Base class so catch blocks can handle any app-level exception uniformly.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// A task lifecycle move that violates the permitted transition graph.
final class StateTransitionException extends AppException {
  const StateTransitionException(super.message);
}

/// Any 4xx/5xx the backend returns that we didn't expect.
final class ApiException extends AppException {
  final int statusCode;
  const ApiException(super.message, {required this.statusCode});
}

/// The session expired and the silent token refresh also failed.
final class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('Session expired. Please log in again.');
}

/// Device is offline or the server is unreachable.
final class NetworkException extends AppException {
  const NetworkException(super.message);
}
