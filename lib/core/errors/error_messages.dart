import 'app_error.dart';

/// Maps an [AppError] to copy a student can act on.
///
/// Kept out of the error classes themselves so wording stays reviewable in one
/// place and can be localised later without touching the data layer. No stack
/// trace, status code or backend detail ever reaches this output.
String userFacingMessage(AppError error) {
  return switch (error) {
    NetworkError() =>
      'No connection. Check your network and try again.',
    TimeoutError() =>
      'That took too long. Your connection looks slow — try again.',
    UnauthorizedError() => 'Your session ended. Please sign in again.',
    ForbiddenError() => 'You do not have access to this.',
    NotFoundError() => 'We could not find that.',
    ValidationError(:final summary) =>
      summary ?? 'Please check the highlighted fields and try again.',
    ServerError() => 'Cirqles is having trouble right now. Try again shortly.',
    DecodingError() =>
      'We could not read that response. The app may need an update.',
    MissingBackendCapabilityError(:final capability) =>
      'This part of Cirqles is not available in the app yet ($capability).',
    UnknownError() => 'Something went wrong. Please try again.',
  };
}

/// Short title for an error state header.
String userFacingTitle(AppError error) {
  return switch (error) {
    NetworkError() || TimeoutError() => 'You are offline',
    UnauthorizedError() => 'Session ended',
    ForbiddenError() => 'No access',
    NotFoundError() => 'Not found',
    ValidationError() => 'Check your details',
    ServerError() => 'Something broke on our side',
    DecodingError() => 'Unexpected response',
    MissingBackendCapabilityError() => 'Coming soon',
    UnknownError() => 'Something went wrong',
  };
}

/// Whether offering “Try again” makes sense. Retrying a 403 or a missing
/// endpoint just teaches students that buttons lie.
bool isRetryable(AppError error) {
  return switch (error) {
    NetworkError() || TimeoutError() || ServerError() || UnknownError() => true,
    UnauthorizedError() ||
    ForbiddenError() ||
    NotFoundError() ||
    ValidationError() ||
    DecodingError() ||
    MissingBackendCapabilityError() =>
      false,
  };
}
