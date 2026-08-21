import '../../../app/config/app_config.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/cirqles_user.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import 'auth_js_client.dart';
import 'session_cookie_store.dart';

/// [AuthRepository] backed by the existing Auth.js credentials provider.
///
/// Sequence for sign-in, mirroring what the web client does in a browser:
/// 1. GET `/api/auth/csrf` — token plus cookie;
/// 2. POST `/api/auth/callback/credentials` — form-encoded;
/// 3. GET `/api/auth/session` — the authoritative user payload;
/// 4. persist the session cookie to the keystore.
///
/// Step 3 is not optional: the callback response says nothing about who signed
/// in, and inventing a user object from the request would be a lie.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthJsClient client,
    required SessionCookieStore cookieStore,
    required KeyValueStore preferences,
    required AppConfig config,
    required AppLogger logger,
  })  : _client = client,
        _cookieStore = cookieStore,
        _preferences = preferences,
        _config = config,
        _logger = logger;

  final AuthJsClient _client;
  final SessionCookieStore _cookieStore;
  final KeyValueStore _preferences;
  final AppConfig _config;
  final AppLogger _logger;

  @override
  Future<Result<AuthSession>> restoreSession() async {
    final hasStoredCookie = await _cookieStore.restore();
    if (!hasStoredCookie) {
      _logger.info('no stored session; starting signed out');
      return const Success<AuthSession>(AuthSessionSignedOut());
    }

    return guard<AuthSession>(() async {
      final user = await _client.fetchSession();
      if (user == null) {
        // The cookie existed but the server rejected it: expired or revoked.
        await _cookieStore.clear();
        _logger.info('stored session was no longer valid');
        return const AuthSessionSignedOut(
          reason: UnauthorizedError(debugMessage: 'stored session expired'),
        );
      }
      _logger.info('session restored');
      return AuthSessionActive(user);
    });
  }

  @override
  Future<Result<SessionUser>> signIn({
    required String email,
    required String password,
  }) {
    final normalisedEmail = email.trim().toLowerCase();
    return guard<SessionUser>(() async {
      final csrfToken = await _client.fetchCsrfToken();
      await _client.submitCredentials(
        email: normalisedEmail,
        password: password,
        csrfToken: csrfToken,
      );

      final user = await _client.fetchSession();
      if (user == null) {
        // Credentials were accepted but no session came back: a cookie
        // problem, not a password problem. Say so rather than blaming the
        // student's password.
        throw const UnknownError(
          debugMessage:
              'sign-in returned success but /api/auth/session had no user',
        );
      }

      await _cookieStore.persist();
      await _preferences.write(PreferenceKeys.lastSignInEmail, normalisedEmail);
      _logger.info('signed in');
      return user;
    });
  }

  @override
  Future<Result<SessionUser>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _logger.warn('sign-up attempted but no HTTP endpoint exists');
    return const Failure<SessionUser>(
      MissingBackendCapabilityError(
        capability: MissingCapabilities.signUp,
        detail: MissingCapabilities.signUpDetail,
      ),
    );
  }

  @override
  Future<Result<void>> signOut() async {
    // Local state is cleared whatever the server says. A failed sign-out that
    // leaves a live cookie on the device is the worse outcome.
    final result = await guard<void>(() async {
      final csrfToken = await _client.fetchCsrfToken();
      await _client.submitSignOut(csrfToken: csrfToken);
    });
    await _cookieStore.clear();
    if (!result.isSuccess) {
      _logger.warn('server sign-out failed; cleared local session anyway');
    }
    return const Success<void>(null);
  }

  @override
  Uri get webSignUpUrl => _config.apiBaseUri.replace(path: '/sign-up');

  @override
  Uri get webVerifyEmailUrl => _config.apiBaseUri.replace(path: '/verify-email');
}
