import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Vlogger {
  Vlogger._();

  static final Logger _logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  static void debug(String message) {
    _logger.d(message);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void trace(String message) {
    _logger.t(message);
  }
}
