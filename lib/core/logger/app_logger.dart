import 'package:flutter/foundation.dart';

/// Centralized logger for the application.
///
/// Follows engineering standards to avoid direct prints and provide
/// structured logging across different environments.
class AppLogger {
  static void debug(String message) {
    if (kDebugMode) {
      _log('DEBUG', message);
    }
  }

  static void info(String message) {
    _log('INFO', message);
  }

  static void warn(String message) {
    _log('WARN', message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('ERROR', '$message ${error != null ? ': $error' : ''}');
    if (stackTrace != null && kDebugMode) {
      debugPrint(stackTrace.toString());
    }
  }

  static void _log(String level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [$level] $message');
  }
}
