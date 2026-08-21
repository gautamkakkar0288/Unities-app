import 'dart:developer' as developer;

import '../../app/config/app_config.dart';

enum LogLevel { debug, info, warn, error }

/// Structured development logging.
///
/// Rules enforced here rather than trusted to call sites:
/// * nothing is emitted below [LogLevel.warn] unless verbose logging is on;
/// * keys that commonly carry credentials are redacted, so a future call site
///   cannot leak a password or session cookie by passing the wrong map.
class AppLogger {
  const AppLogger(this.scope, {required this.verbose});

  final String scope;
  final bool verbose;

  factory AppLogger.forConfig(String scope, AppConfig config) =>
      AppLogger(scope, verbose: config.verboseLogging);

  AppLogger child(String childScope) =>
      AppLogger('$scope.$childScope', verbose: verbose);

  static const Set<String> _redactedKeys = <String>{
    'password',
    'passwordhash',
    'password_hash',
    'token',
    'csrftoken',
    'csrf_token',
    'authorization',
    'cookie',
    'set-cookie',
    'sessiontoken',
    'session_token',
    'email',
    'secret',
  };

  void debug(String message, {Map<String, Object?>? data}) =>
      _log(LogLevel.debug, message, data: data);

  void info(String message, {Map<String, Object?>? data}) =>
      _log(LogLevel.info, message, data: data);

  void warn(String message, {Map<String, Object?>? data}) =>
      _log(LogLevel.warn, message, data: data);

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) =>
      _log(
        LogLevel.error,
        message,
        data: data,
        error: error,
        stackTrace: stackTrace,
      );

  void _log(
    LogLevel level,
    String message, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final isDiagnostic = level == LogLevel.debug || level == LogLevel.info;
    if (isDiagnostic && !verbose) return;

    final payload = data == null || data.isEmpty ? '' : ' ${redact(data)}';
    developer.log(
      '[${level.name.toUpperCase()}] $message$payload',
      name: 'cirqles.$scope',
      error: error,
      stackTrace: stackTrace,
      level: switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warn => 900,
        LogLevel.error => 1000,
      },
    );
  }

  /// Replaces sensitive values with a marker. Exposed for tests.
  static Map<String, Object?> redact(Map<String, Object?> data) {
    return <String, Object?>{
      for (final entry in data.entries)
        entry.key: _redactedKeys.contains(entry.key.toLowerCase())
            ? '<redacted>'
            : entry.value,
    };
  }
}
