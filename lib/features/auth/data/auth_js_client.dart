import '../../../core/errors/app_error.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../shared/models/cirqles_user.dart';
import '../../../shared/models/json.dart';

/// Typed client for the Auth.js HTTP routes exposed by the Cirqles backend.
///
/// This is the *only* real API surface the backend offers today
/// (`app/api/auth/[...nextauth]/route.ts`), so it is modelled precisely rather
/// than generically. Auth.js expects form-encoded bodies, a CSRF token paired
/// with its cookie, and `json=true` to answer with JSON instead of a redirect.
class AuthJsClient {
  AuthJsClient({required ApiClient api, required AppLogger logger})
      : _api = api,
        _logger = logger;

  final ApiClient _api;
  final AppLogger _logger;

  /// Fetches a CSRF token and, as a side effect, the matching CSRF cookie.
  /// Auth.js rejects a credentials POST unless both are present.
  Future<String> fetchCsrfToken() async {
    final json = await _api.get<Map<String, Object?>>(
      AuthPaths.csrf,
      decode: Decoders.jsonObject,
    );
    final token = json['csrfToken'];
    if (token is! String || token.isEmpty) {
      throw const DecodingError(
        debugMessage: 'csrf response did not contain csrfToken',
      );
    }
    return token;
  }

  /// Reads the current session.
  ///
  /// Auth.js answers `{}` with status 200 when there is no session, so an empty
  /// object means signed out — not an error.
  Future<SessionUser?> fetchSession() async {
    final json = await _api.get<Map<String, Object?>>(
      AuthPaths.session,
      decode: Decoders.jsonObject,
    );
    final user = Json.asMapOrNull(json['user']);
    if (user == null || user['id'] == null) {
      _logger.debug('no active session');
      return null;
    }
    return SessionUser.fromJson(user);
  }

  /// Posts credentials to the Auth.js callback.
  ///
  /// Auth.js returns 200 with a `url` field even when the credentials are
  /// wrong; failure is signalled by an `error` query parameter on that URL.
  /// That quirk is handled here so the rest of the app sees a normal
  /// [ValidationError].
  Future<void> submitCredentials({
    required String email,
    required String password,
    required String csrfToken,
  }) async {
    final json = await _api.post<Map<String, Object?>>(
      AuthPaths.signInCredentials,
      formUrlEncoded: true,
      body: <String, String>{
        'csrfToken': csrfToken,
        'email': email,
        'password': password,
        'json': 'true',
        'redirect': 'false',
      },
      decode: Decoders.jsonObject,
    );

    final url = json['url'];
    if (url is String && url.contains('error=')) {
      final code = Uri.tryParse(url)?.queryParameters['error'];
      _logger.warn('credentials rejected', data: <String, Object?>{
        'code': code,
      });
      throw ValidationError(
        // Auth.js deliberately does not say which field was wrong, and neither
        // do we: distinguishing them tells an attacker which emails exist.
        summary: 'That email and password combination did not work.',
        fieldErrors: const <String, String>{
          'password': 'Check your password and try again',
        },
        debugMessage: 'auth.js error code: $code',
      );
    }
  }

  /// Ends the session server-side. Requires the CSRF pair, like sign-in.
  Future<void> submitSignOut({required String csrfToken}) async {
    await _api.post<void>(
      AuthPaths.signOut,
      formUrlEncoded: true,
      body: <String, String>{'csrfToken': csrfToken, 'json': 'true'},
      decode: Decoders.unit,
    );
  }
}
