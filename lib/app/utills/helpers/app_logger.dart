import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    level: kReleaseMode ? Level.off : Level.trace,
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to display in the stack trace
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output line
      colors: true, // Colorful log messages in terminal
      printEmojis: true, // Print emojis for each log level
      dateTimeFormat: DateTimeFormat.dateAndTime, // Show timestamp
    ),
  );

  static void debug(dynamic message) => _logger.d(message);
  static void info(dynamic message) => _logger.i(message);
  static void warning(dynamic message) => _logger.w(message);
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  static void verbose(dynamic message) => _logger.t(message);
}
