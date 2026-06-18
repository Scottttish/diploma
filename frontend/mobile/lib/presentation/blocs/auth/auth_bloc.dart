import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/auth_remote_datasource.dart';

part 'auth_event.dart';
part 'auth_state.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource _datasource;
  final FlutterSecureStorage _storage;

  AuthBloc({
    AuthRemoteDataSource? datasource,
    FlutterSecureStorage? storage,
  })  : _datasource = datasource ?? AuthRemoteDataSource(),
        _storage = storage ?? const FlutterSecureStorage(),
        super(const AuthInitial()) {
    on<AuthStatusChecked>(_onStatusChecked);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _storage.read(key: AppConstants.storageKeyAccessToken);
    if (token != null) {
      final workerId =
          await _storage.read(key: AppConstants.storageKeyWorkerId) ?? '';
      emit(AuthAuthenticated(workerId: workerId));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final tokens =
          await _datasource.login(event.email, event.password);
      await _storage.write(
        key: AppConstants.storageKeyAccessToken,
        value: tokens['access_token'],
      );
      await _storage.write(
        key: AppConstants.storageKeyRefreshToken,
        value: tokens['refresh_token'],
      );
      // Fetch worker profile to store name + id
      final me = await _datasource.getMe();
      final workerId = me['id'].toString();
      final workerName = me['full_name'] as String? ?? '';
      await _storage.write(
        key: AppConstants.storageKeyWorkerId,
        value: workerId,
      );
      await _storage.write(
        key: AppConstants.storageKeyWorkerName,
        value: workerName,
      );
      emit(AuthAuthenticated(workerId: workerId));
    } catch (e) {
      emit(AuthError(message: _friendlyError(e)));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _storage.deleteAll();
    emit(const AuthUnauthenticated());
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid email') || msg.contains('401')) {
      return 'Invalid email or password.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Cannot reach server. Check your network.';
    }
    return 'Login failed. Please try again.';
  }
}
