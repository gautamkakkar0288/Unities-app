import '../../../core/utils/result.dart';
import '../../../shared/models/cirqles_user.dart';
import 'auth_session.dart';

/// Authentication contract used by the presentation layer.
///
/// The implementation talks to Auth.js over cookies, but nothing above this
/// interface knows that — which is what makes a future token-based mobile
/// endpoint a data-layer change rather than an app-wide one.
abstract interface class AuthRepository {
  /// Restores a persisted session at launch and confirms it with the server.
  ///
  /// Returns a signed-out state (not a failure) when there is no valid session;
  /// a [Failure] means we could not reach the server to find out.
  Future<Result<AuthSession>> restoreSession();

  /// Credentials sign-in against the existing Auth.js provider.
  Future<Result<SessionUser>> signIn({
    required String email,
    required String password,
  });

  /// Registration.
  ///
  /// Always fails with `MissingBackendCapabilityError` today: Cirqles registers
  /// students through the `registerUser` **server action**, which has no HTTP
  /// contract a mobile client can call. The method exists so the flow has a
  /// typed seam, and so the gap is visible in code review rather than hidden
  /// behind a fake endpoint. Use [webSignUpUrl] for the interim hand-off.
  Future<Result<SessionUser>> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Clears the server session and the locally persisted cookie.
  Future<Result<void>> signOut();

  /// Web pages the app hands off to for flows with no mobile contract yet.
  Uri get webSignUpUrl;
  Uri get webVerifyEmailUrl;
}
