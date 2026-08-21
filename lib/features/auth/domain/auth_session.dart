import '../../../core/errors/app_error.dart';
import '../../../shared/models/cirqles_user.dart';

/// The app's session state machine.
///
/// Three states, not a nullable user plus a boolean: the launch sequence has to
/// distinguish “we have not checked yet” from “checked, signed out”, or the
/// router flashes the sign-in screen at every cold start.
sealed class AuthSession {
  const AuthSession();

  bool get isAuthenticated => this is AuthSessionActive;

  SessionUser? get user => switch (this) {
        AuthSessionActive(:final user) => user,
        _ => null,
      };
}

/// Restoring the persisted session. The splash screen owns this state.
final class AuthSessionUnknown extends AuthSession {
  const AuthSessionUnknown();
}

/// No valid session.
///
/// [reason] is set when the student was signed *out* rather than never signed
/// in — an expired cookie, or a 401 mid-session — so the sign-in screen can
/// explain why they are looking at it.
final class AuthSessionSignedOut extends AuthSession {
  const AuthSessionSignedOut({this.reason});

  final AppError? reason;
}

final class AuthSessionActive extends AuthSession {
  const AuthSessionActive(this.user);

  @override
  final SessionUser user;
}
