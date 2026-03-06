import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/storage/secure_storage.dart';

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
  /// Returns the user's role if credentials are valid, otherwise returns null.
  /// Supported Roles: 'admin', 'student', 'hod', 'staff'.
  Future<String?> login(
    String email,
    String password, {
    bool stayLoggedIn = false,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Save tokens and user details securely
        await SecureStorage.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          role: data['role'],
          userId: data['user_id'],
          stayLoggedIn: stayLoggedIn,
        );

        return data['role'] as String;
      }
    } catch (e) {
      // Dio intercepts 401s and other API errors here
      // Returning null means login failed (wrong credentials or deactivated)
      return null;
    }
    return null;
  }

  /// Logs out the user by pinging the backend and then clearing all local secure storage.
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Even if the network request fails (e.g. no internet, or token already expired),
      // we still want to proceed with clearing local storage to force the user out.
    } finally {
      await SecureStorage.clearAll();
    }
  }
}
