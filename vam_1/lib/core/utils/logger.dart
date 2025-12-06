import 'package:flutter/foundation.dart';

/// 로깅 유틸리티
class Logger {
  Logger._();

  static const String _tag = '[VAM]';

  static void d(String message, [String? tag]) {
    if (kDebugMode) {
      print('$_tag[${tag ?? 'DEBUG'}] $message');
    }
  }

  static void i(String message, [String? tag]) {
    if (kDebugMode) {
      print('$_tag[${tag ?? 'INFO'}] $message');
    }
  }

  static void w(String message, [String? tag]) {
    if (kDebugMode) {
      print('$_tag[${tag ?? 'WARN'}] ⚠️ $message');
    }
  }

  static void e(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$_tag[${tag ?? 'ERROR'}] ❌ $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  static void game(String message) {
    d(message, 'GAME');
  }

  static void combat(String message) {
    d(message, 'COMBAT');
  }

  static void spawn(String message) {
    d(message, 'SPAWN');
  }

  static void ui(String message) {
    d(message, 'UI');
  }
}
