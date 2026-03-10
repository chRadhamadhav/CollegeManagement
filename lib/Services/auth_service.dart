import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../core/logger/app_logger.dart';
import '../core/models/login_result.dart';

/// Authentication service connecting to the FastAPI backend.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  final Dio _dio = ApiClient().dio;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  /// Authenticates a user with the backend using [email] and [password].
  ///
  /// Returns [LoginResult] indicating success or failure with a message.
  Future<LoginResult> login(
    String email,
    String password, {
    bool stayLoggedIn = false,
  }) async {
    try {
      final response = await _dio.post(
        'auth/login/',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        await SecureStorage.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          role: data['role'],
          userId: data['user_id'],
          stayLoggedIn: stayLoggedIn,
        );

        AppLogger.info('Login successful for $email');
        return LoginResult.success(data['role'] as String);
      }
      return LoginResult.failure('Unexpected response from server');
    } catch (e) {
      if (e is DioException) {
        AppLogger.error('Login failed for $email', e);
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          return LoginResult.failure(
            'Network error: Please check your internet connection',
          );
        }

        if (e.response?.statusCode == 401) {
          return LoginResult.failure('Invalid credentials. Please try again.');
        }

        if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
          return LoginResult.failure('Server error. Please try again later.');
        }
      }
      AppLogger.error('Unexpected login error', e);
      return LoginResult.failure('An unexpected error occurred');
    }
  }

  /// Logs out the user by pinging the backend and then clearing all local secure storage.
  Future<void> logout() async {
    try {
      await _dio.post('auth/logout/');
    } catch (e) {
      // Even if the network request fails (e.g. no internet, or token already expired),
      // we still want to proceed with clearing local storage to force the user out.
    } finally {
      await SecureStorage.clearAll();
    }
  }
}
