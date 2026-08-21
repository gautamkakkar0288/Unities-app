import 'dart:async';

import 'package:dio/dio.dart';

import '../errors/app_error.dart';
import '../logging/app_logger.dart';
import 'api_client.dart';

/// dio-backed [ApiClient].
///
/// Responsibilities kept here so no other layer has to think about them:
/// timeouts, one retry for idempotent reads on a transport hiccup, mapping
/// every failure to an [AppError], and reporting 401s once so the auth layer
/// can end the session.
class DioApiClient implements ApiClient {
  DioApiClient({
    required Dio dio,
    required AppLogger logger,
    this.onUnauthorized,
  })  : _dio = dio,
        _logger = logger;

  final Dio _dio;
  final AppLogger _logger;

  /// Invoked on any 401. The auth controller uses it to clear the session
  /// rather than leaving the user on a screen that will never load.
  final void Function()? onUnauthorized;

  @override
  Future<T> get<T>(
    String path, {
    required JsonDecoder<T> decode,
    Map<String, Object?>? query,
    Duration? timeout,
  }) {
    return _send<T>(
      method: 'GET',
      path: path,
      decode: decode,
      query: query,
      timeout: timeout,
      // Safe to repeat: no state changes on the server.
      retryOnTransportFailure: true,
    );
  }

  @override
  Future<T> post<T>(
    String path, {
    required JsonDecoder<T> decode,
    Object? body,
    Map<String, Object?>? query,
    bool formUrlEncoded = false,
    Duration? timeout,
  }) {
    return _send<T>(
      method: 'POST',
      path: path,
      decode: decode,
      body: body,
      query: query,
      timeout: timeout,
      contentType: formUrlEncoded
          ? Headers.formUrlEncodedContentType
          : Headers.jsonContentType,
    );
  }

  @override
  Future<T> put<T>(
    String path, {
    required JsonDecoder<T> decode,
    Object? body,
    Map<String, Object?>? query,
  }) =>
      _send<T>(
        method: 'PUT',
        path: path,
        decode: decode,
        body: body,
        query: query,
      );

  @override
  Future<T> patch<T>(
    String path, {
    required JsonDecoder<T> decode,
    Object? body,
    Map<String, Object?>? query,
  }) =>
      _send<T>(
        method: 'PATCH',
        path: path,
        decode: decode,
        body: body,
        query: query,
      );

  @override
  Future<T> delete<T>(
    String path, {
    required JsonDecoder<T> decode,
    Object? body,
    Map<String, Object?>? query,
  }) =>
      _send<T>(
        method: 'DELETE',
        path: path,
        decode: decode,
        body: body,
        query: query,
      );

  Future<T> _send<T>({
    required String method,
    required String path,
    required JsonDecoder<T> decode,
    Object? body,
    Map<String, Object?>? query,
    Duration? timeout,
    String? contentType,
    bool retryOnTransportFailure = false,
    int attempt = 1,
  }) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: query?.map(
          (key, value) => MapEntry<String, dynamic>(key, value),
        ),
        options: Options(
          method: method,
          contentType: contentType,
          receiveTimeout: timeout,
          sendTimeout: timeout,
        ),
      );
      return _decode(decode, response.data, path);
    } on DioException catch (exception, stackTrace) {
      final isTransport = _isTransportFailure(exception);
      if (isTransport && retryOnTransportFailure && attempt == 1) {
        _logger.warn('retrying after transport failure', data: {
          'method': method,
          'path': path,
        });
        return _send<T>(
          method: method,
          path: path,
          decode: decode,
          body: body,
          query: query,
          timeout: timeout,
          contentType: contentType,
          retryOnTransportFailure: false,
          attempt: 2,
        );
      }
      throw _mapDioException(exception, stackTrace, path);
    } on AppError {
      rethrow;
    } catch (error, stackTrace) {
      throw UnknownError(
        debugMessage: '$method $path failed: $error',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  T _decode<T>(JsonDecoder<T> decode, Object? data, String path) {
    try {
      return decode(data);
    } catch (error, stackTrace) {
      _logger.error(
        'failed to decode response',
        error: error,
        stackTrace: stackTrace,
        data: <String, Object?>{'path': path},
      );
      throw DecodingError(
        debugMessage: 'Could not decode response from $path',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  bool _isTransportFailure(DioException exception) {
    return switch (exception.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        true,
      _ => false,
    };
  }

  AppError _mapDioException(
    DioException exception,
    StackTrace stackTrace,
    String path,
  ) {
    final status = exception.response?.statusCode;
    final debug = '${exception.type.name} on $path (status $status)';

    if (status != null) {
      if (status == 401) {
        onUnauthorized?.call();
        return UnauthorizedError(debugMessage: debug, cause: exception);
      }
      if (status == 403) {
        return ForbiddenError(debugMessage: debug, cause: exception);
      }
      if (status == 404) {
        return NotFoundError(debugMessage: debug, cause: exception);
      }
      if (status == 400 || status == 422) {
        return ValidationError(
          summary: _serverMessage(exception.response?.data),
          debugMessage: debug,
          cause: exception,
        );
      }
      if (status >= 500) {
        return ServerError(
          statusCode: status,
          debugMessage: debug,
          cause: exception,
        );
      }
    }

    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        TimeoutError(
          debugMessage: debug,
          cause: exception,
          stackTrace: stackTrace,
        ),
      DioExceptionType.connectionError || DioExceptionType.badCertificate =>
        NetworkError(
          debugMessage: debug,
          cause: exception,
          stackTrace: stackTrace,
        ),
      DioExceptionType.cancel => UnknownError(
          debugMessage: 'Request to $path was cancelled',
          cause: exception,
        ),
      _ => UnknownError(
          debugMessage: debug,
          cause: exception,
          stackTrace: stackTrace,
        ),
    };
  }

  /// Only surfaces a server string when it is clearly a user-facing message
  /// field. Anything else stays in the logs.
  String? _serverMessage(Object? data) {
    if (data is Map) {
      final value = data['message'] ?? data['error'];
      if (value is String && value.isNotEmpty && value.length < 300) {
        return value;
      }
    }
    return null;
  }
}
