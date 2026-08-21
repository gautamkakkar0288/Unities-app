import 'package:dio/dio.dart';

import '../logging/app_logger.dart';

/// Request/response logging for development.
///
/// Logs shape and timing, never content: no request bodies (they carry
/// passwords on the sign-in call) and no `cookie`/`set-cookie` headers (they
/// carry the session). Silent unless verbose logging is enabled.
class NetworkLoggingInterceptor extends Interceptor {
  NetworkLoggingInterceptor(this._logger);

  final AppLogger _logger;
  static const String _startKey = 'cirqles.startedAt';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    _logger.debug('request', data: <String, Object?>{
      'method': options.method,
      'path': options.path,
      'query': options.queryParameters.keys.toList(),
    });
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug('response', data: <String, Object?>{
      'method': response.requestOptions.method,
      'path': response.requestOptions.path,
      'status': response.statusCode,
      'ms': _elapsed(response.requestOptions),
    });
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warn('request failed', data: <String, Object?>{
      'method': err.requestOptions.method,
      'path': err.requestOptions.path,
      'status': err.response?.statusCode,
      'type': err.type.name,
      'ms': _elapsed(err.requestOptions),
    });
    handler.next(err);
  }

  int? _elapsed(RequestOptions options) {
    final started = options.extra[_startKey];
    if (started is! int) return null;
    return DateTime.now().millisecondsSinceEpoch - started;
  }
}
