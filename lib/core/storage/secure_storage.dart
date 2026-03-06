import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserRole = 'user_role';
  static const _keyUserId = 'user_id';
  static const _keyStayLoggedIn = 'stay_logged_in';

  // --- Save ---
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String userId,
    bool stayLoggedIn = false,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyUserRole, value: role);
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyStayLoggedIn, value: stayLoggedIn.toString());
  }

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  // --- Read ---
  static Future<String?> getAccessToken() async =>
      await _storage.read(key: _keyAccessToken);

  static Future<String?> getRefreshToken() async =>
      await _storage.read(key: _keyRefreshToken);

  static Future<String?> getUserRole() async =>
      await _storage.read(key: _keyUserRole);

  static Future<String?> getUserId() async =>
      await _storage.read(key: _keyUserId);

  static Future<bool> getStayLoggedIn() async {
    final value = await _storage.read(key: _keyStayLoggedIn);
    return value == 'true';
  }

  // --- Delete (Logout) ---
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
