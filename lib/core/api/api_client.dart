import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    var baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api/v1';
    if (!baseUrl.endsWith('/')) {
      baseUrl = '$baseUrl/';
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(_AuthInterceptor(dio));
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Exclude /auth/login and /auth/refresh from requiring access tokens
    if (!options.path.contains('/auth/login/') &&
        !options.path.contains('/auth/refresh/')) {
      final token = await SecureStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/login/') &&
        !err.requestOptions.path.contains('/auth/refresh/')) {
      // Token is invalid/expired. Try to refresh it.
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final refreshToken = await SecureStorage.getRefreshToken();
          if (refreshToken != null) {
            // Making a direct request bypassing interceptors to avoid loops
            final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
            final response = await refreshDio.post(
              'auth/refresh/',
              data: {'refresh_token': refreshToken},
            );

            if (response.statusCode == 200) {
              final newAccessToken = response.data['access_token'];
              final newRefreshToken = response.data['refresh_token'];

              // Save new tokens
              await SecureStorage.saveAccessToken(newAccessToken);
              if (newRefreshToken != null) {
                // If backend rotated refresh token
                await SecureStorage.saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                  role:
                      response.data['role'] ??
                      await SecureStorage.getUserRole() ??
                      '',
                  userId:
                      response.data['user_id'] ??
                      await SecureStorage.getUserId() ??
                      '',
                );
              }

              // Retry the original request
              err.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final retryResponse = await _dio.fetch(err.requestOptions);
              _isRefreshing = false;
              return handler.resolve(retryResponse);
            }
          }
        } catch (e) {
          // Refresh failed
        } finally {
          _isRefreshing = false;
        }

        // If we reach here, refresh failed or no refresh token.
        await SecureStorage.clearAll();
        // TODO: Emit an event to navigate to LoginScreen
      }
    }

    // Pass the error down to the service layer if we couldn't handle it
    return super.onError(err, handler);
  }
}
