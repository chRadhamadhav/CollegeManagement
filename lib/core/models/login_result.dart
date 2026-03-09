/// Encapsulates the result of a login attempt.
class LoginResult {
  final bool success;
  final String? role;
  final String? message;

  LoginResult({required this.success, this.role, this.message});

  factory LoginResult.success(String role) {
    return LoginResult(success: true, role: role);
  }

  factory LoginResult.failure(String message) {
    return LoginResult(success: false, message: message);
  }
}
