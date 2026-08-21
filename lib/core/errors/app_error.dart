/// The single error currency of the app.
///
/// Every layer below the UI converts whatever it caught — a `DioException`, a
/// `FormatException`, a missing field — into one of these. Widgets switch on
/// the type; they never inspect a status code or a transport exception.
sealed class AppError implements Exception {
  const AppError({this.debugMessage, this.cause, this.stackTrace});

  /// Developer-facing detail. Never rendered to a student: use
  /// `userFacingMessage` from `error_messages.dart`.
  final String? debugMessage;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType(${debugMessage ?? ''})';
}

/// No usable connection, DNS failure, connection refused.
final class NetworkError extends AppError {
  const NetworkError({super.debugMessage, super.cause, super.stackTrace});
}

/// Connect/send/receive deadline exceeded.
final class TimeoutError extends AppError {
  const TimeoutError({super.debugMessage, super.cause, super.stackTrace});
}

/// 401. The session is absent or expired; the auth layer signs the user out.
final class UnauthorizedError extends AppError {
  const UnauthorizedError({super.debugMessage, super.cause, super.stackTrace});
}

/// 403. Authenticated but not permitted — role or membership state.
final class ForbiddenError extends AppError {
  const ForbiddenError({super.debugMessage, super.cause, super.stackTrace});
}

/// 404.
final class NotFoundError extends AppError {
  const NotFoundError({super.debugMessage, super.cause, super.stackTrace});
}

/// 400/422, or a client-side check that mirrors a backend Zod schema.
///
/// [fieldErrors] is keyed by form field so a screen can attach messages to
/// inputs instead of showing one generic banner.
final class ValidationError extends AppError {
  const ValidationError({
    this.fieldErrors = const <String, String>{},
    this.summary,
    super.debugMessage,
    super.cause,
    super.stackTrace,
  });

  final Map<String, String> fieldErrors;

  /// Server-authored message safe to show as-is (for example the university
  /// email rule from the Cirqles sign-up action).
  final String? summary;
}

/// 5xx.
final class ServerError extends AppError {
  const ServerError({
    this.statusCode,
    super.debugMessage,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;
}

/// The response arrived but did not match the expected shape. Almost always a
/// contract drift between this client and the Unities backend.
final class DecodingError extends AppError {
  const DecodingError({super.debugMessage, super.cause, super.stackTrace});
}

/// The backend does not expose this capability over HTTP yet.
///
/// This exists so the app can be honest instead of pretending. Screens render
/// a “not available yet” state naming the capability, rather than an empty
/// list that looks like the student simply has no events.
final class MissingBackendCapabilityError extends AppError {
  const MissingBackendCapabilityError({
    required this.capability,
    required this.detail,
    super.debugMessage,
  });

  /// Short label, for example `events.list`.
  final String capability;

  /// What is missing on the server and what would unblock it.
  final String detail;
}

final class UnknownError extends AppError {
  const UnknownError({super.debugMessage, super.cause, super.stackTrace});
}
