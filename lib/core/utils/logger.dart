import 'package:flutter/foundation.dart';

/// Simple logger that only prints in debug mode.
class AppLogger {
  AppLogger._();

  static void d(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
      if (error != null) debugPrint('[ERROR] $error');
      if (stackTrace != null) debugPrint('[TRACE] $stackTrace');
    }
  }

  static void i(String message) {
    if (kDebugMode) debugPrint('[INFO ] $message');
  }

  static void w(String message) {
    if (kDebugMode) debugPrint('[WARN ] $message');
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('        $error');
    if (stackTrace != null) debugPrint('        $stackTrace');
  }
}
