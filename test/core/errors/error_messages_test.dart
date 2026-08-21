import 'package:cirqles/core/errors/app_error.dart';
import 'package:cirqles/core/errors/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';

/// The contract this file defends: a student sees a sentence they can act on,
/// and never a stack trace, a status code or an internal message.
void main() {
  const debugText = 'SocketException: connection reset by peer at 0x7f';

  final errors = <AppError>[
    const NetworkError(debugMessage: debugText),
    const TimeoutError(debugMessage: debugText),
    const UnauthorizedError(debugMessage: debugText),
    const ForbiddenError(debugMessage: debugText),
    const NotFoundError(debugMessage: debugText),
    const ServerError(statusCode: 500, debugMessage: debugText),
    const DecodingError(debugMessage: debugText),
    const MissingBackendCapabilityError(
      capability: 'GET /api/events',
      detail: 'Events are rendered on the server; no JSON route exists.',
    ),
    const UnknownError(debugMessage: debugText),
  ];

  test('every error has a human title and message', () {
    for (final error in errors) {
      expect(userFacingTitle(error), isNotEmpty, reason: '$error');
      expect(userFacingMessage(error), isNotEmpty, reason: '$error');
    }
  });

  test('internal detail never reaches the user-facing copy', () {
    for (final error in errors) {
      expect(userFacingMessage(error), isNot(contains(debugText)));
      expect(userFacingMessage(error), isNot(contains('Exception')));
      expect(userFacingTitle(error), isNot(contains(debugText)));
    }
  });

  test('only errors that a retry could fix are retryable', () {
    expect(isRetryable(const NetworkError()), isTrue);
    expect(isRetryable(const TimeoutError()), isTrue);
    expect(isRetryable(const UnauthorizedError()), isFalse);
    expect(isRetryable(const ForbiddenError()), isFalse);
    expect(isRetryable(const NotFoundError()), isFalse);
    expect(
      isRetryable(
        const MissingBackendCapabilityError(
          capability: 'GET /api/events',
          detail: 'Not implemented yet.',
        ),
      ),
      isFalse,
    );
  });
}
